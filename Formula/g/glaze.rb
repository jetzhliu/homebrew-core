class Glaze < Formula
  desc "Extremely fast, in-memory JSON and interface library for modern C++"
  homepage "https://github.com/stephenberry/glaze"
  url "https://github.com/stephenberry/glaze/archive/refs/tags/v4.1.0.tar.gz"
  sha256 "2cb3e650a45738f7e7e67e35683ab0b91b7be1cf42f819f33f576ad86871a1fb"
  license "MIT"

  depends_on "cmake" => [:build, :test]

  on_macos do
    depends_on "llvm" => :build
  end

  on_linux do
    depends_on "llvm@18" => :build
  end

  fails_with :gcc do
    version "11"
    cause "Requires C++20"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 3.16)
      project(GlazeTest LANGUAGES CXX)

      set(CMAKE_CXX_STANDARD 20)
      set(CMAKE_CXX_STANDARD_REQUIRED ON)

      find_package(glaze REQUIRED)

      add_executable(glaze_test test.cpp)
      target_link_libraries(glaze_test PRIVATE glaze::glaze)
    CMAKE

    (testpath/"test.cpp").write <<~CPP
      #include <glaze/glaze.hpp>
      #include <map>
      #include <string_view>

      int main() {
          const std::string_view json = R"({"key": "value"})";
          std::map<std::string, std::string> data;
          auto result = glz::read_json(data, json);
          return (!result && data["key"] == "value") ? 0 : 1;
      }
    CPP

    system "cmake", "-S", ".", "-B", "build", "-Dglaze_DIR=#{share}/glaze"
    system "cmake", "--build", "build"
    system "./build/glaze_test"
  end
end
