# SPDX-FileCopyrightText: 2026 Sveriges Television AB
#
# SPDX-License-Identifier: Apache-2.0

# Copied from homebrew-core (last revision 6ffdcc9f95, removed there
# 2026-09-06 by core's license policy) so --with-fdk-aac ffmpeg-encore
# keeps resolving. The library itself is Apache-2.0 — bottling it is fine;
# only ffmpeg binaries linked against it are nonfree (see ffmpeg-encore's
# caveat).
class FdkAac < Formula
  desc "Standalone library of the Fraunhofer FDK AAC code from Android"
  homepage "https://sourceforge.net/projects/opencore-amr/"
  url "https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.3.tar.gz"
  sha256 "829b6b89eef382409cda6857fd82af84fabb63417b08ede9ea7a553f811cb79e"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/svt/homebrew-avtools/releases/download/fdk-aac-2.0.3"
    sha256 cellar: :any, arm64_tahoe:  "62719712e724eb486a04d20e16ef62090b713cc392c8cecc1faa04ee96196141"
    sha256 cellar: :any, arm64_linux:  "63a87b8de9c3b9df48eb13905d0dc6a36a7ca6fab8cccb43deb40b0f0d5967a2"
    sha256 cellar: :any, x86_64_linux: "291c00bbc1e89a8ef615ece4dbc784eebb437a09c82f3641eab0d1a4f1c01e0b"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-example"
    system "make", "install"
  end

  test do
    system bin/"aac-enc", test_fixtures("test.wav"), "test.aac"
    assert_path_exists testpath/"test.aac"
  end
end
