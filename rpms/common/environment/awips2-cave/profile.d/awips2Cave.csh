#!/bin/csh
if ( $USER != "awips" && $USER != 'root' ) then
  return
  exit 0
endif

# Determine where cave has been installed.
set CAVE_INSTALL="/awips2/cave"
setenv TMCP_HOME "${CAVE_INSTALL}/caveEnvironment"
setenv FXA_HOME "${CAVE_INSTALL}/caveEnvironment"
