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

Pre-built bottles are published as GitHub releases for Apple Silicon macOS and
for Linux (`arm64` and `x86_64`), so installation usually needs no local
compilation.

## Patches

The `ffmpeg-encore` formula applies a small set of local FFmpeg patches from
[`patches/`](patches/). They are kept minimal and each is intended for
upstreaming; the list below says what each one fixes and why it is carried
here in the meantime.

| Patch | What it fixes |
| --- | --- |
| [`sidechaincompress_eof_guard.patch`](patches/sidechaincompress_eof_guard.patch) | `sidechaincompress` forwarded input EOF without checking its own buffered samples, so a slow sidechain producer (e.g. `dnenhance` draining its lookahead at EOF) could lose its trailing output — audible as a truncated enhanced-audio track under heavy parallel filtergraph load. The guard forwards status only once the filter's own fifo for that input is drained, matching what other dual-input filters already do. |
| [`dnxhdenc-fast-ratecontrol.patch`](patches/dnxhdenc-fast-ratecontrol.patch) | The DNxHD encoder's fast rate control could raise a macroblock's qscale twice while sizing it once, and since DNxHD's VLC coding of large coefficients is not monotonic in qscale, an encoded slice could outgrow its reserved space and abort on the `put_bits` assertion. The patch stops at the qscale the rate search already verified and does an exact size check instead, returning an error code rather than crashing. Contributes to [FFmpeg trac #9844](https://trac.ffmpeg.org/ticket/9844). |

Patches live in this repository and are referenced with `file://#{__dir__}`
URLs, so the formula and its patches stay versioned together.

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

The default `ffmpeg-encore` build is **GPLv3** (it links GPL libraries such as
x264 and x265 via `--enable-gpl`) and is redistributable — this is what the
pre-built bottle ships.

Building with `--with-fdk-aac` adds the Fraunhofer FDK AAC encoder, which is
GPL-incompatible and forces `--enable-nonfree`. FFmpeg marks such builds as
**unredistributable**, so that binary must not be distributed (keep any
artifacts containing it internal). It is only ever produced by an explicit
source build, never by the bottle:

```console
$ brew install --with-fdk-aac ffmpeg-encore
```

See [FFmpeg's LICENSE.md](https://github.com/FFmpeg/FFmpeg/blob/master/LICENSE.md)
for the authoritative details.

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
