package Import::Into;

use strict;
use warnings FATAL => 'all';

our $VERSION = '1.0';

my %importers;

sub import::into {
  my ($class, $target, @args) = @_;
  $class->${\(
    $importers{$target} ||= eval qq{
      package $target;
      sub { shift->import(\@_) };
    } or die "Couldn't build importer for $target: $@"
  )}(@args);
}

1;
 
=head1 NAME

Import::Into - import packages into other packages 

=head1 SYNOPSIS

  package My::MultiExporter;

  use Thing1 ();
  use Thing2 ();

  sub import {
    my $target = caller;
    Thing1->import::into($target);
    Thing2->import::into($target, qw(import arguments));
  }

=head1 AUTHOR

mst - Matt S. Trout (cpan:MSTROUT) <mst@shadowcat.co.uk>

=head1 COPYRIGHT

Copyright (c) 2010-2011 the Import::Into L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself.
