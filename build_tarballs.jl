# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "OpenLDAPBuilder"
version = v"2.4.46"

# Collection of sources required to build OpenLDAPBuilder
sources = [
    "ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-2.4.46.tgz" =>
    "9a90dcb86b99ae790ccab93b7585a31fbcbeec8c94bf0f7ab0ca0a87ea0c4b2d",

    "patches",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd openldap-2.4.46/
#wget http://www.linuxfromscratch.org/patches/blfs/svn/openldap-2.4.46-consolidated-1.patch
patch -Np1 -i ../openldap_patches/openldap-2.4.46-consolidated-1.patch 
autoconf
./configure --prefix=$prefix --host=$target --with-yielding-select=yes --disable-static --enable-dynamic --disable-debug --disable-slapd
apk update
apk add groff binutils
make depend
make -j${nproc}
make install || true # This is a hack

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, :glibc),
    MacOS(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "liblber", :liblber),
    LibraryProduct(prefix, "libldap", :libldap),
    LibraryProduct(prefix, "libldap_r", :libldap_r)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

