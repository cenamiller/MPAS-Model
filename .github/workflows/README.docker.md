# MPAS-NVIDIA Docker Image

This document describes the process for building and maintaining the MPAS-NVIDIA Docker image used for OpenACC-enabled MPAS builds.

## Image Overview

The image is based on NVIDIA HPC SDK and includes:
- NVIDIA compilers (nvfortran, nvc, nvc++)
- PGI compiler wrappers (pgf90, pgcc, pgc++)
- MPICH for MPI support
- PNetCDF library
- Essential build tools

## Building the Image

1. Clean up existing Docker resources:
```bash
# Show current disk usage
docker system df

# Remove all stopped containers
docker container prune -f

# Remove all unused images
docker image prune -af

# Remove all unused volumes
docker volume prune -f

# Remove all build cache
docker builder prune -af

# Verify cleanup
docker system df
```

2. Build the image:
```bash
docker build -t mpas-nvidia -f .github/workflows/Dockerfile.mpas-nvidia .
```

3. Tag and push to Docker Hub:
```bash
docker tag mpas-nvidia:latest cmille73/mpas-nvidia:latest
docker push cmille73/mpas-nvidia:latest
```

## Image Structure

The Dockerfile uses a multi-stage build process:

1. **Builder Stage**:
   - Installs build dependencies
   - Compiles PNetCDF library
   - Creates necessary library directories

2. **Final Stage**:
   - Uses NVIDIA HPC SDK base image
   - Installs minimal runtime dependencies
   - Copies compiled libraries from builder stage
   - Sets up PGI compiler wrappers
   - Configures environment variables

## Important Notes

1. **PGI Compiler Wrappers**:
   - The image maintains PGI compiler wrappers (pgcc, pgf90, pgc++) as symlinks to NVIDIA compilers
   - These wrappers are required for MPAS build compatibility
   - Wrappers are created in the cleanup step of the Dockerfile

2. **Environment Variables**:
   - PATH includes NVIDIA compiler directories
   - LD_LIBRARY_PATH includes necessary library paths
   - MPAS-specific variables are set for PNetCDF

3. **Cleanup Process**:
   - Removes unnecessary NVIDIA components to reduce image size
   - Preserves essential compiler and library components
   - Maintains PGI compiler wrappers

## Troubleshooting

If you encounter issues with the PGI compilers:
1. Verify the symlinks exist:
```bash
docker run --rm cmille73/mpas-nvidia ls -l /opt/nvidia/hpc_sdk/Linux_x86_64/25.3/compilers/bin/pg*
```

2. Check compiler versions:
```bash
docker run --rm cmille73/mpas-nvidia pgcc --version
docker run --rm cmille73/mpas-nvidia pgf90 --version
```

## Maintenance

Regular maintenance tasks:
1. Update base image version when new NVIDIA HPC SDK is released
2. Clean up Docker resources periodically
3. Rebuild image after significant changes
4. Test the image with MPAS builds before pushing to production

## Image Size Optimization

The image size is optimized by:
1. Using multi-stage builds
2. Removing unnecessary NVIDIA components
3. Cleaning up build artifacts
4. Minimizing installed packages

Current image size: ~28GB 