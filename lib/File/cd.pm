package File::cd;

# ABSTRACT: Easily and safely change directory

use strict;
use warnings;

use Carp qw(croak);
$Carp::Internal{(__PACKAGE__)} = 1;
use Cwd ();

=head1 SYNOPSIS

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

=head1 DESCRIPTION

The global (and negative) effect of perl builtin function C<chdir> is well
known (see L<File::chdir>'s documentation for more details). And few modules
have been created to solve this problem:

=over

=item * L<File::chdir>, by David Golden.

=item * L<File::pushd>, also by David Golden.

=item * L<Cwd::Guard>, by Masahiro Nagano.

=back

Unfortunately, I'm not a big fan of their interface. So this modules provides
yet another way to change directory in perl.

=head2 FUNCTIONS

Exports the function C<cd> by default.

=cut

use Exporter qw(import);
our @EXPORT = our @EXPORT_OK = qw(cd);

=head2 cd($dir, $code)

Change directory to C<$dir>, invoke the function reference C<$code> inside
that directory, and go back to original directory.

The return value of this function is the value of the last expression in
C<$code>. Here's an example to utilize it:

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

Throws an exception when the directory C<$dir> does not exist or is not a
directory.

B<NOTE:> This function is prototyped, which means the validity of supplied
arguments are checked at compile time.

=cut

sub cd ($&) {
    my ($dir, $func) = @_;
    croak "Directory '$dir' does not exist" unless -d $dir;

    my $orig_dir = Cwd::getcwd();

    chdir $dir or croak "Failed to change directory to '$dir': $!";

    # only one will eventually be used (depending on context)
    my ($retval, @retval);

    if (wantarray) {
        @retval = $func->();
    }
    else {
        # void context also goes here
        $retval = $func->();
    }

    chdir $orig_dir
      or croak "Failed to go back to original directory '$orig_dir': $!";

    return wantarray ? @retval : $retval;
}

1;
