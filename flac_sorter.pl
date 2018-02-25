use strict;
use File::Find;
my $dir = "H:/Temp/Unsorted Music/!STAGING";

find(\&store_foundfiles,$dir);

sub store_foundfiles {
    next if $File::Find::name eq '.' or $File::Find::name eq '..';      
 
	
    if ($File::Find::name =~/.cue/)
	{
		print $File::Find::name . "\n";
	}
}