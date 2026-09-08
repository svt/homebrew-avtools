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