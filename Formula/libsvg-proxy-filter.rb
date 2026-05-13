# SPDX-FileCopyrightText: 2021 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class LibsvgProxyFilter < Formula
  desc "FFmpeg proxy filter for svg rendering"
  homepage "https://github.com/SVT/ffmpeg-filter-proxy-filters"
  url "https://github.com/SVT/ffmpeg-filter-proxy-filters/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "3b9f1ba0f9e21b6c2edd523fd954f24cdd241b71fb0d0f7ba1688a12ef55db26"
  license "Apache-2.0"
  head "https://github.com/SVT/ffmpeg-filter-proxy-filters.git", branch: "caching"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libsvg-proxy-filter-1.0.1"
    sha256 cellar: :any,                 big_sur:      "994433c54c6b615cf5261a0deeed176fc37679df93a9af51c6312316f9af1beb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d0c9e9f125efafe9e0c7fcf45e6cc6a4dedd8218535abadc2842a449726fe492"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "cairo"

  def install
    # Pin a portable x86_64 baseline so source builds (e.g. on AMD hosts)
    # don't bake in SSE4a / AVX-only instructions and SIGILL on Intel runtimes.
    # Passing --target activates the matching [target.'cfg(...)'] block in the
    # filter repo's .cargo/config.toml (and isolates the artifact dir).
    triple = Utils.safe_popen_read("rustc", "-vV")[/^host: (.+)$/, 1]
    ENV["RUSTFLAGS"] = "-C target-cpu=x86-64" if triple.start_with?("x86_64")

    system "cargo", "build", "--lib", "--release", "--locked",
           "--target", triple,
           "--jobs", ENV.make_jobs.to_s,
           "--manifest-path", "svg_filter/Cargo.toml"
    lib.install "svg_filter/target/#{triple}/release/#{shared_library("libsvg_filter")}"
  end

  test do
    assert_path_exists lib/shared_library("libsvg_filter")
  end
end
