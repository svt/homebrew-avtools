# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class FfmpegEncore < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.xz"
  sha256 "464beb5e7bf0c311e68b45ae2f04e9cc2af88851abb4082231742a74d97b524c"
  license "GPL-3.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/ffmpeg-encore-8.1.2"
    sha256 arm64_sequoia: "c417aeb293e241ad54c1a43b85e5e3a2739aa1e534e9b6c764cc4ba29ee78d64"
    sha256 arm64_linux:   "06b53e086216ae5ff6a9b089f353d7bd08dc146a3d01e93bafd5579b70ea03f9"
    sha256 x86_64_linux:  "7c0cc6efbf67c92dfaefb45574e620aa6ae900199d98a2761bfe124e1768eb79"
  end

  depends_on "pkgconf" => :build
  depends_on "aom"
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "lame"
  depends_on "libass"
  depends_on "libplacebo"
  depends_on "libsoxr"
  depends_on "libssh"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "libx11"
  depends_on "libxcb"
  depends_on "openjpeg"
  depends_on "openssl@3"
  depends_on "svt-av1"
  depends_on "x264"
  depends_on "x265"
  depends_on "xz"
  depends_on "zimg"
  # GPL-incompatible: forces --enable-nonfree (unredistributable), so keep it
  # opt-in and out of the default bottle.
  depends_on "fdk-aac" => :optional

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  on_intel do
    depends_on "nasm" => :build
  end

  conflicts_with "ffmpeg", because: "it also ships with ffmpeg binary"

  resource "proxy_filter" do
    url "https://github.com/svt/ffmpeg-filter-proxy/archive/refs/tags/v1.4.tar.gz"
    sha256 "fba9588e412efa3080ffcd6b3af07b50a99cecbc7356607b346cb0e28492c896"
  end

  resource "dnenhance_filter" do
    url "https://github.com/svt/ffmpeg-filter-dnenhance/archive/refs/tags/v1.0.tar.gz"
    sha256 "e46c49367f35fa95e1c1603efb9bd8877e237e4f0a74e8132286d1c1354b95bb"
  end

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.ld64_version.between?("1015.7", "1022.1")
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-gpl
      --enable-libaom
      --enable-libdav1d
      --enable-libmp3lame
      --enable-libvorbis
      --enable-libvpx
      --enable-libx264
      --enable-libx265
      --enable-libxml2
      --enable-lzma
      --enable-libass
      --enable-libfontconfig
      --enable-libfreetype
      --enable-libharfbuzz
      --enable-libplacebo
      --disable-libjack
      --disable-indev=jack
      --enable-openssl
      --enable-libopenjpeg
      --enable-libssh
      --enable-libvmaf
      --enable-libzimg
      --enable-libsvtav1
    ]

    args += %w[--enable-videotoolbox --enable-audiotoolbox] if OS.mac?
    args << "--enable-neon" if Hardware::CPU.arm?

    # Only enable fdk-aac on request: it's the sole nonfree library here and
    # makes the build unredistributable. The default stays clean GPLv3.
    if build.with?("fdk-aac")
      args << "--enable-libfdk-aac"
      args << "--enable-nonfree"
    end

    resource("proxy_filter").stage do |stage|
      @proxyfilterpath = Dir.pwd
      stage.staging.retain!
    end
    cp_r Dir.glob("#{@proxyfilterpath}/*.c"), "libavfilter", verbose: true
    inreplace "libavfilter/allfilters.c",
              "extern const FFFilter ff_vf_yadif;",
              "extern const FFFilter ff_vf_yadif;\nextern const FFFilter ff_vf_proxy;\n"
    inreplace "libavfilter/Makefile",
              "# video filters",
              "# video filters\nOBJS-$(CONFIG_PROXY_FILTER) += vf_proxy.o\n"

    # af_dnenhance: neural dialogue enhancement via DeepFilterNet 3 (libdf
    # is dlopen'd at runtime; no build-time dependency).
    resource("dnenhance_filter").stage do |stage|
      @dnenhancefilterpath = Dir.pwd
      stage.staging.retain!
    end
    cp_r Dir.glob("#{@dnenhancefilterpath}/*.c"), "libavfilter", verbose: true
    inreplace "libavfilter/allfilters.c",
              "extern const FFFilter ff_af_dialoguenhance;",
              "extern const FFFilter ff_af_dialoguenhance;\nextern const FFFilter ff_af_dnenhance;\n"
    inreplace "libavfilter/Makefile",
              "# audio filters",
              "# audio filters\nOBJS-$(CONFIG_DNENHANCE_FILTER) += af_dnenhance.o\n"

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  def caveats
    # Only warn when fdk-aac was actually compiled in. The default build (and
    # the bottle) is plain GPLv3, so it needs no caveat.
    return if build.without?("fdk-aac")

    <<~EOS
      This build includes the Fraunhofer FDK AAC encoder, so it enables
      --enable-nonfree and is NOT redistributable. Keep any artifacts
      containing it internal; do not publish bottles or images built this way.
    EOS
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_path_exists mp4out
  end
end
