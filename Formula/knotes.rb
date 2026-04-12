class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  url "https://github.com/antoninbas/knotes/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "49cd2405d814b0578e43cecdf41dd69feb3270175b1022aabbfa5f1fb0914fe6"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install"
    cd "src/web/app" do
      system "bun", "install"
      system "bun", "run", "build"
    end

    libexec.install Dir["src", "package.json", "bun.lock", "node_modules"]
    # Frontend node_modules needed for the built assets path resolution
    (libexec/"src/web/app/node_modules").install Dir["src/web/app/node_modules/*"] if Dir.exist?("src/web/app/node_modules")

    (bin/"knotes").write <<~SH
      #!/bin/sh
      exec "#{Formula["oven-sh/bun/bun"].opt_bin}/bun" run "#{libexec}/src/main.ts" "$@"
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
