![REUSE Compliance](https://img.shields.io/reuse/compliance/github.com/janderssonse/homebrew-avtools)

# Homebrew AVTools

A brew tap for assorted audio and video tools in use at SVT, mainly for encoding purposes.

Currently this tap holds minor modifications of existing core Homebrew formulas  - FFmpeg and codecs, but also formulas for a few of the [FFmpeg filters released by SVT](https://github.com/svt/ffmpeg-filter-proxy)

* ffmpeg-encore - FFmpeg tailored for encore, with x264, x265, [ffmpg-filter-proxy support](https://github.com/svt/ffmpeg-filter-proxy)
* libsrf-proxy-filter -  [Subtitle Rendering Format filter](https://github.com/svt/ffmpeg-filter-proxy-filters)
* libsvg-proxy-filter - [SVG filter](https://github.com/svt/ffmpeg-filter-proxy-filters)
* x264-encore - [x264 encoder lib](https://code.videolan.org/videolan/x264.git)
* x265-encore - [x265 encoder lib](https://bitbucket.org/multicoreware/x265_git)


## Dependencies

- [Brew](https://brew.sh/)

## Installation & Usage

There are a few options. 

You can use the pre-built Docker Image, build your own Docker Image from the Dockerfile, or add the Brew tap and build it on your machine.


### Install Brew tap

- Add the tap to your Brew tap configuration, and install the tools you wish

```console
$ brew tap svt/avtools 
```

- Optional: For more info about the tap you could use (example uses [jq](https://stedolan.github.io/jq/)

```console
$ brew tap-info svt/avtools --json | jq
```

- Example install

```console
$ brew install ffmpeg-encore
```

### With Docker

#### Test the pre-built Docker Image

_**This image is only intended for development and not production usage. It contains the taps version of FFmpeg. 
Notably, compared to the Formula/ffmpeg-encore does *excludes* the GPL-incompatible library fdk-aac** (but use aac instedI)_

[avtools-osadl-debian](https://github.com/janderssonse?tab=packages&repo_name=homebrew-avtools), 


#### Building your own Dockerimage


You can also build you own Docker Image using the included Dockerfile. 

Use of [Docker buildx](https://docs.docker.com/buildx/working-with-buildx/) is assumed

_Example, located in the project root, using buildx, building the distribution image for the linux/amd64 platform, without the fdk-aac library_

```console
$ docker build --target=distribution --platform linux/amd64 --build-arg=FFMPEG_BREW_OPTIONS=--without-fdk-aac . -f docker/Dockerfile.osadl.debian
```

Available build targets are:

* buildimage
* distribution
* source

Default: If you dont give a --target you will build the distribution image as default - but also all other targets, so set the target, you want to avoid the source target if you don't need it.

Brew Options through the Docker build:

* To build the FFmepg forumla without fdk-aac you could pass the --build-arg FFMPEG_BREW_OPTIONS=--without-fdk-aac


**NOTE: If you build your own Docker Image for anything else than internal use, you have to consider how the third party dependencies interact, if you want to avoid building an un-distributable image.
A notable example is that you can't include the fdk-aac library together with x264,x265 in the same build, as the fdk-aac license is currently GPL-incompatible.**

## Configuration

Currently, the configurations options are few - this might change in the future.

## Known issues

* The Docker Images could be smaller if it used Alpine, and was optimized regarding dependencies

* The build uses some libraries installed through apt, so we are *not* in the Brew eco system totally - in other words, all dependecies used for the avvideo tools are not found in Brew repos, most notably glibc. Run ffmpeg with ldd to see a list.
 
* Auditing the Formulas still gives a few warnings, *feel free to fix them.*
To audit them all, from the project's root folder you can run

```console
$ for f in Formula/*.rb; do echo "Processing $f file.."; eval "brew audit --new --formula $f"; done
```

* The Formulas is not yet keg_only, which could allow to have multiple instances/versions

## Getting help

If you have questions, concerns, bug reports, etc, please file an issue in [this repository's Issue Tracker](https://github.com/svt/homebrew-avtools)

## Getting involved

See [CONTRIBUTING](CONTRIBUTING.adoc)

----

## License

### FORMULAS

- The Formulas in this project is all released under the [BSD 2-clause "Simplified" License](LICENSE)

- The Formulas FFmpeg-encore, x264-encore, x264-encore is built on Brew formulas, formulas themselves released under the same BSD-2 License, but also Copyright 2009-present, Homebrew contributors besides SVT.

### NOTE ABOUT THE FFMPEG FORMULA BUILD BINARY RESULTS

The binaries the Formulas will *build* is released under various other licenses, depending on your build options. 
See the different projects homepages and the license metadata in the docker/misc/LICENSE_THIRD_PARTIES.txt for some guidance to make an informed decision if you intend to distribute any built binaries further. 

### PRE-BUILT DOCKER IMAGE LICENSE

The Docker Image avtools-osadl-debian image is built on the [OSADL](https://www.osadl.org/OSADL-Docker-Base-Image.osadl-docker-base-image.0.html ) Debian base image.

The FFmpeg binary compiled in avtools-osadl-debian is released as under GPLv3 due to being the least common distrubutable license combination. 

A corresponding image [avtools-osadl-debian-source-image](https://github.com/janderssonse?tab=packages&repo_name=homebrew-avtools) contains corresponding source and license information for the libraries used.

_We aim to follow best practices for license compliance, however, if you find something we missed or even plain errors, please let us know so that we can improve this as soon as possible._

----

## Primary Maintainer

[The Videocore team at SVT](https://github.com/orgs/svt/teams/videocore)

## Credits and references

To many to mention, the list would be endless here, but a sincerly thanks to projects big or small making this repo possible.

