#!/usr/bin/env bash
#set -eu -o pipefail

if [ $# -ne 3 ]; then
  echo "usage: $(basename ""$0"") WORK_DIR WINE_VERSION PREFIX"
  echo
  echo 'Build wine with new wow64 build in Docker container.'
  echo 'This script assumes the source is placed at `WORK_DIR/wine.src`.'
  exit 1
fi

workdir=$1
wine_version=$2
prefix=$3

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

docker_progress=auto
if [ ! -z "$DOCKER_PROGRESS" ]; then
  docker_progress=$DOCKER_PROGRESS
fi

image_tag=wine-builder_${wine_version}_new-wow64

(docker image ls --format "{{.Repository}}" | grep -x "${image_tag}" > /dev/null); image_found=$?
if [ $image_found -ne 0 ]; then
  echo 'remove already existed image'
  docker rmi "${image_tag}"
fi

echo 'building wine (new wow64 build)...'
dockerfile=docker/Dockerfile.new-wow64-builder
declare -a build_args=(
    --progress "$docker_progress"
    -f "$dockerfile"
    --tag "$image_tag"
    --platform "$DOCKER_PLATFORM_WINE64"
    --build-context source="$workdir"
    --build-arg base_image="$DOCKER_BASE_IMAGE64"
    --build-arg prefix="$prefix"
    --build-arg make_max_jobs="$MAKE_MAX_JOBS"
    .
)
echo docker build "${build_args[@]}"
docker build "${build_args[@]}"

echo 'successfully built wine (new wow64 build).'

echo "copying wine files into ${prefix}..."
container_id=$(docker create "$image_tag")
docker cp "${container_id}:${prefix}/" "$prefix/"
docker rm "${container_id}"

echo "successfully installed wine (${wine_version}, new wow64 build) at:"
echo "  ${prefix}"
