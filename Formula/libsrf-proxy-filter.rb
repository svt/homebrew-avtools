# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsrfProxyFilter < Formula
  desc "FFmpeg proxy filter for subtitle rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/v1.0.1.tar.gz"
  sha256 "3b9f1ba0f9e21b6c2edd523fd954f24cdd241b71fb0d0f7ba1688a12ef55db26"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git"

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"
  depends_on "protobuf-c"

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
