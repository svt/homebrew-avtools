# SPDX-FileCopyrightText: 2026 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause

class Libdf < Formula
  desc "DeepFilterNet inference library (libDF) with C ABI"
  homepage "https://github.com/Rikorose/DeepFilterNet"
  # Upstream Rikorose/DeepFilterNet has had no commits since 2024-09-25 and
  # looks de facto unmaintained. If the repo ever disappears or we hit a
  # rustc/build issue we can't sidestep, active community forks include
  # grazder/DeepFilterNet (the largest, with its own forks) and
  # KaleyraVideo/DeepFilterNet (a corporate fork shipping in production).
  # The C ABI we depend on is just six functions, so swapping the source
  # in this formula is mostly a URL + sha256 change.
  #
  # Pinned to a specific main commit (d375b2d) as the deliberate stable
  # base. The most recent tagged release, v0.5.6, cannot be used because:
  # (a) its libDF/Cargo.toml lacks the `crate-type = ["cdylib", ...]`
  # declaration, so cargo only produces an .rlib; (b) its Cargo.lock pins
  # an outdated `time` crate that no longer compiles on current rustc.
  # Both issues are fixed on main. Given the upstream silence noted above,
  # treat the SHA pin as the long-term posture rather than a placeholder —
  # bump it only when there's a concrete reason (new release, fork
  # migration, or a needed fix).
  url "https://github.com/Rikorose/DeepFilterNet/archive/d375b2d8309e0935d165700c91da9de862a99c31.tar.gz"
  version "0.5.6+d375b2d"
  sha256 "49471f3633a24c097d82f3b0d2dbd83a0c1bac3e2f6f6c9a675ef0020ebe5c51"
  license "MIT"
  head "https://github.com/Rikorose/DeepFilterNet.git", branch: "main"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/libdf-0.5.6+d375b2d"
    sha256 cellar: :any, arm64_sequoia: "78a40df4427bc74f7fff5109a406b3f966a39ae4fc8bc14c428462d041604c70"
    sha256 cellar: :any, arm64_linux:   "fc0a30ff15302f140bedc829870cfe967323ec620fa0488c7d2307131db1f257"
    sha256 cellar: :any, x86_64_linux:  "d606e1d544afbde345e68ae84088a87f4e4da7e40a13964daac1ca97185cd7f8"
  end

  depends_on "rust" => :build

  def install
    # Build libDF with the C API enabled and the `tract` ONNX backend
    # (pure Rust, no native deps).
    #
    # Note on the `default-model` feature: libDF's Cargo.toml declares
    #   capi = ["tract", "default-model", "dep:ndarray"]
    # so default-model is a transitive dependency of capi and can't be
    # dropped without patching upstream. It embeds the ~8 MB DFN3 ONNX
    # tarball into libdf.dylib via include_bytes!, reachable only from
    # Rust via DfParams::default() — NOT from the C API. Our C callers
    # (af_dnenhance) go through df_create(path, ...), which always reads
    # the tarball from disk (libDF/src/capi.rs:83 → tract.rs:30, calls
    # File::open(tar_file)).
    #
    # Net effect: ~8 MB of dead weight inside libdf.dylib that our usage
    # never reads. We still must install the standalone DFN3 tarball to
    # pkgshare because that's what the C API actually opens. Living with
    # the dead weight is easier than carrying a Cargo.toml patch.
    system "cargo", "build", "--lib", "--release",
           "--jobs", ENV.make_jobs.to_s,
           "-p", "deep_filter",
           "--features", "capi,tract,default-model"

    lib.install "target/release/#{shared_library("libdf")}"
    pkgshare.install "models/DeepFilterNet3_onnx.tar.gz" => "DeepFilterNet3.tar.gz"
  end

  def caveats
    <<~EOS
      Use libdf with the af_dnenhance FFmpeg filter (ffmpeg-encore):
        ffmpeg -i in.wav -af dnenhance out.wav

      af_dnenhance auto-discovers libdf.dylib from this prefix and the
      DFN3 model installed at:
        #{opt_pkgshare}/DeepFilterNet3.tar.gz
      No DYLD_LIBRARY_PATH or `model=` argument needed.

      To use a different DFN3 variant (e.g. the low-latency model), pass
      it explicitly:
        ffmpeg -i in.wav -af "dnenhance=model=/path/to/model.tar.gz" out.wav
    EOS
  end

  test do
    assert_path_exists lib/shared_library("libdf")
    assert_path_exists pkgshare/"DeepFilterNet3.tar.gz"
    # Confirm the C ABI symbols we depend on are exported.
    output = if OS.mac?
      shell_output("nm -gU #{lib}/#{shared_library("libdf")}")
    else
      shell_output("nm -gD #{lib}/#{shared_library("libdf")}")
    end
    %w[df_create df_get_frame_length df_process_frame
       df_set_atten_lim df_set_post_filter_beta df_free].each do |sym|
      assert_match sym, output
    end
  end
end
