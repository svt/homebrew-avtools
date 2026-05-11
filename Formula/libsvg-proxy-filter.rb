# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsvgProxyFilter < Formula
  desc "FFmpeg proxy filter for svg rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/refs/heads/caching.tar.gz"
  sha256 "81a3667d4b1ee39c8e3af8b4fc20bd48621eac7a8c323298d5f2613776aa5213"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git", branch: "master"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libsvg-proxy-filter-1.0.1"
    sha256 cellar: :any,                 big_sur:      "994433c54c6b615cf5261a0deeed176fc37679df93a9af51c6312316f9af1beb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d0c9e9f125efafe9e0c7fcf45e6cc6a4dedd8218535abadc2842a449726fe492"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"

  def install
    system "cargo", "build", "--lib", "--release", "--manifest-path", "svg_filter/Cargo.toml"
    if OS.mac?
      lib.install "svg_filter/target/release/libsvg_filter.dylib"
    else
      lib.install "svg_filter/target/release/libsvg_filter.so"
    end
  end

  test do
    print "TODO: tests\n"
  end
end
