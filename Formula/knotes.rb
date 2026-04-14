class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  license "MIT"

  # NOTE: Starting from the next release, knotes is distributed as pre-packaged
  # macOS tarballs built by CI. Native modules (better-sqlite3) are compiled on
  # real macOS hardware in CI so that Homebrew's sandbox doesn't need network
  # access during installation.
  #
  # TODO: Replace the placeholder sha256 values below with the real checksums
  # once the CI jobs produce the tarballs for the next release.
  # Run: ./scripts/update-formula.sh vX.Y.Z /path/to/homebrew-tap
  on_arm do
    url "https://github.com/antoninbas/knotes/releases/download/v0.5.2/knotes-0.5.2-darwin-arm64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  on_intel do
    url "https://github.com/antoninbas/knotes/releases/download/v0.5.2/knotes-0.5.2-darwin-x64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  # Node is still required because tsx (bundled in node_modules) runs on Node.js
  depends_on "node"

  def install
    # Tarballs are pre-packaged by CI with native modules already compiled and
    # the frontend already built. No npm install or compilation needed here.
    libexec.install Dir["*"]

    (bin/"knotes").write <<~SH
      #!/bin/sh
      exec "#{libexec}/node_modules/.bin/tsx" "#{libexec}/src/main.ts" "$@"
    SH
  end

  service do
    run [bin/"knotes", "server"]
    keep_alive true
    log_path var/"log/knotes.log"
    error_log_path var/"log/knotes.log"
  end

  def caveats
    <<~EOS
      To start knotes as a background service:
        brew services start knotes

      Or use the built-in service manager:
        knotes service install

      The server runs on port 7713 by default (configurable with `knotes config set webPort <port>`).

      Data is stored in ~/.knotes by default. To use a custom directory,
      set KNOTES_HOME in your shell profile:
        export KNOTES_HOME=/path/to/data
    EOS
  end

  test do
    assert_match "knotes", shell_output("#{bin}/knotes --help")
  end
end
