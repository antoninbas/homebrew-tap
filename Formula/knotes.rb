class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/antoninbas/knotes/releases/download/v0.1.0/knotes-darwin-arm64.tar.gz"
      sha256 "46bbc4c99b95c315075c4657e7bbcebfa85bf46472e3f52470e21dc4ac2fc3cb"
    else
      url "https://github.com/antoninbas/knotes/releases/download/v0.1.0/knotes-darwin-x64.tar.gz"
      sha256 "cf7141ea1404a9f9515078e25e9c84db3df62d96487a127ef191a8ac41ba9867"
    end
  end

  on_linux do
    url "https://github.com/antoninbas/knotes/releases/download/v0.1.0/knotes-linux-x64.tar.gz"
    sha256 "4ee7df926d221dd09b7b3bd1111ab3c6866b5cc37f6b5aad0ee391b6e27a06d4"
  end

  def install
    if Hardware::CPU.arm? && OS.mac?
      bin.install "knotes-darwin-arm64" => "knotes"
    elsif OS.mac?
      bin.install "knotes-darwin-x64" => "knotes"
    else
      bin.install "knotes-linux-x64" => "knotes"
    end
  end

  test do
    assert_match "knotes", shell_output("#{bin}/knotes --help")
  end
end
