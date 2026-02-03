# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class FfmpegEncore < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-8.0.1.tar.xz"
  sha256 "05ee0b03119b45c0bdb4df654b96802e909e0a752f72e4fe3794f487229e5a41"
  license "GPL-3.0-or-later"
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/ffmpeg-encore-8.0.1"
    sha256 arm64_sequoia: "658a1218b9f8dd7996b3442803d3160dccacad4fe0f376d4c554ec7658763b63"
    sha256 x86_64_linux:  "8d3815ec534d2a48c219ee400ab4fd804a8454a3582d480842b986121b65ff95"
  end

  depends_on "pkgconf" => :build
  depends_on "aom"
  depends_on "dav1d"
  depends_on "fdk-aac"
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

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_intel do
    depends_on "nasm" => :build
  end

  conflicts_with "ffmpeg", because: "it also ships with ffmpeg binary"

  resource "proxy_filter" do
    url "https://github.com/svt/ffmpeg-filter-proxy/archive/refs/tags/v1.3.tar.gz"
    sha256 "c286192fa9e04ad17f10757d1c04291c3ea531316640736a3904fd8b86f6cbb8"
  end

  # Add svt-av1 4.x support
  patch do
    url "https://git.ffmpeg.org/gitweb/ffmpeg.git/patch/a5d4c398b411a00ac09d8fe3b66117222323844c"
    sha256 "1dbbc1a4cf9834b3902236abc27fefe982da03a14bcaa89fb90c7c8bd10a1664"
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
      --enable-libfdk-aac
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
      --enable-nonfree
      --enable-libsvtav1
    ]

    args += %w[--enable-videotoolbox --enable-audiotoolbox] if OS.mac?
    args << "--enable-neon" if Hardware::CPU.arm?

    # GPL-incompatible libraries, requires ffmpeg to build with "--enable-nonfree" flag, (unredistributable libraries)
    # Openssl IS GPL compatible since 3, but due to this patch
    # https://patchwork.ffmpeg.org/project/ffmpeg/patch/20200609001340.52369-1-rcombs@rcombs.me/
    # not being in this version we build from, we have to enable non-free anyway.
    # When FFmpeg base is upgraded (including that patch), we should only enable-nonfree when
    # fdk-aac is enabled (the default option)
    # args << "--enable-nonfree" if !build.without?("fdk-aac")

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

    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install (buildpath/"tools").children.select { |f| f.file? && f.executable? }
    pkgshare.install buildpath/"tools/python"
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_path_exists mp4out
  end
end
