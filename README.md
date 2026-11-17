# wine-builder

My scripts to build [wine](https://www.winehq.org) locally.

## No License

This repository has no license. All rights reserved by the author. This repository is publicly available for others to view, but it is **not intended for reuse by others**.

## Usage

To build [wine 11.0](https://gitlab.winehq.org/wine/wine/-/tags/wine-11.0) (a stable release of wine 11.x), run `build-wine` in this repo like this:

```
./build-wine 11.0 /path/to/install/wine_11.0
```

```
Usage: build-wine [OPTION] TARGET_OPTION PREFIX

Build a wine specified TARGET_OPTION and install it.

PREFIX is a directory to installed all of build results. If you run this script
like `build-wine 10.0 /path/to/mywine`, a binary `wine` is placed at
`/path/to/mywine/bin/wine`.
So the WINELOADER for this should be set like `PREFIX/bin/wine`.

TARGET_OPTION determines the target to build. TARGET OPTIONS are mutually
exclusive so there is neccesary to choose one.

To build a specific version, choose `-v VERSION` target option. This will be a
tag in official git repository. Tags are tyipically named like `wine-<version>`.
The source will be cloned from official git repository.

To build with existed source, choose this `-d SRCDIR` option.

TARGET OPTIONS                  These options are mutually exclusive.
   -v, --version=VERSION    ... Build wine with specified version.
   -d, --source=SRCDIR      ... Build wine with sources placed on SRCDIR.

OTHER OPTION'
   -s, --staging            ... Build a staging version instead of winehq/wine
                                repository. This option affects only builds
                                git-cloned source, like -v option.
   -h, --help               ... Show this message.
```

Tested on:

- New wow64 build (11.0 or later)
    - [x] wine 11.0
    - [x] wine-staging 11.0
- Old wow64 build
    - [x] wine 10.2
    - [x] wine-staging 9.21

## Requirements

- bash
- docker

## Author

- t-sin (<t-sin@ibotenic.sakura.ne.jp>)
