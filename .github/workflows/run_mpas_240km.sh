#!/usr/bin/env bash

set -ex

#----------------------------------------------------------------------------
# environment
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPTDIR}/build_common.cfg || { echo "cannot locate ${SCRIPTDIR}/build_common.cfg!!"; exit 1; }
#----------------------------------------------------------------------------

# Accept number of processors as first argument, or use NUM_PROCS env, and default to 1
NUM_PROCS="${1:-${NUM_PROCS:-1}}"

tar xzf .github/workflows/240km.tar.gz
mv 240km 240km_${NUM_PROCS}
cd 240km_${NUM_PROCS}/

ln -sf ../atmosphere_model .

# Modify namelist.atmosphere to change run duration (config_run_duration) to 6 hours
sed -i "s/config_run_duration = '[^']*'/config_run_duration = '0_06:00:00'/" namelist.atmosphere

# Modify streams.atmosphere to change restart output_interval to 6 hours
sed -i '/<immutable_stream name="restart"/,/\/>/ s/output_interval="[^"]*"/output_interval="0_06:00:00"/' streams.atmosphere


echo "Running MPAS from $(pwd) on $NUM_PROCS processors"
echo "MPI_FLAGS: $MPI_FLAGS"

# Run the model with MPI flags
# Use pipefail to ensure the script fails if mpirun fails
set -o pipefail

mpirun -n "$NUM_PROCS" $MPI_FLAGS ./atmosphere_model

