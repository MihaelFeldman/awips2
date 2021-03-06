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
package com.raytheon.viz.mpe.util;

import com.raytheon.viz.mpe.util.DailyQcUtils.Station;
import com.raytheon.viz.mpe.util.Disagg6Hr.Dist;
import com.raytheon.viz.mpe.util.Disagg6Hr.Values_1hr;
import com.raytheon.viz.mpe.util.Disagg6Hr.Values_6hr;

/**
 * Disagg Point Method
 * 
 * <pre>
 * 
 * SOFTWARE HISTORY
 * Date         Ticket#    Engineer    Description
 * ------------ ---------- ----------- --------------------------
 * Apr 22, 2009            snaples     Initial creation
 * Jul 28, 2016 4623       skorolev    Cleanup.
 * 
 * </pre>
 * 
 * @author snaples
 */

public class DisaggPointMethod {

    private DailyQcUtils dqc = DailyQcUtils.getInstance();

    private Station[] disaggStation6hr = Disagg6Hr.disagg_station_6hr;

    private Values_1hr[] disaggValues = Disagg6Hr.disaggValues;

    private int disaggDbFactor = Disagg6Hr.disagg_db_factor;

    private Values_6hr[] values6hr = Disagg6Hr.values6hr;

    private int mpeDqcMaxPrecipNeighbors = DailyQcUtils.mpe_dqc_max_precip_neighbors;

    private Dist[] dist6hrTo1hr = Disagg6Hr.dist_6hr_to_1hr;

    private int sortedArraySize = Compute1HrNeighborList.sortedArraySize;

    private int[] sortedList1hr = Compute1HrNeighborList.sortedList1hr;

    private Values_1hr[] valuesReadIn = Compute1HrNeighborList.valuesReadIn;

    private Station[] disaggStation1hr = Compute1HrNeighborList.disaggStation1hr;

    /**
     * 
     */
    public void disaggPointMethod() {

        int i, j, k, l, m, n, p;

        float fdist = 0.f;
        float fdata = 0.f;
        float[] fvalue = new float[6];
        float val1hr = -9999.f;
        short prism1hr = -9999;
        short prism6hr = -9999;
        float dist; // 6hr to 1hr
        float padj;
        float scale = 1.f;
        float stotal = 0.f;
        int numMissingPeriods = 0;
        int numDisaggStations = Disagg6Hr.num_disagg_stations;
        int numDaysToQc = DailyQcUtils.qcDays;
        boolean goToNextNeighbor = false;
        boolean next6hrStation = false;
        int index = -1;

        for (i = 0; i < numDisaggStations; i++) {
            for (j = 0; j < numDaysToQc; j++) {
                index = j * numDisaggStations + i;

                if (values6hr[index].ID
                        .equals(Disagg6Hr.DISAGG_MISSING_STATION_SYMBOL)) {
                    continue;
                }

                for (k = 0; k < 4; k++)// 4 6hr periods
                {

                    // If the quality code is the following don't disagg

                    for (n = 0; n < 6; n++) {
                        fvalue[n] = -9999.f;
                        /*
                         * block that checks if the six hr station has a missing
                         * report if it is a missing report, don't bother
                         * disagging the station
                         */
                        if (values6hr[index].value[k] < 0.) {
                            disaggValues[index].dqc_day = j;
                            for (l = 0; l < 6; l++) {
                                disaggValues[index].HourlyValues[6 * k + l] = -9999.f;
                            }
                            next6hrStation = true;
                            break;
                        }
                        /*
                         * block that handles a six hr station with a val = 0
                         * all 1hr periods get a value of '0'
                         */
                        else if (values6hr[index].value[k] == 0.) {
                            disaggValues[index].dqc_day = j;
                            for (l = 0; l < 6; l++) {
                                disaggValues[index].HourlyValues[6 * k + l] = 0.f;
                            }
                            next6hrStation = true;
                            break;
                        }
                        /*
                         * block that handles a six hr station with a non
                         * missing, non zero report
                         */
                        else {
                            for (p = 0; p < 12; p++) {
                                if (disaggStation6hr[index].isoh[p] != -1) {
                                    /*
                                     * at the moment we are using the prism
                                     * value for the first month dqc run time
                                     * spans into. in some cases it could span
                                     * into 2 months
                                     */
                                    prism6hr = (short) disaggStation6hr[index].isoh[p];
                                    break;
                                }
                            }
                            for (l = 0; l < mpeDqcMaxPrecipNeighbors; l++) {
                                dist = (float) dist6hrTo1hr[i].distances_to_neighbors[l];
                                if (dist == 0) {
                                    dist = 0.000001f;
                                }

                                for (m = 0; m < sortedArraySize; m++) {
                                    if (disaggStation6hr[index].index[l] == sortedList1hr[m]) {
                                        val1hr = valuesReadIn[j
                                                * sortedArraySize + m].HourlyValues[6
                                                * k + n];
                                        if (val1hr < 0.0) {
                                            goToNextNeighbor = true;
                                            break;
                                        }
                                        for (p = 0; p < 12; p++) {
                                            if (disaggStation1hr[sortedList1hr[m]].isoh[p] != -1) {
                                                /*
                                                 * at the moment we are using
                                                 * the prism value for the first
                                                 * month dqc run time spans
                                                 * into. in some cases it could
                                                 * span into 2 months
                                                 */
                                                prism1hr = (short) disaggStation1hr[sortedList1hr[m]].isoh[p];
                                                break;
                                            }
                                        }
                                        break;
                                    }
                                }
                                if (goToNextNeighbor) {
                                    goToNextNeighbor = false;
                                    continue;
                                }
                                padj = val1hr * (prism6hr / prism1hr);
                                fdist = (float) (fdist + (1 / Math.pow(dist, 2)));
                                fdata = (float) (fdata + (padj / Math.pow(dist,
                                        2)));
                            }
                            /*
                             * Quit if number of reported 1hrs is less than
                             * desired. This piece is being commented at the
                             * moment.
                             */
                            fvalue[n] = fdata / fdist;
                        }
                    }

                    stotal = 0.0f;
                    numMissingPeriods = 0;
                    for (l = 0; l < 6; l++) {
                        if (fvalue[l] >= 0) {
                            stotal = stotal + fvalue[l];
                        } else {
                            numMissingPeriods++;
                        }
                    }

                    disaggValues[index].dqc_day = j;
                    if (numMissingPeriods > 0) {
                        // write to log file set all 1hr values to missing
                        for (l = 0; l < 6; l++) {
                            disaggValues[index].HourlyValues[6 * k + l] = -9999.f;
                        }
                    } else {
                        scale = values6hr[index].value[k] / stotal;
                        for (l = 0; l < 6; l++) {
                            if (fvalue[l] != -9999.) {
                                disaggValues[index].HourlyValues[6 * k + l] = fvalue[l]
                                        * scale * disaggDbFactor;
                            }
                        }
                    }
                    if (next6hrStation) {
                        next6hrStation = false;
                        continue;
                    }
                }
            }
        }
    }

}
