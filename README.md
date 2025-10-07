# wine-builder

My scripts to build [wine](https://www.winehq.org) locally.

To build [wine 9.0.1](https://gitlab.winehq.org/wine/wine/-/tags/wine-9.0.1) (a stable release of wine 9.x), run `build-wine` in this repo like this:

```
./build-wine 9.0.1 /path/to/install/wines
```

Its usage is:

```
Usage: build-wine VERSION PREFIX

Build a specific version of wine and install it

The VERSION will be used to determine a tag to clone git repository. Tags are
tyipically named like `wine-<version>`

PREFIX is a directory name will contain wine directory built. A directory, named
like `wine_VERSION`, including all files built will be placed at `PREFIX`. So
the WINELOADER should be `PREFIX/wine_VERSION/bin/wine`
```

## Requirements

- bash
- docker

## Author

- t-sin (<t-sin@ibotenic.sakura.ne.jp>)

## License

*wine-builder* is licensed under the [MIT license](LICENSE).
