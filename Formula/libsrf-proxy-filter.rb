# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsrfProxyFilter < Formula
  desc "FFmpeg proxy filter for subtitle rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "3b9f1ba0f9e21b6c2edd523fd954f24cdd241b71fb0d0f7ba1688a12ef55db26"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git", branch: "caching"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libsrf-proxy-filter-1.0.1"
    sha256 cellar: :any,                 big_sur:      "efeecdd2562cacffd138ad1f68b03f80212266e552c567b7ccba524f30e46e1e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8afd2d435b9cd30615495f5b2f15960faba5af81f871ea6b6e2d8c9424402ed4"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"

  def install
    # Pin a portable x86_64 baseline so source builds (e.g. on AMD hosts)
    # don't bake in SSE4a / AVX-only instructions and SIGILL on Intel runtimes.
    ENV["RUSTFLAGS"] = "-C target-cpu=x86-64" if Hardware::CPU.intel?
    system "cargo", "build", "--lib", "--release", "--locked",
           "--jobs", ENV.make_jobs.to_s,
           "--manifest-path", "srf_filter/Cargo.toml"
    lib.install "srf_filter/target/release/#{shared_library("libsrf_filter")}"
  end

  test do
    assert_path_exists lib/shared_library("libsrf_filter")
  end
end
