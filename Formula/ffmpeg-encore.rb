# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class FfmpegEncore < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  license "GPL-3.0-or-later"
  revision 4
  head "https://github.com/FFmpeg/FFmpeg.git", branch: "master"

  stable do
    url "https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz"
    sha256 "57be87c22d9b49c112b6d24bc67d42508660e6b718b3db89c44e47e289137082"

    # Fix for binutils, remove with `stable` block on next release
    # https://www.linuxquestions.org/questions/slackware-14/regression-on-current-with-ffmpeg-4175727691/
    patch do
      url "https://github.com/FFmpeg/FFmpeg/commit/effadce6c756247ea8bae32dc13bb3e6f464f0eb.patch?full_index=1"
      sha256 "9800c708313da78d537b61cfb750762bb8ad006ca9335b1724dbbca5669f5b24"
    end
  end

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/ffmpeg-encore-6.0_4"
    sha256 big_sur:      "eabd026b89de9a8efffc0467a293ec653b4730c98318b732664dc46715535c76"
    sha256 x86_64_linux: "4325d46b538697164ac9653590a0ef7d152e4461801bc7e05deed548f686155d"
  end
  option "with-ffplay", "Enable ffplay"

  depends_on "pkg-config" => :build
  depends_on "aom"
  depends_on "dav1d"
  depends_on "fontconfig"
  depends_on "freetype"
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
  depends_on "x264-encore"
  depends_on "x265-encore"
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

  fails_with gcc: "5"

  resource "proxy_filter" do
    url "https://github.com/SVT/ffmpeg-filter-proxy/archive/v1.1.tar.gz"
    sha256 "13ec3e891aad01b36b8cbb61e7a604a86157265a2b0bc6fb111605a4b686071a"
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
    bin.install Dir["tools/*"].select { |f| File.executable? f }

    # Fix for Non-executables that were installed to bin/
    remove_dir bin/"python", force: true
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
