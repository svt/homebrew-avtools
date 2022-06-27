# SPDX-FileCopyrightText: 2009-present, Homebrew contributors
# SPDX-FileCopyrightText: 2022 Sveriges Television AB
#
# SPDX-License-Identifier: BSD-2-Clause
#

class Libmxf < Formula
  desc "Software library written by BBC Research to read and write MXF files"
  homepage "https://sourceforge.net/p/bmxlib/home/Home/"
  url "https://downloads.sourceforge.net/project/bmxlib/bmx-snapshot-20210707/bmx-snapshot-20210707.tar.gz"
  sha256 "425ec728213fd94ffc4f125b74c0597d19e210987d17ad8d7490e501a898ce5a"

  env :std

  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  on_linux do
    depends_on "util-linux"
  end

  def install
    Dir.chdir "libMXF"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-examples",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    print "TODO: tests\n"
  end
end
