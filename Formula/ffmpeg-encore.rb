# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class FfmpegEncore < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-4.3.1.tar.xz"
  sha256 "ad009240d46e307b4e03a213a0f49c11b650e445b1f8be0dda2a9212b34d2ffb"
  license "GPL-3.0-or-later"
  revision 1
  head "https://github.com/FFmpeg/FFmpeg.git"

  option "with-ffplay", "Enable ffplay"

  depends_on "nasm" => :build
  depends_on "pkg-config" => :build
  depends_on "aom"
  depends_on "fdk-aac" => :recommended
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "lame"
  depends_on "libass"
  depends_on "libsoxr"
  depends_on "libssh"
  depends_on "libvmaf"
  depends_on "libvorbis"
  depends_on "libvpx"
  depends_on "openssl@3"
  depends_on "x264-encore"
  depends_on "x265-encore"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  conflicts_with "ffmpeg", because: "it also ships with ffmpeg binary"

  resource "proxy_filter" do
    url "https://github.com/SVT/ffmpeg-filter-proxy/archive/v1.0.tar.gz"
    sha256 "9a9ddfe248ea299ffa5bf9643bed95913f00b3a9d4e03f402aebc3224e4f82f3"
  end

  if build.with? "ffplay"
    depends_on "libxv" unless OS.mac?
    depends_on "sdl2"
  end

  def install

    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --enable-pthreads
      --enable-version3
      --enable-hardcoded-tables
      --enable-avresample
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --enable-gpl
      --enable-libaom
      --enable-libmp3lame
      --enable-libvorbis
      --enable-libvpx
      --enable-libx264
      --enable-libx265
      --enable-lzma
      --enable-libass
      --enable-libfontconfig
      --enable-libfreetype
      --disable-libjack
      --disable-indev=jack
      --enable-libaom
      --enable-openssl
      --enable-libssh
      --enable-libvmaf
      --enable-nonfree
    ]

    if !build.without? "fdk-aac"
      args << "--enable-libfdk-aac" 
    end
   
    args << "--enable-ffplay" if build.with? "ffplay"
    args << "--enable-videotoolbox" if OS.mac?
   
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
              "extern AVFilter ff_vf_yadif;",
              "extern AVFilter ff_vf_yadif;\nextern AVFilter ff_vf_proxy;\n"
    inreplace "libavfilter/Makefile",
              "# video filters",
              "# video filters\nOBJS-\$(CONFIG_PROXY_FILTER) += vf_proxy.o\n"
    
    system "./configure", *args
    system "make", "install"

    # Build and install additional FFmpeg tools
    system "make", "alltools"
    bin.install Dir["tools/*"].select { |f| File.executable? f }

    # Fix for Non-executables that were installed to bin/
    mv bin/"python", pkgshare/"python", force: true
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
