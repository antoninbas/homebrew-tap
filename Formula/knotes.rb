class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  url "https://github.com/antoninbas/knotes/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "8ab8c7e320a8e78c30fe075c97370eccd20a474278cb7a419bbf81a05db98295"
  license "MIT"

  depends_on "node"

  def install
    # Skip node-llama-cpp binary download (done lazily on first use of `knotes embed`)
    ENV["NODE_LLAMA_CPP_SKIP_DOWNLOAD"] = "1"
    # Point node-gyp to local Node.js headers so better-sqlite3 compiles without network access
    ENV["npm_config_nodedir"] = Formula["node"].opt_prefix.to_s

    system "npm", "install"
    cd "src/web/app" do
      system "npm", "install"
      system "npx", "vite", "build"
    end
    system "npm", "run", "build"
    system "npm", "prune", "--omit=dev"

    libexec.install "dist", "node_modules", "package.json"

    (bin/"knotes").write <<~SH
      #!/bin/sh
      KNOTES_BIN="#{bin}/knotes"
      export KNOTES_BIN
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/dist/main.js" "$@"
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
