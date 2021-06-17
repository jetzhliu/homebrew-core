class Tmuxp < Formula
  include Language::Python::Virtualenv

  desc "Tmux session manager. Built on libtmux"
  homepage "https://tmuxp.git-pull.com/"
  url "https://files.pythonhosted.org/packages/0d/96/6e7273db2d316f31f0df294a3040521c4542298f13a865018a51a61c92ca/tmuxp-1.9.1.tar.gz"
  sha256 "d5a81e323bcf2572a75c344af04f92a8feef5e3ebc309ae0436a756a754f2655"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "adb61801748cbfa449a90bc830a8146f307bd68411fb78182697ecd364722160"
    sha256 cellar: :any_skip_relocation, big_sur:       "3076ab1df50dfc4728aa05e667c57355a84dc862565684bd8dff462a00b49f85"
    sha256 cellar: :any_skip_relocation, catalina:      "ba9fa5dc41e15b4305725b695eb0b86abcf4e46d0b151772cfec58e07d808f70"
    sha256 cellar: :any_skip_relocation, mojave:        "e8641e8b91ce59d848918322b20e03856e729138b9da5f618f52d0272019bcff"
  end

  depends_on "python@3.9"
  depends_on "tmux"

  resource "click" do
    url "https://files.pythonhosted.org/packages/27/6f/be940c8b1f1d69daceeb0032fee6c34d7bd70e3e649ccac0951500b4720e/click-7.1.2.tar.gz"
    sha256 "d2b5255c7c6349bc1bd1e59e08cd12acbbd63ce649f2588755783aa94dfb6b1a"
  end

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/1f/bb/5d3246097ab77fa083a61bd8d3d527b7ae063c7d8e8671b1cf8c4ec10cbe/colorama-0.4.4.tar.gz"
    sha256 "5941b2b48a20143d2267e95b1c2a7603ce057ee39fd88e7329b0c292aa16869b"
  end

  resource "kaptan" do
    url "https://files.pythonhosted.org/packages/94/64/f492edfcac55d4748014b5c9f9a90497325df7d97a678c5d56443f881b7a/kaptan-0.5.12.tar.gz"
    sha256 "1abd1f56731422fce5af1acc28801677a51e56f5d3c3e8636db761ed143c3dd2"
  end

  resource "libtmux" do
    url "https://files.pythonhosted.org/packages/6d/a1/163e93ac885db77955f333663edf010c5f6fab3bd5e5f9aac639a917993f/libtmux-0.10.1.tar.gz"
    sha256 "c8bc81499616ba899538704e419463a1c83ba7ca21e53b1efc6abbe98eb26b61"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/a0/a4/d63f2d7597e1a4b55aa3b4d6c5b029991d3b824b5bd331af8d4ab1ed687d/PyYAML-5.4.1.tar.gz"
    sha256 "607774cbba28732bfa802b54baa7484215f530991055bb562efbed5b2f20a45e"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmuxp --version")

    (testpath/"test_session.yaml").write <<~EOS
      session_name: 2-pane-vertical
      windows:
      - window_name: my test window
        panes:
          - echo hello
          - echo hello
    EOS

    system bin/"tmuxp", "debug-info"
    system bin/"tmuxp", "convert", "--yes", "test_session.yaml"
    assert_predicate testpath/"test_session.json", :exist?
  end
end
