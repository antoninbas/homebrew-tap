class Knotes < Formula
  desc "Local-first note and activity log manager with hybrid search"
  homepage "https://github.com/antoninbas/knotes"
  url "https://github.com/antoninbas/knotes/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "f8259635c912aabcb03783e668abcb33de667df509d8740c88f4100b8276d1e4"
  license "MIT"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install"
    cd "src/web/app" do
      system "bun", "install"
      system "bun", "run", "build"
    end

    libexec.install Dir["src", "package.json", "bun.lock", "node_modules"]

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
