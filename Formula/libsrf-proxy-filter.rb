# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsrfProxyFilter < Formula
  desc "FFmpeg proxy filter for subtitle rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/refs/heads/caching.tar.gz"
  sha256 "81a3667d4b1ee39c8e3af8b4fc20bd48621eac7a8c323298d5f2613776aa5213"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git", branch: "master"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libsrf-proxy-filter-1.0.1"
    sha256 cellar: :any,                 big_sur:      "efeecdd2562cacffd138ad1f68b03f80212266e552c567b7ccba524f30e46e1e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8afd2d435b9cd30615495f5b2f15960faba5af81f871ea6b6e2d8c9424402ed4"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"

  def install
    system "cargo", "build", "--lib", "--release", "--manifest-path", "srf_filter/Cargo.toml"
    if OS.mac?
      lib.install "srf_filter/target/release/libsrf_filter.dylib"
    else
      lib.install "srf_filter/target/release/libsrf_filter.so"
    end
  end

  test do
    print "TODO: tests\n"
  end
end
