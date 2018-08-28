use Distribution::IO;

my $API_TOKEN = %*ENV<GITHUB_API_TOKEN> // '';

sub powershell-webrequest($uri) {
    return Nil unless once { $*DISTRO.is-win && so try run('powershell', '-help', :!out, :!err) };
    my $header = $API_TOKEN.chars ?? ('-Headers @{"Authorization"="token ' ~ $API_TOKEN ~ '"}') !! '';
    my $content = shell("cmd /c powershell -executionpolicy bypass -command (Invoke-WebRequest $header -UseBasicParsing -URI $uri).Content", :out).out.slurp(:close);
    return $content;
}

sub curl($uri) {
    return Nil unless once { so try run('curl', '--help', :!out, :!err) };
    my $header = $API_TOKEN.chars ?? "Authorization: token {$API_TOKEN}" !! '';
    my $proc = run('curl', $header, '--max-time', 60, '-s', '-L', $uri, :out, :err);
    note "PROC:";
    note $proc.perl;
    my $content = $proc.out.slurp(:close);
    my $err = $proc.err.slurp(:close);
    note "ERROR:";
    note $err;
    note "CONTENT:";
    note $content;
    return $content;
}

sub wget($uri) {
    return Nil unless once { so try run('wget', '--help', :!out, :!err) };
    my $header = $API_TOKEN.chars ?? qq|--header="Authorization: token {$API_TOKEN}"| !! '';
    my $content = run('wget', $API_TOKEN.chars ?? qq|--header="Authorization: token {$API_TOKEN}"| !! (), '--timeout=60', '-qO-', $uri, :out).out.slurp(:close);
    return $content;
}

role Distribution::IO::Remote::Github does Distribution::IO {
    method user    { ... }
    method repo    { ... }
    method branch  { ... }

    method !content-uri($name-path = '') { "https://raw.githubusercontent.com/{$.user}/{$.repo}/{$.branch}/{$name-path}"     }
    method !ls-files-uri                 { "https://api.github.com/repos/{$.user}/{$.repo}/git/trees/{$.branch}?recursive=1" }
    method !https-request($url) {
        powershell-webrequest($url) // curl($url) // wget($url);
    }

    method slurp-rest($name-path, Bool :$bin) {
        my $content = self!https-request(self!content-uri($name-path));
        return $bin ?? Buf.new($content.encode) !! $content;
    }

    method ls-files {
        state @paths = do {
            my $content = self!https-request(self!ls-files-uri);
            my $json    = Rakudo::Internals::JSON.from-json($content)<tree>;
            $json.grep(*.<type>.?chars).grep({.<type>.lc eq 'blob'}).map(*.<path>)
        }
    }
}
