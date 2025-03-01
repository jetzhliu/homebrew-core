class Streamripper < Formula
  desc "Separate tracks via Shoutcasts title-streaming"
  homepage "https://streamripper.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/streamripper/streamripper%20%28current%29/1.64.6/streamripper-1.64.6.tar.gz"
  sha256 "c1d75f2e9c7b38fd4695be66eff4533395248132f3cc61f375196403c4d8de42"
  license "GPL-2.0-or-later"
  revision 2

  livecheck do
    url :stable
    regex(%r{url=.*?/streamripper[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia:  "c7c22401f41f85bd6bc51a741220de73a0a9d327ceb356f7ec2ef90c32298c81"
    sha256 cellar: :any,                 arm64_sonoma:   "064b8506ad4e3c3c313dd10fd5874c5270ba23ac723b24320dae84006d8abbe1"
    sha256 cellar: :any,                 arm64_ventura:  "1f53d313f817d1193b5622b6bf8294cf33438cab5318882ae2d697c09de13ccf"
    sha256 cellar: :any,                 arm64_monterey: "191660118509494bd8a3a584956da6edfe82ac9f5c95b7f41a4914c8e8bfe4a8"
    sha256 cellar: :any,                 arm64_big_sur:  "233eb2016447acf712f7b440c482879631048d02310509072664fb1d9bda6370"
    sha256 cellar: :any,                 sonoma:         "790ed39078914325c46947614b3304e8222a1b5a5849a005e037d698ef2ca641"
    sha256 cellar: :any,                 ventura:        "3d9f776cc673235764c30fa0937ae919d6beb3f46e41f039fea131e31e39fb8f"
    sha256 cellar: :any,                 monterey:       "620a45816eac20426e21ae85cb615439b6a32401a5e51acf6cff858b61b6905e"
    sha256 cellar: :any,                 big_sur:        "9e5398bff6bf329bd9652326511058bc092b30f274587779a23fd0f9cf212d2c"
    sha256 cellar: :any,                 catalina:       "07388ebb695754c780d14ddeb56cbe171eecbcc0bc8251dd0b353825f8c3155a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ebe33322f4bca7c998f76446b9c10988c7c058ba02bf0aedbbec87b0a9861a38"
  end

  depends_on "pkgconf" => :build
  depends_on "glib"
  depends_on "mad"

  on_macos do
    depends_on "gettext"
  end

  def install
    # the Makefile ignores CPPFLAGS from the environment, which
    # breaks the build when HOMEBREW_PREFIX is not /usr/local
    ENV.append_to_cflags ENV.cppflags if ENV.cppflags.present?

    # Work around error: call to undeclared library function 'strcpy'.
    # Ref: https://sourceforge.net/p/streamripper/code/ci/master/tree/lib/argv.c#l33
    ENV.append_to_cflags "-DANSI_PROTOTYPES=1" if DevelopmentTools.clang_build_version >= 1403

    # remove bundled libmad
    rm_r(buildpath/"libmad-0.15.1b")

    chmod 0755, "./install-sh" # or "make install" fails

    system "./configure", *std_configure_args
    system "make", "install"
  end

  test do
    system bin/"streamripper", "--version"
  end
end
