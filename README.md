## Distribution::Common::Remote

Create an installable Distribution from remote sources using the `Distribution::Common` interface

See [Distribution::Common](https://github.com/ugexe/Raku-Distribution--Common) for more information.
This is kept as a separate repo as it requires additional dependencies.

## Synopsis

    BEGIN %*ENV<GITHUB_ACCESS_TOKEN> = "..."; # optional, but useful due to api rate limiting

    use Distribution::Common::Remote::Github;

    # Distribution::Common::Remote:auth<github:ugexe>
    my $dist = Distribution::Common::Remote::Github.new(
        user    => "ugexe",
        repo    => "Raku-Distribution--Common--Remote",
        branch  => "main"
    );

    say $dist.meta;
    say $dist.content('lib/Distribution/Common/Remote.rakumod').open.slurp-rest;

## Classes

### Distribution::Common::Remote::Github

Installable `Distribution` from a github repository

## Roles

### Distribution::IO::Remote::Github

Fetch a single raw file from a distribution's github to memory. When `CompUnitRepository::Installation::Install.install`
accesses such files they are written directly to their install location instead of first using an intermediate temporary
location
