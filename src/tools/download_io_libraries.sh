#!/bin/bash
# filepath: /MPAS-Model/src/tools/download_io_libraries.sh

# Create the sources directory if it doesn't exist
mkdir -p sources

# Use wget to download all files from the directory
wget -r -np -nH --cut-dirs=5 -P sources --accept "*.tar.gz" https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/
