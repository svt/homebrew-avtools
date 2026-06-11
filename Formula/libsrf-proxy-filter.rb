# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsrfProxyFilter < Formula
  desc "FFmpeg proxy filter for subtitle rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/refs/tags/v1.1.tar.gz"
  sha256 "601d0e89e225e8147b365060f6f5bcbebb9d0b8b40967507829488200d27098c"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git", branch: "master"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libsrf-proxy-filter-1.1"
    sha256 cellar: :any, arm64_sequoia: "4eb8e3affdb450e81416b5899757ae0c85af3aea6ea457bd40a7a96d390216fe"
    sha256 cellar: :any, arm64_linux:   "c03d4be9f35440d075f6c373b2c393fb16d06160283f5e333aa78a19085ac7e9"
    sha256 cellar: :any, x86_64_linux:  "8bffe243ef34d129da07e117005d773883b086b881e8ae233bef56788219cd91"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"

  def install
    system "cargo", "build", "--lib", "--release", "--locked",
           "--jobs", ENV.make_jobs.to_s,
           "--manifest-path", "srf_filter/Cargo.toml"
    lib.install "srf_filter/target/release/#{shared_library("libsrf_filter")}"
  end

  test do
    assert_path_exists lib/shared_library("libsrf_filter")
  end
end
