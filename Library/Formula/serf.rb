require 'formula'

class Serf < Formula
  homepage 'http://code.google.com/p/serf/'
  url 'http://serf.googlecode.com/files/serf-1.3.2.tar.bz2'
  sha1 '90478cd60d4349c07326cb9c5b720438cf9a1b5d'

  bottle do
    revision 2
    sha1 '5f092dd8ed34ee7ac3d240ac4cfa6aea98d73f54' => :mavericks
    sha1 'dd64a99d05dd6949fec49d38ee2b5444520f5ef9' => :mountain_lion
    sha1 'b1295c46e6840494afbf25b54cb4ada81ea5274c' => :lion
  end

  option :universal
  option 'with-brewed-openssl', 'Include OpenSSL support via Homebrew'

  depends_on :libtool
  depends_on 'sqlite'
  depends_on 'scons' => :build
  depends_on 'openssl' if build.with? 'brewed-openssl'

  def install
    # SConstruct merges in gssapi linkflags using scons's MergeFlags,
    # but that discards duplicate values - including the duplicate
    # values we want, like multiple -arch values for a universal build.
    # Passing 0 as the `unique` kwarg turns this behaviour off.
    inreplace 'SConstruct', 'unique=1', 'unique=0'

    ENV.universal_binary if build.universal?
    # scons ignores our compiler and flags unless explicitly passed
    args = %W[PREFIX=#{prefix} GSSAPI=/usr CC=#{ENV.cc}
              CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}]
    args << "OPENSSL=#{Formula.factory('openssl').opt_prefix}" if build.with? 'brewed-openssl'
    system "scons", *args
    system "scons install"
  end
end
