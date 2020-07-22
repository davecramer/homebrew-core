class VulkanHeaders < Formula
  desc "Vulkan Header files and API registry"
  homepage "https://github.com/KhronosGroup/Vulkan-Headers"
  url "https://github.com/KhronosGroup/Vulkan-Headers/archive/v1.2.148.tar.gz"
  sha256 "fecaa9af5f7c4d85abdbbe2a63d4b8ebdf48a532e992710ba204d5dfa7513866"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    sha256 "a2dbd1467874f539b416aa5594069efdb1b7e9b64a96546d20d7a89c3d5c0b94" => :catalina
    sha256 "a2dbd1467874f539b416aa5594069efdb1b7e9b64a96546d20d7a89c3d5c0b94" => :mojave
    sha256 "a2dbd1467874f539b416aa5594069efdb1b7e9b64a96546d20d7a89c3d5c0b94" => :high_sierra
  end

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <vulkan/vulkan_core.h>

      int main() {
        printf("vulkan version %d", VK_VERSION_1_0);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-o", "test"
    system "./test"
  end
end
