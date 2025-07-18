#!/usr/bin/env bash

set -ex

#----------------------------------------------------------------------------
# environment
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPTDIR}/build_common.cfg || { echo "cannot locate ${SCRIPTDIR}/build_common.cfg!!"; exit 1; }
#----------------------------------------------------------------------------

# Accept number of processors as first argument, or use NUM_PROCS env, or default to 1
NUM_PROCS="${1:-${NUM_PROCS:-1}}"

tar xzf .github/workflows/240km.tar.gz
mv 240km 240km_${NUM_PROCS}
cd 240km_${NUM_PROCS}/

ln -sf ../atmosphere_model .

# Modify namelist.atmosphere to change run duration (config_run_duration)
# from 5 days to quarter day  
sed -i "s/config_run_duration = '5_00:00:00'/config_run_duration = '0_06:00:00'/" namelist.atmosphere


echo "Running MPAS from $(pwd) on $NUM_PROCS processors"

# Run the model
# allow-run-as-root is needed for openmpi to run on github actions as root
if [ "$MPI_IMPL" = "openmpi" ]; then
    mpirun -n "$NUM_PROCS" --allow-run-as-root ./atmosphere_model
else
    mpirun -n "$NUM_PROCS" ./atmosphere_model
fi

