# MPAS Dependencies Dockerfile
# Based on the GitHub Actions workflow for installing MPAS libraries
FROM ubuntu:latest

# Set environment variables
ENV LIBSRC=/tmp/sources
ENV LIBBASE=/opt/mpas-libs
ENV SERIAL_FC=gfortran
ENV SERIAL_F77=gfortran
ENV SERIAL_CC=gcc
ENV SERIAL_CXX=g++
ENV MPI_FC=mpifort
ENV MPI_F77=mpifort
ENV MPI_CC=mpicc
ENV MPI_CXX=mpic++

# Install system dependencies
RUN apt-get update && apt-get install -y \
    mpich \
    libmpich-dev \
    cmake \
    curl \
    libcurl4-openssl-dev \
    wget \
    bzip2 \
    git \
    build-essential \
    m4 \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p ${LIBSRC} ${LIBBASE}

# Install Zlib
RUN cd ${LIBSRC} \
    && wget http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/zlib-1.2.11.tar.gz \
    && tar xzvf zlib-1.2.11.tar.gz \
    && cd zlib-1.2.11 \
    && ./configure --prefix=${LIBBASE} --static \
    && make -j 4 \
    && make install \
    && cd .. \
    && rm -rf zlib-1.2.11 zlib-1.2.11.tar.gz

# Install HDF5
RUN cd ${LIBSRC} \
    && wget http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/hdf5-1.10.5.tar.bz2 \
    && tar xjvf hdf5-1.10.5.tar.bz2 \
    && cd hdf5-1.10.5 \
    && export FC=${MPI_FC} \
    && export CC=${MPI_CC} \
    && export CXX=${MPI_CXX} \
    && ./configure --prefix=${LIBBASE} --enable-parallel --with-zlib=${LIBBASE} --disable-shared \
    && make -j 4 \
    && make install \
    && cd .. \
    && rm -rf hdf5-1.10.5 hdf5-1.10.5.tar.bz2

# Install Parallel-netCDF
RUN cd ${LIBSRC} \
    && wget http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/pnetcdf-1.11.2.tar.gz \
    && tar xzvf pnetcdf-1.11.2.tar.gz \
    && cd pnetcdf-1.11.2 \
    && ./configure --prefix=${LIBBASE} \
    && make -j 4 \
    && make install \
    && cd .. \
    && rm -rf pnetcdf-1.11.2 pnetcdf-1.11.2.tar.gz

# Install NetCDF-C
RUN cd ${LIBSRC} \
    && wget http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/netcdf-c-4.7.0.tar.gz \
    && tar xzvf netcdf-c-4.7.0.tar.gz \
    && cd netcdf-c-4.7.0 \
    && export CPPFLAGS="-I${LIBBASE}/include" \
    && export LDFLAGS="-L${LIBBASE}/lib" \
    && export LIBS="-lhdf5_hl -lhdf5 -lz -ldl" \
    && export CC=${MPI_CC} \
    && ./configure --prefix=${LIBBASE} --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-cdf5 --enable-parallel-tests --disable-shared \
    && make -j 4 \
    && make install \
    && cd .. \
    && rm -rf netcdf-c-4.7.0 netcdf-c-4.7.0.tar.gz

# Install NetCDF-Fortran
RUN cd ${LIBSRC} \
    && wget http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/netcdf-fortran-4.4.5.tar.gz \
    && tar xzvf netcdf-fortran-4.4.5.tar.gz \
    && cd netcdf-fortran-4.4.5 \
    && export FC=${MPI_FC} \
    && export F77=${MPI_F77} \
    && export LIBS="-lnetcdf ${LIBS}" \
    && export FFLAGS="-g -fbacktrace -fallow-argument-mismatch" \
    && export FCFLAGS="-g -fbacktrace -fallow-argument-mismatch" \
    && export CPPFLAGS="-I${LIBBASE}/include" \
    && export LDFLAGS="-L${LIBBASE}/lib" \
    && ./configure --prefix=${LIBBASE} --enable-parallel-tests --disable-shared \
    && make -j 4 \
    && make install \
    && cd .. \
    && rm -rf netcdf-fortran-4.4.5 netcdf-fortran-4.4.5.tar.gz

# Install PIO
RUN cd ${LIBSRC} \
    && git clone https://github.com/NCAR/ParallelIO \
    && cd ParallelIO \
    && git checkout -b pio-2.5.10 pio2_5_10 \
    && export PIOSRC=$(pwd) \
    && cd .. \
    && mkdir pio \
    && cd pio \
    && export CC=${MPI_CC} \
    && export FC=${MPI_FC} \
    && cmake -DNetCDF_C_PATH=${LIBBASE} \
             -DNetCDF_Fortran_PATH=${LIBBASE} \
             -DPnetCDF_PATH=${LIBBASE} \
             -DHDF5_PATH=${LIBBASE} \
             -DCMAKE_INSTALL_PREFIX=${LIBBASE} \
             -DPIO_USE_MALLOC=ON \
             -DCMAKE_VERBOSE_MAKEFILE=1 \
             -DPIO_ENABLE_TIMING=OFF \
             -DMPI_C_INCLUDE_PATH=/usr/include/mpich \
             -DMPI_Fortran_INCLUDE_PATH=/usr/include/mpich \
             ${PIOSRC} \
    && make \
    && make install \
    && cd .. \
    && rm -rf pio ParallelIO

# Set MPAS environment variables
ENV MPAS_EXTERNAL_LIBS="-L${LIBBASE}/lib -lhdf5_hl -lhdf5 -ldl -lz -lpnetcdf"
ENV MPAS_EXTERNAL_INCLUDES="-I${LIBBASE}/include"
ENV PNETCDF=${LIBBASE}

# Clean up source directory
RUN rm -rf ${LIBSRC}

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"] 