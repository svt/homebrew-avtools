# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsvgProxyFilter < Formula
  desc "FFmpeg proxy filter for svg rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/refs/tags/v1.1.tar.gz"
  sha256 "601d0e89e225e8147b365060f6f5bcbebb9d0b8b40967507829488200d27098c"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git", branch: "master"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libsvg-proxy-filter-1.1"
    sha256 cellar: :any, arm64_sequoia: "9fd0599174b6820e60658342b5b24809b09b72314278a935665c4e3c866928a3"
    sha256 cellar: :any, arm64_linux:   "c8331f8a24d36b9ea495314282ae34ee736fbe47250c0a2095cb73fa8cf5ca14"
    sha256 cellar: :any, x86_64_linux:  "d9708adae8d9c6a056c9c74994a29adb39f8259101e6bb4a412bdce39df9b499"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"

  def install
    system "cargo", "build", "--lib", "--release", "--locked",
           "--jobs", ENV.make_jobs.to_s,
           "--manifest-path", "svg_filter/Cargo.toml"
    lib.install "svg_filter/target/release/#{shared_library("libsvg_filter")}"
  end

  test do
    assert_path_exists lib/shared_library("libsvg_filter")
  end
end
