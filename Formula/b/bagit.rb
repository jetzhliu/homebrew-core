class Bagit < Formula
  include Language::Python::Virtualenv

  desc "Library for creation, manipulation, and validation of bags"
  homepage "https://libraryofcongress.github.io/bagit-python/"
  url "https://files.pythonhosted.org/packages/e5/99/927b704237a1286f1022ea02a2fdfd82d5567cfbca97a4c343e2de7e37c4/bagit-1.8.1.tar.gz"
  sha256 "37df1330d2e8640c8dee8ab6d0073ac701f0614d25f5252f9e05263409cee60c"
  license "CC0-1.0"
  revision 1
  version_scheme 1
  head "https://github.com/LibraryOfCongress/bagit-python.git", branch: "master"

  livecheck do
    url :stable
    regex(%r{href=.*?/project/bagit/v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "dd3d0ccfed47a60b957217320af5f1d3ce5104909b591ae67a4096c332306497"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "60395129ac88a0d1a5e1d3c9772092d17a2645c202ee3b6969608c161315e9c1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "60395129ac88a0d1a5e1d3c9772092d17a2645c202ee3b6969608c161315e9c1"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "60395129ac88a0d1a5e1d3c9772092d17a2645c202ee3b6969608c161315e9c1"
    sha256 cellar: :any_skip_relocation, sonoma:         "ea57458604d5bba0379d762de56d85f04f6485a285a99707b0ee5989d4747263"
    sha256 cellar: :any_skip_relocation, ventura:        "da64b9f36df90101ccf6702a55206eb9309d0ce2dcbc33722f3c709d00a87ec8"
    sha256 cellar: :any_skip_relocation, monterey:       "da64b9f36df90101ccf6702a55206eb9309d0ce2dcbc33722f3c709d00a87ec8"
    sha256 cellar: :any_skip_relocation, big_sur:        "da64b9f36df90101ccf6702a55206eb9309d0ce2dcbc33722f3c709d00a87ec8"
    sha256 cellar: :any_skip_relocation, catalina:       "da64b9f36df90101ccf6702a55206eb9309d0ce2dcbc33722f3c709d00a87ec8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "dc9585e81bfa176935a810e61cedbcddb08e5f82e96ae24496d1d11ad6e0f318"
  end

  depends_on "python@3.12"

  # Replace pkg_resources with importlib
  # https://github.com/LibraryOfCongress/bagit-python/pull/170
  patch do
    url "https://github.com/LibraryOfCongress/bagit-python/commit/de842aad182c74de21d09d108050740affb94f2e.patch?full_index=1"
    sha256 "f7fab3dead0089f44e6e65930a267f6d69f2589845e9ea4c1d6bbb3847f5ff3a"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system "#{bin}/bagit.py", "--source-organization", "Library of Congress", testpath.to_s
    assert_predicate testpath/"bag-info.txt", :exist?
    assert_predicate testpath/"bagit.txt", :exist?
    assert_match "Bag-Software-Agent: bagit.py", File.read("bag-info.txt")
    assert_match "BagIt-Version: 0.97", File.read("bagit.txt")

    assert_match version.to_s, shell_output("#{bin}/bagit.py --version")
  end
end
