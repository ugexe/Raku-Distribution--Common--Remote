use Net::HTTP::GET;
use Distribution::IO;

role Distribution::IO::Remote::Github does Distribution::IO {
    method user   { ... }
    method repo   { ... }
    method branch { ... }

    method !content-uri($name-path = '') { "https://raw.githubusercontent.com/{$.user}/{$.repo}/{$.branch}/" ~ $name-path    }
    method !ls-files-uri                 { "https://api.github.com/repos/{$.user}/{$.repo}/git/trees/{$.branch}?recursive=1" }

    method slurp-rest($name-path, Bool :$bin) {
        my $response = Net::HTTP::GET(self!content-uri($name-path));
        $bin ?? $response.body !! $response.content;
    }

    method ls-files {
        state @paths = do {
            my $content = Net::HTTP::GET(self!ls-files-uri).content;
            my @json    = |Rakudo::Internals::JSON.from-json($content)<tree>;
            @json.grep(*.<type>.?chars).grep({.<type>.lc eq 'blob'}).map(*.<path>)
        }
    }
}
