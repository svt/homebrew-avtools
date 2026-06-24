![REUSE Compliance](https://img.shields.io/reuse/compliance/github.com/svt/homebrew-avtools)

# Homebrew AVTools

A Homebrew tap for the audio and video tools used at SVT, primarily for encoding
and proxy/subtitle rendering.

The tap ships a build of FFmpeg tailored for [Encore](https://github.com/svt/encore)
together with the [FFmpeg filters released by SVT](https://github.com/svt/ffmpeg-filter-proxy),
plus the supporting libraries those filters need at runtime.

## Formulas

| Formula | Description |
| --- | --- |
| `ffmpeg-encore` | FFmpeg tailored for Encore, with x264, x265, SVT-AV1, fdk-aac, [ffmpeg-filter-proxy](https://github.com/svt/ffmpeg-filter-proxy) (`proxy` video filter) and the [`dnenhance`](https://github.com/svt/ffmpeg-filter-dnenhance) neural dialogue-enhancement audio filter built in. |
| `libsrf-proxy-filter` | [Subtitle Rendering Format filter](https://github.com/svt/ffmpeg-filter-proxy-filters) for the `proxy` filter. |
| `libsvg-proxy-filter` | [SVG filter](https://github.com/svt/ffmpeg-filter-proxy-filters) for the `proxy` filter. |
| `libdf` | [DeepFilterNet](https://github.com/Rikorose/DeepFilterNet) inference library (libDF, C ABI), loaded at runtime by the `dnenhance` filter in `ffmpeg-encore`. |

Pre-built bottles are published as GitHub releases for `arm64_sequoia` (Apple
Silicon macOS), `arm64_linux`, and `x86_64_linux`, so installation usually
needs no local compilation.

## Installation

Add the tap, then install the formulas you need:

```console
$ brew tap svt/avtools
$ brew install ffmpeg-encore
```

`ffmpeg-encore` conflicts with Homebrew core `ffmpeg` (both ship an `ffmpeg`
binary), so only one can be linked at a time.

For more info about the tap (example uses [jq](https://stedolan.github.io/jq/)):

```console
$ brew tap-info svt/avtools --json | jq
```

## Usage

### The `proxy` filter (SRF / SVG)

The `proxy` filter is compiled into `ffmpeg-encore` and loads a rendering
backend at runtime. Install the backend you need — `libsrf-proxy-filter` for
subtitles, `libsvg-proxy-filter` for SVG — and point the filter at the shared
library. See the
[ffmpeg-filter-proxy](https://github.com/svt/ffmpeg-filter-proxy) docs for the
full argument syntax.

```console
$ brew install libsrf-proxy-filter libsvg-proxy-filter
```

### Neural dialogue enhancement (`dnenhance`)

The `dnenhance` audio filter (from
[ffmpeg-filter-dnenhance](https://github.com/svt/ffmpeg-filter-dnenhance)) is
compiled into `ffmpeg-encore` and uses DeepFilterNet 3 via `libdf` at runtime.
Install `libdf` and run:

```console
$ brew install libdf
$ ffmpeg -i in.wav -af dnenhance out.wav
```

The filter auto-discovers `libdf` and the bundled DeepFilterNet 3 model from the
Homebrew prefix — no `DYLD_LIBRARY_PATH` or `model=` argument is required. To use
a different DFN3 variant, pass it explicitly:

```console
$ ffmpeg -i in.wav -af "dnenhance=model=/path/to/model.tar.gz" out.wav
```

## Getting help

For questions, bug reports, etc., please file an issue in
[this repository's issue tracker](https://github.com/svt/homebrew-avtools/issues).

## Getting involved

See [CONTRIBUTING](CONTRIBUTING.md).

---

## License

The formulas in this project are released under the
[BSD 2-Clause "Simplified" License](LICENSE). `ffmpeg-encore` is built on
Homebrew formulas, which are themselves released under the same BSD-2 license but
are also Copyright 2009-present, Homebrew contributors besides SVT.

### Note about FFmpeg build results

The binaries the formulas *build* are released under various licenses depending
on the source they pull in. The default `ffmpeg-encore` build enables
`--enable-gpl` and `--enable-nonfree` (it links fdk-aac), which produces a
**non-redistributable** binary. Consult the upstream project homepages before
distributing any built binaries.

_We aim to follow best practices for license compliance. If you find something
we missed, or plain errors, please let us know so we can fix it as soon as
possible._

---

## Primary maintainer

[The Videocore team at SVT](https://github.com/orgs/svt/teams/videocore)

## Credits and references

Too many to mention — but a sincere thanks to the projects big and small that
make this repo possible.
</content>
