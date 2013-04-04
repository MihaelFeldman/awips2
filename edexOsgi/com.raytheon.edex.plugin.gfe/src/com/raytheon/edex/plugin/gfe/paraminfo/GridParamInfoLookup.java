/**
 * This software was developed and / or modified by Raytheon Company,
 * pursuant to Contract DG133W-05-CQ-1067 with the US Government.
 *
 * U.S. EXPORT CONTROLLED TECHNICAL DATA
 * This software product contains export-restricted data whose
 * export/transfer/disclosure is restricted by U.S. law. Dissemination
 * to non-U.S. persons whether in the United States or abroad requires
 * an export license or other authorization.
 *
 * Contractor Name:        Raytheon Company
 * Contractor Address:     6825 Pine Street, Suite 340
 *                         Mail Stop B8
 *                         Omaha, NE 68106
 *                         402.291.0100
 *
 * See the AWIPS II Master Rights File ("Master Rights File.pdf") for
 * further licensing information.
 **/
package com.raytheon.edex.plugin.gfe.paraminfo;

import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import com.raytheon.uf.common.dataplugin.grid.mapping.DatasetIdMapper;
import com.raytheon.uf.common.localization.IPathManager;
import com.raytheon.uf.common.localization.LocalizationContext.LocalizationLevel;
import com.raytheon.uf.common.localization.LocalizationContext.LocalizationType;
import com.raytheon.uf.common.localization.LocalizationFile;
import com.raytheon.uf.common.localization.PathManagerFactory;
import com.raytheon.uf.common.status.IUFStatusHandler;
import com.raytheon.uf.common.status.UFStatus;
import com.raytheon.uf.common.status.UFStatus.Priority;
import com.raytheon.uf.common.time.TimeRange;
import com.raytheon.uf.common.util.mapping.MultipleMappingException;

/**
 * Lookup class for getting metadata information about grib parameters.
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Jun 24, 2010 #6372      bphillip     Initial creation
 * Jan 25, 2012 DR 14305   ryu          Read site parameterInfo files
 * Sep 12, 2012 #1117      dgilling     Implement method to retrieve all
 *                                      parm names for a given model.
 * Feb 15, 2013 1598       bsteffen     Make GridParamInfoLookup filter on
 *                                      extension.
 * Mar 20, 2013 #1774      randerso     Added getModelInfo, 
 *                                      added Dflt if no levels specified
 * 
 * </pre>
 * 
 * @author bphillip
 * @version 1.0
 */
public class GridParamInfoLookup {
    private static final transient IUFStatusHandler statusHandler = UFStatus
            .getHandler(GridParamInfoLookup.class);

    /** The singleton instance */
    private static GridParamInfoLookup instance;

    /** Parameter information map */
    private Map<String, GridParamInfo> modelParamMap;

    /**
     * Gets the singleton instance
     * 
     * @return The singleton instance
     */
    public synchronized static GridParamInfoLookup getInstance() {
        if (instance == null) {
            instance = new GridParamInfoLookup();
        }
        return instance;
    }

    /**
     * Creates a new GribParamInfoLookup instance
     */
    private GridParamInfoLookup() {
        modelParamMap = new HashMap<String, GridParamInfo>();
        init();
    }

    /**
     * Gets the model information based on the specified model
     * 
     * @param mappedModel
     *            The model name
     * @return The parameter information or null if none found
     */
    public GridParamInfo getGridParamInfo(String mappedModel) {
        String paramInfoName = null;
        try {
            paramInfoName = DatasetIdMapper.getInstance().lookupAliasOrNull(
                    mappedModel, "gfeParamInfo");
        } catch (MultipleMappingException e) {
            statusHandler.handle(Priority.WARN, e.getLocalizedMessage(), e);
            paramInfoName = e.getArbitraryMapping();
        }

        if (paramInfoName == null) {
            return null;
        }

        return modelParamMap.get(paramInfoName);
    }

    /**
     * Gets the parameter information based on the specified model and parameter
     * name
     * 
     * @param site
     *            The site which is requesting the information
     * @param model
     *            The model name
     * @param parameter
     *            The parameter name
     * @return The parameter information
     */
    public ParameterInfo getParameterInfo(String mappedModel, String parameter) {
        GridParamInfo modelInfo = getGridParamInfo(mappedModel);
        if (modelInfo == null) {
            return null;
        }

        ParameterInfo parameterInfo = modelInfo.getParameterInfo(parameter);

        return parameterInfo;
    }

    public List<TimeRange> getParameterTimes(String mappedModel, Date refTime) {
        GridParamInfo modelInfo = getGridParamInfo(mappedModel);
        if (modelInfo == null) {
            return Collections.emptyList();
        }
        return modelInfo.getAvailableTimes(refTime);
    }

    public Collection<String> getParmNames(String mappedModel) {
        GridParamInfo modelInfo = getGridParamInfo(mappedModel);
        if (modelInfo == null) {
            return Collections.emptyList();
        }

        List<ParameterInfo> paramInfoList = modelInfo.getGridParamInfo();
        Set<String> parmNames = new HashSet<String>();
        for (ParameterInfo info : paramInfoList) {
            parmNames.add(info.getShort_name());
        }

        return parmNames;
    }

    /**
     * Initializes the grid parameter information
     */
    private void init() {
        Unmarshaller um = null;
        try {
            JAXBContext context = JAXBContext.newInstance(ParameterInfo.class,
                    GridParamInfo.class, GribParamInfo.class);
            um = context.createUnmarshaller();
        } catch (JAXBException e) {
            statusHandler.handle(Priority.PROBLEM, e.getLocalizedMessage(), e);
            return;
        }
        IPathManager pm = PathManagerFactory.getPathManager();

        LocalizationFile[] files = pm.listFiles(
                pm.getLocalSearchHierarchy(LocalizationType.EDEX_STATIC),
                "grid" + IPathManager.SEPARATOR + "parameterInfo",
                new String[] { ".xml" }, true, true);

        for (LocalizationFile file : files) {
            try {
                GridParamInfo paramInfo = (GridParamInfo) um.unmarshal(file
                        .getFile());
                String key = file.getFile().getName().replace(".xml", "");
                if (!modelParamMap.containsKey(key)) {
                    modelParamMap.put(key, paramInfo);
                }
            } catch (JAXBException e) {
                statusHandler.handle(Priority.PROBLEM,
                        "Error unmarshalling grid parameter information", e);
            }
        }

        // Deprecated grib SITE level files.
        files = pm.listFiles(pm.getContext(LocalizationType.EDEX_STATIC,
                LocalizationLevel.SITE), "grib" + IPathManager.SEPARATOR
                + "parameterInfo", new String[] { ".xml" }, true, true);
        for (LocalizationFile file : files) {
            String name = file.getFile().getName().replace(".xml", "");
            // Do not override grid files.
            if (modelParamMap.get(name) != null) {
                continue;
            }

            try {
                GridParamInfo paramInfo = (GridParamInfo) um.unmarshal(file
                        .getFile());
                modelParamMap.put(name, paramInfo);
            } catch (JAXBException e) {
                statusHandler.handle(Priority.PROBLEM,
                        "Error unmarshalling grid parameter information", e);
            }
        }

        for (GridParamInfo gridParamInfo : modelParamMap.values()) {
            for (String parmName : gridParamInfo.getParmNames()) {
                ParameterInfo parameterInfo = gridParamInfo
                        .getParameterInfo(parmName);

                // add Dflt level if no other levels defined
                if (parameterInfo.getLevels().isEmpty()) {
                    parameterInfo.getLevels().add("Dflt");
                }
            }
        }
    }
}
