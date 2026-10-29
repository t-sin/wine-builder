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
Usage: build-wine VERSION PREFIX

Build a specific version of wine and install it

The VERSION will be used to determine a tag to clone git repository. Tags are
tyipically named like `wine-<version>`

PREFIX is a directory to installed all of build results.
If you run this script like `build-wine 10.0 /path/to/mywine`, a binary `wine` is
placed at `/path/to/mywine/bin/wine`.
So the WINELOADER for this should be set like `PREFIX/bin/wine`

OPTIONS
   -s, --staging                  Build a staging version instead of normal wine source tree.
   -d, --source-directory=PATH    Use sources placed on PATH insted of cloning sources.
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
