use strict;
use warnings FATAL => 'all';
use 5.008001;
use ExtUtils::MakeMaker;
(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Import::Into',
  VERSION_FROM => 'lib/Import/Into.pm',
  PREREQ_PM => { },
  LICENSE => 'perl',

  META_MERGE => {
    dynamic_config => 0,

    resources => {
      # r/w: p5sagit@git.shadowcat.co.uk:Import-Into.git
      repository => 'git://git.shadowcat.co.uk/p5sagit/Import-Into.git',
      homepage => 'http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/Import-Into.git',
    },

  },
);
