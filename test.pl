# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..17\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::Persistent_hash;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Check for an old test.ini and remove it if it exists.
if( -e "test.ini" ) {
   unlink('test.ini');
}

tie(%ini,'Tie::Persistent_hash', 'test.ini') ? print "ok 2\n" : print "not ok 2\n";

$ini{'scalar'} = "Jon Brandon";
$ini{'array'}  = ['Jon','Brandon'];
$ini{'hash'}   = {'Jon' => 'Brandon'};

# Check the data, and types 
$ini{'scalar'} eq "Jon Brandon" ? print "ok 3\n" : print "not ok 3\n";

ref($ini{'array'}) eq 'ARRAY' ? print "ok 4\n" : print "not ok 4\n";
($ini{'array'}->[0] eq "Jon" and $ini{'array'}->[1] eq "Brandon") ?
print "ok 5\n" : print "not ok 5\n";

ref($ini{'hash'}) eq 'HASH' ? print "ok 6\n" : print "not ok 6\n";
($ini{'hash'}->{'Jon'} eq "Brandon") ? print "ok 7\n" : print "not ok 7\n";

$ini_file = $ini{'_ini_file_'};
print( ($ini_file) ? "ok 8\n" : "not ok 8\n");

$as_string = $ini{'_raw_data_'};
(ref(eval($as_string)) eq "HASH") ? print "ok 9\n" : print "no ok 9\n";

undef(%ini);

(-e $ini_file) ? print "ok 10\n" : print "not ok 10\n";

tie(%ini,"Tie::Persistent_hash", $ini_file);

# And re-check data and types 
$ini{'scalar'} eq "Jon Brandon" ? print "ok 11\n" : print "not ok 11\n";

ref($ini{'array'}) eq 'ARRAY' ? print "ok 12\n" : print "not ok 12\n";
($ini{'array'}->[0] eq "Jon" and $ini{'array'}->[1] eq "Brandon") ?
print "ok 13\n" : print "not ok 13\n";

ref($ini{'hash'}) eq 'HASH' ? print "ok 14\n" : print "not ok 14\n";
($ini{'hash'}->{'Jon'} eq "Brandon") ? print "ok 15\n" : print "not ok 15\n";

$ini_file = $ini{'_ini_file_'};
print( ($ini_file) ? "ok 16\n" : "not ok 16\n");

$as_string = $ini{'_raw_data_'};
(ref(eval($as_string)) eq "HASH") ? print "ok 17\n" : print "no ok 17\n";

# Clean up.
undef(%ini);
unlink($ini_file);

exit;
