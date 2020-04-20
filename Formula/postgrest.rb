class Postgrest < Formula
  desc "Serves a fully RESTful API from any existing PostgreSQL database"
  homepage "https://github.com/PostgREST/postgrest"
  url "https://github.com/PostgREST/postgrest/archive/v7.0.0.tar.gz"
  sha256 "f3018c23d859255248cc741909e68bb3f12b87bf14d51cf275f54ec64b6eb891"
  head "https://github.com/PostgREST/postgrest.git"

  bottle do
    cellar :any
    rebuild 1
    sha256 "0faf148fc9d7e2335d0e8914ef4a705b1489ba7b848853d0cfafbdc3fd4a7c37" => :catalina
    sha256 "6a9bef86530f93884fe167bd146e277f4433202ef22c5fc142ac3aa654150ad4" => :mojave
    sha256 "de1af5d881a13d20e4b742f108a141ef846d6b222b88a71f69eee384241b6ac9" => :high_sierra
  end

  depends_on "cabal-install" => :build
  depends_on "ghc" => :build
  depends_on "postgresql"

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    return if ENV["CI"]

    pg_bin  = Formula["postgresql"].bin
    pg_port = free_port
    pg_user = "postgrest_test_user"
    test_db = "test_postgrest_formula"

    system "#{pg_bin}/initdb", "-D", testpath/test_db,
      "--auth=trust", "--username=#{pg_user}"

    system "#{pg_bin}/pg_ctl", "-D", testpath/test_db, "-l",
      testpath/"#{test_db}.log", "-w", "-o", %Q("-p #{pg_port}"), "start"

    begin
      port = free_port
      system "#{pg_bin}/createdb", "-w", "-p", pg_port, "-U", pg_user, test_db
      (testpath/"postgrest.config").write <<~EOS
        db-uri = "postgres://#{pg_user}@localhost:#{pg_port}/#{test_db}"
        db-schema = "public"
        db-anon-role = "#{pg_user}"
        server-port = #{port}
      EOS
      pid = fork do
        exec "#{bin}/postgrest", "postgrest.config"
      end
      sleep 5 # Wait for the server to start

      output = shell_output("curl -s http://localhost:#{port}")
      assert_match "200", output
    ensure
      begin
        Process.kill("TERM", pid) if pid
      ensure
        system "#{pg_bin}/pg_ctl", "-D", testpath/test_db, "stop",
          "-s", "-m", "fast"
      end
    end
  end
end
