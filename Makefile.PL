use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;
(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Import::Into',
  VERSION_FROM => 'lib/Import/Into.pm',
  PREREQ_PM => { },
  LICENSE => 'perl',

  META_MERGE => {
    'meta-spec' => { version => 2 },
    dynamic_config => 0,
    resources => {
      # r/w: p5sagit@git.shadowcat.co.uk:Import-Into.git
      repository => {
        url => 'git://git.shadowcat.co.uk/p5sagit/Import-Into.git',
        web => 'http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/Import-Into.git',
        type => 'git',
      },
      bugtracker => {
          mailto => 'bug-Import-Into@rt.cpan.org',
          web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Import-Into',
      },
    },

  },
);
