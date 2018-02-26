use strict;
use File::Find;

use constant SINGLE_FILE_FLAC => 1;
use constant MULTI_FILE_FLAC => 2;


my $dir = "H:/Temp/Unsorted Music/Testing";
my $current_dir = undef;
my $music_file_count = 0;
my $accurip_log_found = 0;
my @files_to_process;


sub dir_copy_files_to_results
{
	print "copying ...\n";
	print "$_\n" for @files_to_process;
}

sub dir_single_or_multi_file
{
	my $my_file = shift;
	my $retval = MULTI_FILE_FLAC;
	if ($music_file_count == 1)
	{
		$retval = SINGLE_FILE_FLAC;
		print "Suspect this could be a single-file flac.\n"
	}
	return $retval;
}


sub file_determine_if_flac
{
	my $my_file = shift;
	if ($my_file =~ m/.flac$/)
	{
		push @files_to_process, $my_file;
		$music_file_count  ++;
		#print "$_\n"
	}
}

sub file_accurip_log_exists
{
	my $my_file = shift;
	if ($my_file eq "accurip.log")
	{
		push @files_to_process, $my_file;
		$accurip_log_found = 1;
		print "accurip found\n";
	}
}

sub reset_global_vars
{
	$accurip_log_found = 0;
	$music_file_count = 0;
	splice(@files_to_process);
}


sub dir_process_next
{
	my $last = shift;
	$current_dir = $_;
	if ($music_file_count  > 0)
	{
		print "Total music files = $music_file_count\n";
		my $single_or_multi_file = dir_single_or_multi_file($music_file_count);

		dir_copy_files_to_results;
		reset_global_vars;
	}
	else
	{
		print "This folder does not contain music files\n\n";
	}

	if ($last)
	{
		
	}
	else
	{
		print "\n\ncurrent_dir = $current_dir\n";
	}
	
}

sub store_foundfiles {
    next if $_ eq '.' or $_ eq '..';      
	
	if (-d $_)
	{
		dir_process_next;
	}
	else
	{
		file_determine_if_flac($_);
		file_accurip_log_exists($_);
	}
}


mkdir("results");
mkdir ("results/single_file");
mkdir ("results/multi_file");

find(\&store_foundfiles,$dir);
dir_process_next(1);
# determine if single file or multiple file
# determine if various artists or single artists
# look for unwanted files

# rename cue to the correct name
# 