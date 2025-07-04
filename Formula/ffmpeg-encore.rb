# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class FfmpegEncore < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  license "GPL-3.0-or-later"
  revision 1
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  stable do
    url "https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz"
    sha256 "733984395e0dbbe5c046abda2dc49a5544e7e0e1e2366bba849222ae9e3a03b1"

    # Backport support for recent svt-av1 (3.0.0)
    patch do
      url "https://github.com/FFmpeg/FFmpeg/commit/d1ed5c06e3edc5f2b5f3664c80121fa55b0baa95.patch?full_index=1"
      sha256 "0eb23ab90c0e5904590731dd3b81c86a4127785bc2b367267d77723990fb94a2"
    end
  end

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/ffmpeg-encore-7.1.1_1"
    sha256 arm64_sonoma: "e7cb8796bb2708666cc2deadaf3f92b5b0c59335f5941ba54b8bcea3dad432ab"
    sha256 x86_64_linux: "413ab02626c5b1ed74397d6dcc9335d7ddb9bf5a664af2ad57b49cbdea3201f1"
  end

  option "with-ffplay", "Enable ffplay"

  depends_on "pkgconf" => :build
  depends_on "aom"
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "harfbuzz"
  depends_on "lame"
  depends_on "libass"
  depends_on "libsoxr"
  depends_on "libssh"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "openjpeg"
  depends_on "openssl@3"
  depends_on "svt-av1"
  depends_on "x264"
  depends_on "x265"
  depends_on "xz"
  depends_on "zimg"
  depends_on "fdk-aac" => :recommended

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_intel do
    depends_on "nasm" => :build
  end

  conflicts_with "ffmpeg", because: "it also ships with ffmpeg binary"

  resource "proxy_filter" do
    url "https://github.com/svt/ffmpeg-filter-proxy/archive/refs/tags/v1.2.tar.gz"
    sha256 "9798759f589daaa0de3fc8a5d10002a384481a9daa2dc1f8a3dc323df4bdc578"
  end

  if build.with? "ffplay"
    on_linux do
      depends_on "libxv"
    end
    depends_on "sdl2"
  end

  def install
    # The new linker leads to duplicate symbol issue https://github.com/homebrew-ffmpeg/homebrew-ffmpeg/issues/140
    ENV.append "LDFLAGS", "-Wl,-ld_classic" if DevelopmentTools.clang_build_version >= 1500
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

    args << "--enable-libfdk-aac" if build.with? "fdk-aac"
    args << "--enable-ffplay" if build.with? "ffplay"
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
              "extern const AVFilter ff_vf_yadif;",
              "extern const AVFilter ff_vf_yadif;\nextern const AVFilter ff_vf_proxy;\n"
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
