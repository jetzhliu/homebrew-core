class Ortp < Formula
  desc "Real-time transport protocol (RTP, RFC3550) library"
  homepage "https://linphone.org/"
  license "GPL-3.0-or-later"

  stable do
    url "https://gitlab.linphone.org/BC/public/ortp/-/archive/5.3.63/ortp-5.3.63.tar.bz2"
    sha256 "597f106519ebc59f4d4a6ee971d42a2ddfc787a44e043128b6d15aa135722b61"

    # bctoolbox appears to follow ortp's version. This can be verified at the GitHub mirror:
    # https://github.com/BelledonneCommunications/bctoolbox
    resource "bctoolbox" do
      url "https://gitlab.linphone.org/BC/public/bctoolbox/-/archive/5.3.63/bctoolbox-5.3.63.tar.bz2"
      sha256 "4d86996367c72b8575a8a06e88e91724f762e8a004eed10280bf7301cf59c146"
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "3b399296b0218fc7263b5f478b22c884e00780842b1103617f246759bdbf8b52"
    sha256 cellar: :any,                 arm64_ventura:  "1cfd04bc081d3bf0e1d0ba7cc8fe6f0eca39f16877d6c442a5dc348e294de1fb"
    sha256 cellar: :any,                 arm64_monterey: "2fea94ea5915606aaf210d0e9cc82eb92585207171e63d50d4067061ff768e34"
    sha256 cellar: :any,                 sonoma:         "5f08119f84d0ef21ebefcd1a64d96d713af02c9654040de6c3e6132dcfc363c2"
    sha256 cellar: :any,                 ventura:        "d346672a722d2eaf5931a4e784439448f5c60cbda5648d21cb2a1cbdd0c1fdeb"
    sha256 cellar: :any,                 monterey:       "9e72e4dcc447b3f8e885e6a92e69b456a0f3b74986f7e7b476b15d7a5f28ede0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "cd9437d1b2f5adfcbc864bfa220e9b4843942df52da01716529377b814ddcd17"
  end

  head do
    url "https://gitlab.linphone.org/BC/public/ortp.git", branch: "master"

    resource "bctoolbox" do
      url "https://gitlab.linphone.org/BC/public/bctoolbox.git", branch: "master"
    end
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "mbedtls"

  def install
    odie "bctoolbox resource needs to be updated" if build.stable? && version != resource("bctoolbox").version

    resource("bctoolbox").stage do
      args = ["-DENABLE_TESTS_COMPONENT=OFF", "-DBUILD_SHARED_LIBS=ON"]
      args << "-DCMAKE_C_FLAGS=-Wno-error=unused-parameter" if OS.linux?
      system "cmake", "-S", ".", "-B", "build",
                      *args,
                      *std_cmake_args(install_prefix: libexec)
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    ENV.prepend_path "PKG_CONFIG_PATH", libexec/"lib/pkgconfig"
    ENV.append "LDFLAGS", "-Wl,-rpath,#{libexec}/lib" if OS.linux?
    cflags = ["-I#{libexec}/include"]
    cflags << "-Wno-error=maybe-uninitialized" if OS.linux?

    args = %W[
      -DCMAKE_PREFIX_PATH=#{libexec}
      -DCMAKE_C_FLAGS=#{cflags.join(" ")}
      -DCMAKE_CXX_FLAGS=-I#{libexec}/include
      -DBUILD_SHARED_LIBS=ON
      -DENABLE_DOC=NO
      -DENABLE_UNIT_TESTS=NO
    ]
    args << "-DCMAKE_INSTALL_RPATH=#{libexec}/Frameworks" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "ortp/logging.h"
      #include "ortp/rtpsession.h"
      #include "ortp/sessionset.h"
      int main()
      {
        ORTP_PUBLIC void ortp_init(void);
        return 0;
      }
    EOS
    linker_flags = OS.mac? ? %W[-F#{frameworks} -framework ortp] : %W[-L#{lib} -lortp]
    system ENV.cc, "test.c", "-o", "test", "-I#{include}", "-I#{libexec}/include", *linker_flags
    system "./test"
  end
end
