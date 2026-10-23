#!/usr/bin/env bash
set -eu -o pipefail

# > ## New WoW64 Build
# >
# > Most likely you want a "new WoW64" build, which can run both 32-bit and 64-bit Windows applications on 64-bit Linux without any 32-bit Linux libraries. Things should be very simple. Once all the build requirements are installed, go to the wine source directory and run:
# >
# > ```sh
# > $ ./configure --enable-archs=i386,x86_64
# > $ make -j`nproc`
# > ```
# >
# > Installing wine to /usr is optional. You can run wine entirely from within the build directory without installation:
# >
# > ```
# > $ ./wine <some-exe>
# > ```
# >
# > ## 32-bit-only Build
# >
# > If you want to build Wine on a 32-bit system and run it on the same system, simply run the configure script without arguments, for example:
# >
# > ```
# > $ ./configure
# > $ make -j`nproc`
# > ```
# >
# > ## 64-bit-only Build
# >
# > If you're on a 64-bit system, all you need to do to build a 64-bit wine is pass --enable-win64 to the configure script:
# >
# > ```
# > $ ./configure --enable-win64
# > $ make -j`nproc`
# > ```
# >
# > The problem is that by itself, that build will only run applications compiled for 64-bit Windows. Since the vast majority of Windows applications have 32-bit installers even if the application itself is 64-bit, you very likely want to follow the new WoW64 instructions above or old WoW64 instructions below.
# >
# --- "Building Wine · Wiki · wine / wine · GitLab" from [Building Wine](https://gitlab.winehq.org/wine/wine/-/wikis/Building-Wine#new-wow64-build)
