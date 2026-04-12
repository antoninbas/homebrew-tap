class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/antoninbas/knotes/releases/download/v0.2.0/knotes-darwin-arm64.tar.gz"
      sha256 "86e13df1891cab98ee34da0845aa95fc4c0c2e419e01bbb6a2fa5d7a6de8a9fb"
    else
      url "https://github.com/antoninbas/knotes/releases/download/v0.2.0/knotes-darwin-x64.tar.gz"
      sha256 "2b8007d94cce86af0423b54b90224ebc262cf4cf0d585e31fa5feb443a39d70e"
    end
  end

  on_linux do
    url "https://github.com/antoninbas/knotes/releases/download/v0.2.0/knotes-linux-x64.tar.gz"
    sha256 "153dd0b014e73c17036c88ee2d19497c32dd0f351fe7f109af6e1a3c8c01a7f1"
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
