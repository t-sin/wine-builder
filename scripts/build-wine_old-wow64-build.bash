#!/usr/bin/env bash
#set -eu -o pipefail

if [ $# -ne 3 ]; then
  echo "usage: $(basename ""$0"") WORK_DIR WINE_VERSION PREFIX"
  echo
  echo 'Build wine with old wow64 build in Docker container.'
  echo 'This script assumes the source is placed at `WORK_DIR/wine.src`.'
  exit 1
fi

workdir=$1
wine_version=$2
prefix=$3

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

image_tag_base=wine-builder_${wine_version}_old-wow64

docker_progress=auto
if [ ! -z "$DOCKER_PROGRESS" ]; then
  docker_progress=$DOCKER_PROGRESS
fi

image_tag_wine64=${image_tag_base}_wine64-builder
echo
echo "checking existed image ${image_tag_wine64}..."
(docker image ls --format "{{.Repository}}" | grep -x "$image_tag_wine64") >/dev/null 2>&1; image_found=$?
if [ $image_found -ne 0 ]; then
  echo  "remove already existed image: $image_tag_wine64"
  docker image rm "${image_tag_wine64}:latest"
fi

echo
echo 'building wine64 (old wow64 build)...'
dockerfile=docker/Dockerfile.old-wow64-wine64-builder
declare -a build_args=(
    --progress "$docker_progress"
    -f "$dockerfile"
    --tag "$image_tag_wine64"
    --platform "$DOCKER_PLATFORM_WINE64"
    --build-context source="$workdir"
    --build-arg base_image="$DOCKER_BASE_IMAGE64"
    --build-arg prefix="$prefix"
    --build-arg make_max_jobs="$MAKE_MAX_JOBS"
    .
)
echo docker build "${build_args[@]}"
docker build "${build_args[@]}" > "${workdir}/docker-build-wine64.log" 2>&1; build_success=$?

echo 'successfully built wine64 (old wow64 build).'

# wine32-base
image_tag_wine32_base=${image_tag_base}_wine32-base
echo
echo "checking existed image ${image_tag_wine32_base}..."
(docker image ls --format "{{.Repository}}" | grep -x "$image_tag_wine32_base") >/dev/null 2>&1; image_found=$?
if [ $image_found -ne 0 ]; then
  echo  "remove already existed image: $image_tag_wine32_base"
  docker image rm "${image_tag_wine32_base}:latest"
fi

echo
echo 'building wine32-base (old wow64 build)...'
dockerfile=docker/Dockerfile.old-wow64-wine32-base
declare -a build_args=(
    --progress "$docker_progress"
    -f "$dockerfile"
    --tag "$image_tag_wine32_base"
    --platform "$DOCKER_PLATFORM_WINE32"
    --build-context source="$workdir"
    --build-arg base_image="$DOCKER_BASE_IMAGE32"
    --build-arg make_max_jobs="$MAKE_MAX_JOBS"
    .
)
echo docker build "${build_args[@]}"
docker build "${build_args[@]}" > "${workdir}/docker-build-wine32-base.log" 2>&1; build_success=$?

echo 'successfully built wine32-base (old wow64 build).'

# wine32-tools
image_tag_wine32_tools=${image_tag_base}_wine32-tools
echo
echo "checking existed image ${image_tag_wine32_tools}..."
(docker image ls --format "{{.Repository}}" | grep -x "$image_tag_wine32_tools") >/dev/null 2>&1; image_found=$?
if [ $image_found -ne 0 ]; then
  echo  "remove already existed image: $image_tag_wine32_tools"
  docker image rm "${image_tag_wine32_tools}:latest"
fi

echo
echo 'building wine32-tools (old wow64 build)...'
dockerfile=docker/Dockerfile.old-wow64-wine32-tools
declare -a build_args=(
    --progress "$docker_progress"
    -f "$dockerfile"
    --tag "$image_tag_wine32_tools"
    --platform "$DOCKER_PLATFORM_WINE32"
    --build-context source="$workdir"
    --build-arg wine_version="$wine_version"
    --build-arg make_max_jobs="$MAKE_MAX_JOBS"
    "${workdir}"
)
echo docker build "${build_args[@]}"
docker build "${build_args[@]}" > "${workdir}/docker-build-wine32-tools.log" 2>&1; build_success=$?

if [ $build_success -ne 0 ]; then
  echo "build failed: $image_tag_wine32_tools"
  exit 1
fi

echo 'successfully built wine32-tools (old wow64 build).'

# wine32
image_tag_wine32=${image_tag_base}_wine32-builder
echo
echo "checking existed image ${image_tag_wine32}..."
(docker image ls --format "{{.Repository}}" | grep -x "$image_tag_wine32") >/dev/null 2>&1; image_found=$?
if [ $image_found -ne 0 ]; then
  echo  "remove already existed image: $image_tag_wine32"
  docker image rm "${image_tag_wine32}"
fi

echo
echo "copying files from wine64 container..."
container_id=$(docker create "$image_tag_wine64")
docker cp "${container_id}:/build-wine/wine64" "${workdir}/wine64"
docker rm "${container_id}"

echo
echo "copying files from wine32-tools container..."
container_id=$(docker create "$image_tag_wine32_tools")
docker cp "${container_id}:/build-wine/wine32-tools" "${workdir}/wine32-tools"
docker rm "${container_id}"

echo
echo 'building wine32 (old wow64 build)...'
dockerfile=docker/Dockerfile.old-wow64-wine32-builder
declare -a build_args=(
    --progress "$docker_progress"
    -f "$dockerfile"
    --tag "$image_tag_wine32"
    --platform "$DOCKER_PLATFORM_WINE32"
    --build-context source="$workdir"
    --build-arg wine_version="$wine_version"
    --build-arg prefix="$prefix"
    --build-arg make_max_jobs="$MAKE_MAX_JOBS"
    "${workdir}"
)
echo docker build "${build_args[@]}"
docker build "${build_args[@]}" > "${workdir}/docker-build-wine32.log" 2>&1; build_success=$?

echo 'successfully built wine32 (old wow64 build).'

echo
echo "copying wine files into ${prefix}..."
container_id=$(docker create "$image_tag_wine32")
docker cp "${container_id}:${prefix}/" "$prefix/"
docker rm "${container_id}"

echo
echo "successfully installed wine (${wine_version}, old wow64 build) at:"
echo "  ${prefix}"
