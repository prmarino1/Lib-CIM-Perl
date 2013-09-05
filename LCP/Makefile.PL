use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'LCP',
    VERSION_FROM      => 'lib/LCP.pm', # finds $VERSION
    PREREQ_PM         => {'XML::Twig' => 1.0, 'LWP' => 6.00 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/LCP.pm', # retrieve abstract from module
       AUTHOR         => 'Paul Robert Marino <code@TheMarino.net>') : ()),
);
