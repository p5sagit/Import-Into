use strict;
use warnings FATAL => 'all';
use Test::More qw(no_plan);

BEGIN {

  package MyExporter;

  use base qw(Exporter);

  our @EXPORT_OK = qw(thing);

  sub thing { 'thing' }

  package MultiExporter;

  use Import::Into;

  sub import {
    my $target = caller;
    warnings->import::into($target);
    MyExporter->import::into($target, 'thing');
    CheckFile->import::into(1);
  }

  $INC{"MultiExporter.pm"} = 1;
}

my @checkcaller;
BEGIN {

  package CheckFile;

  sub import {
    @checkcaller = caller;
  }

  $INC{"CheckFile.pm"} = 1;
}

BEGIN {

  package TestPackage;

  no warnings;

#line 1
  use MultiExporter;

  sub test {
    thing . undef
  }
}

my @w;

is(do {
  local $SIG{__WARN__} = sub { push @w, @_; };
  TestPackage::test;
}, 'thing', 'returned thing ok');

is(scalar @w, 1, 'Only one entry in @w');

like($w[0], qr/uninitialized/, 'Correct warning');

is $checkcaller[0], 'TestPackage', 'import by level has correct package';
is $checkcaller[1], __FILE__, 'import by level has correct file';
is $checkcaller[2], 1, 'import by level has correct line';
