package Tie::Persistent_hash;
# This package alows you to save state information from one
# run of the program to the next.

use strict;
use vars qw($VERSION);

$VERSION = '0.01';

sub TIEHASH {
   my($type, $ini_file) = @_;


   # If you think of a better way to do this please let me know
   # I want the ini_files to be in the same place as this module
   # if no inifile is given.
   unless( $ini_file ) {
      my $package = __PACKAGE__ . ".pm";
      $package =~ s/::/\//;
      $ini_file = $INC{$package};
      $ini_file =~ s/$package$//;
      $ini_file = $ini_file.$0.".ini";  
   }

   my $this = load($ini_file);

   bless $this, $type;

   $this->{'_ini_file_'} = $ini_file;
   
   return $this;

}

sub load {
   my($ini_file) = @_;
   my($in, $this);

   open(IN, $ini_file);

   my $save = $/;
   $/ = '';
   
   $in = <IN>;
   if( $in ) {
      $this = eval $in;
   } else {
      $this = {};
   }

   close(IN);

   $/ = $save;

   return $this;
}

sub FETCH {
   my($obj, $value) = @_;
   my($tmp);

   if( $obj->{$value} ) {

      $tmp = $obj->{$value};

      if( $tmp ) {
         return $tmp;
      } else {
         return $obj->{$value};
      }

   } elsif( $obj->can($value) ) {
      return $obj->$value();
   } else {
      return undef;
   }
}

sub EXISTS {
   my($obj, $key) = @_;
   $obj->{$key} ? return 1 : return 0;
}

sub STORE {
   my($obj, $key, $value) = @_;
   unless( $key eq "_ini_file_" ) {
      $obj->{$key} = $value;
   } else {
      print "Sorry you can not overwrite ini_file\n";
   }
}

sub DELETE {
   my($obj, $key) = @_;

   undef($obj->{$key});
   delete($obj->{$key});
}

sub DESTROY {
   my($obj) = @_;
   
   my $save = $obj->_raw_data_();

   open(OUT, ">$obj->{'_ini_file_'}");
   print OUT $save;
   close(OUT);

}

sub CLEAR {
   my($obj) = @_;

   $obj->DESTROY();
   undef(%{$obj});
}

sub _raw_data_ {
   my($obj) = @_;

    my %explosivo = %{$obj};
    delete($explosivo{'_ini_file_'});
    return(package_hash(\%explosivo));
}

sub package_array {
   my($array) = @_;
   my($value); 

   my $ret_array = "[";

   for( @{$array} ) {
      if( ref($_) eq 'ARRAY' ) {
         $value = package_array($_);
      } elsif( ref($_) eq 'HASH' ) {
         $value = package_hash($_);
      } else {
         $value = $_;
      }

      if( ref($_) ne 'HASH'  and ref($_) ne 'ARRAY' ) {
	 $value =~ s/\\/\\\\/g;
	 $value =~ s/'/\\'/g;
         $ret_array .= "'$value',";
      } else {
         $ret_array .= "$value,";
      }
   }

   $ret_array =~ s/,$//;
   $ret_array .= "]";

   return($ret_array);
}

sub package_hash {
   my($hash) = @_;
   my($value); 

   my $ret_hash = "{\n";

   for( keys(%{$hash}) ) {
      if( ref($hash->{$_}) eq 'ARRAY' ) {
         $value = package_array($hash->{$_});
         $value = "'$_',$value,";
      } elsif( ref($hash->{$_}) eq 'HASH' ) {
         $value = package_hash($hash->{$_});
         $value = "'$_',$value,";
      } else {
	 $value =  $hash->{$_};
	 $value =~ s/\\/\\\\/g;
	 $value =~ s/'/\\'/g;
         $value =  "'$_','$value',";
      }

      $ret_hash .= "$value";
   }

   $ret_hash =~ s/,$//;
   $ret_hash .= "\n}\n";

   return($ret_hash);

}
1;
__END__

=head1 NAME

Tie::Persistent_hash - persistent hash

=head1 SYNOPSIS

  use Tie::Persistent_hash;

  # Tie to a hash and have Persistent_hash decide where to put
  # The file it will create.
  tie(%ini, 'Tie::Persistent_hash'); 
  
  # or tell Persistent_hash where to put the file, so you know where 
  # it is.
  tie(%ini, 'Tie::Persistent_hash','my_ini_file'); 

   $ini{'keep_this'} = "very important info";
   $ini{'employees'} = ['chris','mathias','jeff','steve'];
   $ini{'schedule'}  = {'chris' => ['monday','tuesday'],
                        'jeff'  => ['thursday','friday']};

   # Or whatever you want to do with the hash.  Next time
   # You tie to it these values will still exist.

   $ini_file  = $ini{'_ini_file_'}; # Get the path to the inifile.
   $as_string = $ini{'_raw_data_'}; # Get the hash as it is stored to the file.

=head1 DESCRIPTION

The Tie::Persistent_hash package allows you to work with a hash and have
that information stored from one run of the program to the next. 

Persistent_hash was written because I wanted a simple way for a program 
to use an ini file without writing subroutines to read and parse this 
information each time I wanted to work with it.  Using a hash makes 
this very simple because it is easy to work with, and native to the
perl language.

There are currently two special keys, '_ini_file_' which is where
Persistent_hash saves the path to the ini file it is using, and
'_raw_data_' which is the subroutine that Persistent_hash uses to
pack up the hash for storage in a file.

You cannot use _ini_file_ as a key. If this was overwritten, Persistent_hash
would not know where to save the hash.  You can, however, overwrite
_raw_data_; but if you did this and want to get the hash as a string
you would no longer be able to do so.  I would suggest not using keys
that are surrounded by '_' just in case there are more useful routines
in future versions.

=head1 EXAMPLE
   use Tie::Persistent_hash;

   tie(%ini,'Tie::Persistent_hash',"$0.ini");
 
   print "Please enter some key values pairs ^D when done\n";

   do {
      ($key,$value) = split(/\s+/);

       if( $key and $value ) {
          if($ini{$key}) {
             print "Key: $key was $ini{$key}; now setting $key to $value\n";
             $ini{$key} = $value; 
          } else {
             print "Key: $key did not exist, now setting\n";
             $ini{$key} = $value;
          }
       }

   } while(<>);

   # Each run of this example will start with the key values that
   # were entered during the last time the program was run.

   my $raw_data = $ini{'_raw_data_'};
   print "Here is the hash packaged up and ready for storage, $raw_data\n";
     
   my $ini_file = $ini{'_ini_file_'};
   print "And here is where it will be stored $ini_file\n"; 

=head1 AUTHOR

Jon Brandon <jonjay@teleport.com>

=head1 SEE ALSO

perl(1).

=cut

