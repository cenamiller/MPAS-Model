#!/bin/bash
# filepath: /MPAS-Model/src/tools/download_io_libraries.sh

# Create the sources directory if it doesn't exist
mkdir -p sources

# Use wget to download all files from the directory
wget -P sources https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/mpich-3.3.1.tar.gz

wget -r -np -nH --cut-dirs=5 -P sources --accept "*.tar.gz" https://www2.mmm.ucar.edu/people/duda/files/mpas/sources/

# Unpack the tarballs
for file in sources/*.tar.gz; do
    tar -xzf $file -C sources
done


