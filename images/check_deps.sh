#! /bin/bash

# [command] -> [package name]
declare -A DEPS
DEPS=(['curl']='curl' ['tar']='tar' ['gzip']='gzip' ['autoreconf']='autoconf' \
      ['sed']='sed' ['make']='make' ['xz']='xz-utils' ['ld']='binutils' \
      ['gcc']='gcc' ['g++']='g++' ['patch']='patch' ['bzip2']='bzip2' \
      ['perl']='perl' ['cpio']='cpio' ['unzip']='unzip' ['rsync']='rsync' \
      ['file']='file' ['bc']='bc' ['wget']='wget')
# Exit status - number of missing dependencies (incl. disk space)
STATUS=0

# Arg 1: missing package
function warn {
    echo "Missing dependency: '$1'!"
    STATUS=$((STATUS + 1))
}

# Check for missing packages
for D in ${!DEPS[@]}; do
    which $D &> /dev/null || warn "${DEPS[$D]}"
done

# Check disk space
SPACE="$(df -B1 --output=avail . | tail -n 1)"
if [ $SPACE -lt 7516192768 ]; then
    echo "Less than 7 GiB of space available on '$(findmnt -T . -o source -n)'"
    STATUS=$((STATUS + 1))
fi

if [ $STATUS -eq 0 ]; then
    echo "No missing dependencies"
fi

exit $STATUS
