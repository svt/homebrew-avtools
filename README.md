# Homebrew AVTools

A brew tap for assorted audio and video tools in use at SVT, mainly for encoding purposes.
Currently this tap holds minor modifications of existing core Homebrew formulas  - ffmpeg and codecs, but also formulas for a few of the [FFmpeg filters released by SVT](https://github.com/svt/ffmpeg-filter-proxy)

* ffmpeg-encore - FFmpeg tailored for encore, with x264, x265, [ffmpg-filter-proxy support](https://github.com/svt/ffmpeg-filter-proxy)
* libsrf-proxy-filter -  [Subtitle Rendering Format filter](https://github.com/svt/ffmpeg-filter-proxy-filters)
* libsvg-proxy-filter - [SVG filter](https://github.com/svt/ffmpeg-filter-proxy-filters)
* x264-encore - [x264 encoder lib](https://code.videolan.org/videolan/x264.git)
* x265-encore - [x265 encoder lib](https://bitbucket.org/multicoreware/x265_git)

## Dependencies

- [Brew](https://brew.sh/)

## Installation & Usage

There are a few options. 

You can use the prebuilt docker-image, build your own docker image or add the Brew tap.

### Docker

You can use the prebuilt Docker image or build your own.

The prebuilt Docker image is available at [avtools-debian]() 

### Building your own Dockerimage

You can also build you own Docker Image using the included Dockerfile

_Example, in root, using buildx, building for the linux/amd64 platform_

```console
$ docker buildx build --platform linux/amd64 . -f docker/Dockerfile.oasdl.debian
```
 


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

## Configuration

Currently, the configurations options are few - this might change in the future.

## Known issues

* The Docker Images could be smaller if it used Alpine, and was optimized regarding dependencies

* The build uses some libraries installed through Apt, so we are *not* in the Brew eco system totally - in other words, all dependecies used for the avvideo tools are not found in Brews. Run ffmpeg with ldd to see a list.
 
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

- The Formulas in this project is all released under the [BSD 2-clause "Simplified" License](LICENSE)

- The Formulas FFmpeg-encore, x264-encore, x264-encore is built on Brew formulas, released under the same BSD-2 License, but also Copyright 2009-present, Homebrew contributors besides SVT.

- However, Note that the binaries the Formulas will *build* is released under various other licenses, see the different projects homepages and the license metadata in the Formula for some guidance for making an informed decision if you intend to share any built binaries further, if you add things.

The Docker Image avtools-debian image is built on the [OSADL](https://www.osadl.org/OSADL-Docker-Base-Image.osadl-docker-base-image.0.html ) Debian image, wich contains license information and source code, see information.

- The FFmpeg binary compiled in avtools-ubuntu is enabling gpl and using third party libraries:
  - 264, 265 GPL (TODO).


----

## Primary Maintainer

[The Videocore team at SVT](https://github.com/orgs/svt/teams/videocore)

## Credits and references

To the great projects OSADL, FFmpeg, Brew, x264, x265 and many others we forgot.

