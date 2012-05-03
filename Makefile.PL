use strict;
use warnings FATAL => 'all';
use 5.008001;
use ExtUtils::MakeMaker;
(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Import-Into',
  VERSION_FROM => 'lib/Import/Into.pm',
  PREREQ_PM => { },
  LICENSE => 'perl',
);
