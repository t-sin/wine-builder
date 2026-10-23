#!/usr/bin/env bash
set -eu -o pipefail

# > ## Old WoW64 Build
# >
# > When Windows began targeting 64-bit architectures, Microsoft decided to include a compatibility layer to support their massive universe of 32-bit applications. This kind of subcomponent, nicknamed WoW64 (for Windows on Windows 64-bit), is also implemented in Wine to solve the exact same problem.
# >
# > **64-bit Wine built without 32-bit support will not be able to run ANY 32-bit applications, which most Windows binaries are. Even many 64-bit programs still include 32-bit components!**
# >
# > The good news is that once you have the dependencies in place to compile both 32 and 64-bit Wine, you've already done the hard part. If you have all your dependencies through multi-lib or (on some happy day in the future) you've co-installed all the dependencies through multi-arch, you only need to follow two simple steps:
# >
# > 1. Compile the 64-bit version of Wine first with the --enable-win64 configure flag, in a separate build directory of course ;)
# > 2. When you build the 32-bit version next (again in a fresh build directory), point configure to the 64-bit build directory by using --with-wine64= and the relative path
# >
# > On the command line:
# >
# > ```
# > $ cd ~/wine-dirs/wine64-build/
# > $ ../wine-source/configure --enable-win64
# > $ make
# > ```
# >
# > ```
# > $ cd ~/wine-dirs/wine32-build/
# > $ PKG_CONFIG_PATH=/path/to/pkgconfig ../wine-source/configure --with-wine64=../wine64-build
# > $ make
# > ```
# >
# > PKG_CONFIG_PATH should point to the location of the 32 bit pkgconfig files, probably /usr/lib or /usr/lib32 or /usr/lib/i386-linux-gnu. Without it, the configure script will pick up the 64 bit files and disable gstreamer support in the 32 bit build.
# >
# > When you make the 32-bit version of Wine, the build process should inject whatever libraries the 64-bit version needs to handle 32-bit programs. After that, just run wine from the 64-bit build to have WoW64 features.
# >
# > If you're using GCC, you need at least v4.4 to compile 64-bit wine because __builtin_ms_va_list support was missing from earlier versions. For the same reason, you need at least v3.7.1 of Clang.
# >
# > --- "Building Wine · Wiki · wine / wine · GitLab" from [Building Wine](https://gitlab.winehq.org/wine/wine/-/wikis/Building-Wine#old-wow64-build)
