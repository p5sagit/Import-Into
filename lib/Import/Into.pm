package Import::Into;

use strict;
use warnings FATAL => 'all';

our $VERSION = '1.001000'; # 1.1.0

my %importers;

sub _importer {
  my $target = shift;
  \($importers{$target} ||= eval qq{
    package $target;
    sub { my \$m = splice \@_, 1, 1; shift->\$m(\@_) };
  } or die "Couldn't build importer for $target: $@")
}
  

sub import::into {
  my ($class, $target, @args) = @_;
  $class->${_importer($target)}(import => @args);
}

sub unimport::out_of {
  my ($class, $target, @args) = @_;
  $class->${_importer($target)}(unimport => @args);
}

1;
 
=head1 NAME

Import::Into - import packages into other packages 

=head1 SYNOPSIS

  package My::MultiExporter;

  use Import::Into;

  use Thing1 ();
  use Thing2 ();

  sub import {
    my $target = caller;
    Thing1->import::into($target);
    Thing2->import::into($target, qw(import arguments));
  }

Note: you don't need to do anything more clever than this provided you
document that people wanting to re-export your module should also be using
L<Import::Into>. In fact, for a single module you can simply do:

  sub import {
    ...
    Thing1->import::into(scalar caller);
  }

Notably, this works:

  use base qw(Exporter);

  sub import {
    shift->export_to_level(1);
    Thing1->import::into(scalar caller);
  }

Note 2: You do B<not> need to do anything to Thing1 to be able to call
C<import::into> on it. This is a global method, and is callable on any
package (and in fact on any object as well, although it's rarer that you'd
want to do that).

Finally, we also provide an C<unimport::out_of> to allow the exporting of the
effect of C<no>:

  # unimport::out_of was added in 1.1.0 (1.001000)
  sub unimport {
    Moose->unimport::out_of(scalar caller); # no MyThing == no Moose
  }

If how and why this all works is of interest to you, please read on to the
description immediately below.

=head1 DESCRIPTION

Writing exporters is a pain. Some use L<Exporter>, some use L<Sub::Exporter>,
some use L<Moose::Exporter>, some use L<Exporter::Declare> ... and some things
are pragmas.

If you want to re-export other things, you have to know which is which.
L<Exporter> subclasses provide export_to_level, but if they overrode their
import method all bets are off. L<Sub::Exporter> provides an into parameter
but figuring out something used it isn't trivial. Pragmas need to have
their C<import> method called directly since they affect the current unit of
compilation.

It's ... annoying.

However, there is an approach that actually works for all of these types.

  eval "package $target; use $thing;"

will work for anything checking caller, which is everything except pragmas.
But it doesn't work for pragmas - pragmas need:

  $thing->import;

because they're designed to affect the code currently being compiled - so
within an eval, that's the scope of the eval itself, not the module that
just C<use>d you - so

  sub import {
    eval "use strict;"
  }

doesn't do what you wanted, but

  sub import {
    strict->import;
  }

will apply L<strict> to the calling file correctly.

Of course, now you have two new problems - first, that you still need to
know if something's a pragma, and second that you can't use either of
these approaches alone on something like L<Moose> or L<Moo> that's both
an exporter and a pragma.

So, the complete solution is:

  my $sub = eval "package $target; sub { shift->import(\@_) }";
  $sub->($thing, @import_args);

which means that import is called from the right place for pragmas to take
effect, and from the right package for caller checking to work - and so
behaves correctly for all types of exporter, for pragmas, and for hybrids.

Remembering all this, however, is excessively irritating. So I wrote a module
so I didn't have to anymore. Loading L<Import::Into> creates a global method
C<import::into> which you can call on any package to import it into another
package. So now you can simply write:

  use Import::Into;

  $thing->import::into($target, @import_args);

This works because of how perl resolves method calls - a call to a simple
method name is resolved against the package of the class or object, so

  $thing->method_name(@args);

is roughly equivalent to:

  my $code_ref = $thing->can('method_name');
  $code_ref->($thing, @args);

while if a C<::> is found, the lookup is made relative to the package name
(i.e. everything before the last C<::>) so

  $thing->Package::Name::method_name(@args);

is roughly equivalent to:

  my $code_ref = Package::Name->can('method_name');
  $code_ref->($thing, @args);

So since L<Import::Into> defines a method C<into> in package C<import>
the syntax reliably calls that.

For more craziness of this order, have a look at the article I wrote at
L<http://shadow.cat/blog/matt-s-trout/madness-with-methods> which covers
coderef abuse and the C<${\...}> syntax.

Final note: You do still need to ensure that you already loaded C<$thing> - if
you're receiving this from a parameter, I recommend using L<Module::Runtime>:

  use Import::Into;
  use Module::Runtime qw(use_module);

  use_module($thing)->import::into($target, @import_args);

And that's it.

=head1 AUTHOR

mst - Matt S. Trout (cpan:MSTROUT) <mst@shadowcat.co.uk>

=head1 CONTRIBUTORS

None yet - maybe this software is perfect! (ahahahahahahahahaha)

=head1 COPYRIGHT

Copyright (c) 2012 the Import::Into L</AUTHOR> and L</CONTRIBUTORS>
as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms
as perl itself.
