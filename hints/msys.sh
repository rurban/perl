#! /bin/sh
# msys.sh - windows cross-compile for mingw
#

# not otherwise settable
exe_ext='.exe'
firstmakefile='GNUmakefile'
case "$ldlibpthname" in
'') ldlibpthname=PATH ;;
esac

# mandatory (overrides incorrect defaults)
test -z "$cc" && cc='gcc'
if test -z "$plibpth"
then
    plibpth=`gcc -print-file-name=libc.a`
    plibpth=`dirname $plibpth`
    plibpth=`cd $plibpth && pwd`
fi
usenm=no
issymlink=false
# XXX this is fragile
libc=/usr/lib/libmsys-1.0.dll.a
so='dll'
# - eliminate -lc, causes multiple definition of `__impure_ptr'
libswanted=`echo " $libswanted " | sed -e 's/ c / /g'`
# eliminate -lm, causes multiple definition of `___infinity'
libswanted=`echo " $libswanted " | sed -e 's/ m / /g'`
# - eliminate -lutil, symbols are all in libc
libswanted=`echo " $libswanted " | sed -e 's/ util / /g'`
# XXX if gdbm add libgdbm_compat
# libswanted="$libswanted gdbm_compat"
test -z "$optimize" && optimize='-O3'
man3ext='3pm'
test -z "$use64bitint" && use64bitint='define'
test -z "$useithreads" && useithreads='define'
ccflags="$ccflags -DPERL_USE_SAFE_PUTENV -U__STRICT_ANSI__"

# dynamic loading
cccdlflags=' '
lddlflags=' --shared'
test -z "$ld" && ld='g++'

# IPv6
# This will need: netsh interface ipv6 install
# XXX How to query?
d_inetntop='define'
d_inetpton='define'

# compile Win32CORE "module" as static. try to avoid the space.
if test -z "$static_ext"; then
  static_ext="Win32CORE"
else
  static_ext="$static_ext Win32CORE"
fi

# XXX Win9x problem with non-blocking read from a closed pipe
#d_eofnblk='define'

# suppress auto-import warnings
ldflags="$ldflags -Wl,--enable-auto-import -Wl,--export-all-symbols -Wl,--enable-auto-image-base"
lddlflags="$lddlflags $ldflags"

# Strip exe's and dll's? Better do it afterwards to allow -debuginfo packages
#ldflags="$ldflags -s"
#ccdlflags="$ccdlflags -s"
#lddlflags="$lddlflags -s"
