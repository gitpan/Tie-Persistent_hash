use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Tie::Persistent_hash',
    'VERSION_FROM' => 'Persistent_hash.pm', # finds $VERSION
);
