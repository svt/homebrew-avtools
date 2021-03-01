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

Auditing the Formulas still gives a few warnings, *feel free to fix them.*
To audit them all, from the project's root folder you can run

```console
$ for f in Formula/*.rb; do echo "Processing $f file.."; eval "brew audit --new --formula $f"; done
```

The Formulas is not yet keg_only, which could allow to have multiple instances/versions

## Getting help

If you have questions, concerns, bug reports, etc, please file an issue in [this repository's Issue Tracker](https://github.com/svt/homebrew-avtools)

## Getting involved

See [CONTRIBUTING](CONTRIBUTING.adoc)

----

## License

- The Formulas in this project is all released under the [BSD 2-clause "Simplified" License](LICENSE)

- The Formulas FFmpeg-encore, x264-encore, x264-encore is built on Brew formulas, released under the same BSD-2 License, but also Copyright 2009-present, Homebrew contributors besides SVT.

- However, Note that the binaries the Formulas will *build* is released under various other licenses, see the different projects homepages and the license metadata in the Formula for some guidance for making an informed decision if you intend to share any built binaries further.

----

## Primary Maintainer

[The Videocore team at SVT](https://github.com/orgs/svt/teams/videocore)

## Credits and references

To the great projects FFmpeg, Brew, x264, x265 and many others we forgot.

