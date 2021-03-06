# NAME

File::cd - Easily and safely change directory

# VERSION

version 0.003

# SYNOPSIS

    use 5.010;
    use File::cd;
    use Cwd qw(cwd);

    cd '/tmp' => sub {
        # output: /tmp
        say cwd;

      # do something in /tmp
      process_directory();

        # we can also nest multiple cds
        cd '/home/foo' => sub { ... };
    };

    # back at original directory
    say cwd;

# DESCRIPTION

The global (and negative) effect of perl builtin function `chdir` is well
known (see [File::chdir](http://search.cpan.org/perldoc?File::chdir)'s documentation for more details). And few modules
have been created to solve this problem:

- [File::chdir](http://search.cpan.org/perldoc?File::chdir), by David Golden.
- [File::pushd](http://search.cpan.org/perldoc?File::pushd), also by David Golden.
- [Cwd::Guard](http://search.cpan.org/perldoc?Cwd::Guard), by Masahiro Nagano.

Unfortunately, I'm not a big fan of their interface. So this modules provides
yet another way to change directory in perl.

## FUNCTIONS

Exports the function `cd` by default.

## cd($dir, $code)

Change directory to `$dir`, invoke the function reference `$code` inside
that directory, and go back to original directory.

The return value of this function is the value of the last expression in
`$code`. Here's an example to utilize it:

    # get a list of files contained in directory /home/example
    use File::Spec qw(catfile);

    my $destination = '/home/example';

    my @files = cd $destination => sub {
        map { catfile $destination, $_ } glob '*'
    }

    # make sure to match the context!
    my $files = cd $destination => sub {
        [ map { catfile $destination, $_ } glob '*' ]
    }

Throws an exception when the directory `$dir` does not exist or is not a
directory.

__NOTE:__ This function is prototyped, which means the validity of supplied
arguments are checked at compile time.

# AUTHOR

Ahmad Syaltut <syaltut at cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Ahmad Syaltut.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
