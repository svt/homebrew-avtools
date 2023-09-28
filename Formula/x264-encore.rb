# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause
#

class X264Encore < Formula
  desc "H.264/AVC encoder"
  homepage "https://www.videolan.org/developers/x264.html"
  license "GPL-2.0-only"
  head "https://code.videolan.org/videolan/x264.git", branch: "master"

  stable do
    # the latest commit on the stable branch
    url "https://code.videolan.org/videolan/x264.git",
        revision: "baee400fa9ced6f5481a728138fed6e867b0ff7f"
    version "r3095"
  end

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/x264-encore-r3095"
    sha256 cellar: :any,                 big_sur:      "5da638265fba821ba32610b123604fef909d924a6ebc67a17c206900541d426d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4887c0820dcafb7d3a5e6ea597d8df85a9fde23e38f394e0a61875aa26b11e8d"
  end

  on_macos do
    depends_on "gcc" if DevelopmentTools.clang_build_version <= 902
  end

  on_intel do
    depends_on "nasm" => :build
  end

  conflicts_with "x264", because: "it comes with the same binary"

  # https://code.videolan.org/videolan/x264/-/commit/b5bc5d69c580429ff716bafcd43655e855c31b02
  fails_with :clang do
    build 902
    cause "Stack realignment requires newer Clang"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-lsmash
      --disable-swscale
      --disable-ffms
      --enable-shared
      --enable-static
      --enable-strip
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_match version.to_s.delete("r"), shell_output("#{bin}/x264 --version").lines.first
    (testpath/"test.c").write <<~EOS
      #include <stdint.h>
      #include <x264.h>

      int main()
      {
          x264_picture_t pic;
          x264_picture_init(&pic);
          x264_picture_alloc(&pic, 1, 1, 1);
          x264_picture_clean(&pic);
          return 0;
      }
    EOS
    system ENV.cc, "-L#{lib}", "test.c", "-lx264", "-o", "test"
    system "./test"
  end
end
