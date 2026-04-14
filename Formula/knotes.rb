class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  url "https://github.com/antoninbas/knotes/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "f885657917e86a8c119a792a0950715e50fb8925c3bedd5e3010305499c6dadf"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", "--production"
    cd "src/web/app" do
      system "npm", "install"
      system "npx", "vite", "build"
    end

    libexec.install Dir["src", "package.json", "package-lock.json", "node_modules"]
    # Frontend node_modules needed for the built assets path resolution
    (libexec/"src/web/app/node_modules").install Dir["src/web/app/node_modules/*"] if Dir.exist?("src/web/app/node_modules")

    (bin/"knotes").write <<~SH
      #!/bin/sh
      exec npx tsx "#{libexec}/src/main.ts" "$@"
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
