#! /bin/bash
. conf
set -o pipefail

# Test if scratch directory exists
if ! [ -d scratch ]; then
    echo 'Creating directory "scratch" ...'
    mkdir scratch
fi

# Download SYSLINUX
pushd scratch &> /dev/null
    # Test if SYSLINUX tarball exists
    if ! [ -e .syslinux_dl_done ]; then
        while ! [ -e .syslinux_dl_done ]; do
            echo 'Fetching SYSLINUX tarball ...'
            curl -L -O $SYSLINUX_URL/$SYSLINUX_VER.tar.xz && touch .syslinux_dl_done
        done
    fi

    # Test if SYSLINUX is extracted
    if ! [ -d $SYSLINUX_VER ]; then
        echo 'Extracting SYSLINUX tarball ...'
        tar xf $SYSLINUX_VER.tar.xz
    fi
popd &> /dev/null

# Prepare buildroot sources
pushd scratch &> /dev/null
    # Test if buildroot tarball exists
    if ! [ -e .buildroot_dl_done ]; then
        while ! [ -e .buildroot_dl_done ]; do
            echo 'Fetching Buildroot tarball ...'
            curl -L -O $BUILDROOT_URL/$BUILDROOT_VER.tar.gz && touch .buildroot_dl_done
        done
    fi

    # Test if buildroot is extracted
    if ! [ -d buildroot ]; then
        echo 'Extracting Buildroot tarball ...'
        tar xf $BUILDROOT_VER.tar.gz
        mv $BUILDROOT_VER buildroot
    fi

    # Prepare buildroot tree
    pushd buildroot &> /dev/null
        # Clean any existing files
        if [ -d 64bit ]; then
            echo 'Cleaning existing tree ...'
            rm -rf 64bit
        fi

        # Add out-of-tree build directories and files
        echo 'Creating out-of-tree structure ...'
        cp -r ../../buildroot/64bit ./

        # Add the buildroot packages
        echo 'Patching Buildroot config for sedutil ...'
        sed -i '/sedutil/d' package/Config.in
        sed -i '/menu "System tools"/a \\tsource "package/sedutil/Config.in"' package/Config.in
        rm -rf package/sedutil
        cp -r ../../buildroot/packages/sedutil/ package/

        # Add the busybox patchs
        echo 'Adding busybox patches ...'
        ls -w 1 ../../buildroot/packages/busybox/*.patch
        cp -r ../../buildroot/packages/busybox/ package/

        # Build sedutil tarball and add it
        pushd ../../.. &> /dev/null
            echo 'Reconfiguring sedutil ...'
            autoreconf -i
            ./configure

            echo 'Building sedutil package ...'
            make dist

            echo 'Adding sedutil to Buildroot tree ...'
            mkdir -p images/scratch/buildroot/dl/
            cp sedutil-*.tar.gz images/scratch/buildroot/dl/
            make distclean

            # Expand the distribution tarball so we can use it as the Buildroot override.
            # Override location is specified in the 'local.mk' file in buildroot/64bit
            # directory.
            # See also section 8.12.6 "Using Buildroot during development" in the
            # Buildroot user manual.
            cd images/scratch/buildroot/dl
            tar xf sedutil-*.tar.gz
        popd &> /dev/null

        # Have buildroot download the required sources
        echo 'Fetching required sources with Buildroot ...'
        while ! [ -e .buildroot_sources_dl_done ]; do
            make O=64bit source |& tee -a 64bit/dl_output.txt && touch .buildroot_sources_dl_done
        done
    popd &> /dev/null
popd &> /dev/null
