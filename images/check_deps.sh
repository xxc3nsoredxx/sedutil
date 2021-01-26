#! /bin/bash

# [command] -> [package name]
declare -A DEPS
DEPS=(['curl']='curl' ['tar']='tar' ['gzip']='gzip' ['autoreconf']='autoconf' \
      ['sed']='sed' ['make']='make' ['xz']='xz-utils' ['ld']='binutils' \
      ['gcc']='gcc' ['g++']='g++' ['patch']='patch' ['bzip2']='bzip2' \
      ['perl']='perl' ['cpio']='cpio' ['unzip']='unzip' ['rsync']='rsync' \
      ['file']='file' ['bc']='bc' ['wget']='wget')
# Exit status - number of missing dependencies
STATUS=0

# Arg 1: missing package
function warn {
    echo "Missing dependency: $1"
    STATUS=$((STATUS + 1))
}

for D in ${!DEPS[@]}; do
    which $D &> /dev/null || warn "${DEPS[$D]}"
done

if [ $STATUS -eq 0 ]; then
    echo "No missing dependencies"
fi

exit $STATUS
