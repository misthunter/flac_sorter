use strict;
use File::Find;
use Lingua::EN::Titlecase;
use File::Basename;
use constant SINGLE_FILE_FLAC => 1;
use constant MULTI_FILE_FLAC => 2;
use Music::Tag;

my $results_dir = "results";
my $results_single_file_dir = "results/single_file";
my $results_multi_file_dir = "results/multi_file";
# for mac
#my $dir = "/Users/yewchoonchong/Documents/Projects/git_workspace/flac_sorter/sample";

# for windows
#my $dir = "D:/Programs/Portable/cmdline/flac_sorter/sample";

# for actual MP3
my $dir = "H:/Temp/Unsorted Music/!STAGING";
my $skip_flag = 0;
my $current_dir = undef;
my $music_file_count = 0;
my $accurip_log_found = 0;
my @files_to_process;
my @formatted_filenames;
my $prev_artist = undef;
my $various_artists = 0;


# music tags
my $artist = undef;
my $album = undef;
my $title = undef;
my $tracknum = undef;


sub get_flac_tags
{
	my $my_file = shift;
	my $info = Music::Tag->new($my_file, { quiet => 1 }, "FLAC");
	$info->get_tag();
	if ($prev_artist)
	{
		if ($prev_artist  ne $info->artist)
		{
			print "Multple artists detected\n";
			$various_artists = 1;
		}
	}
	else
	{
		$prev_artist = $info->artist;
	}
	$artist = $info->artist;
	$album = $info->album;
	$title = Lingua::EN::Titlecase->new($info->title);
	$tracknum = $info->tracknum;
	
	if ($tracknum =~ m/\//)
	{
		 my @tmp_tracknum = split(/\//, $tracknum);
		 $tracknum = sprintf("%02d", $tmp_tracknum[0]);
	}
	else
	{
		$tracknum = sprintf("%02d", $tracknum);
	}
	

    print "Artist is " . $info->artist . "\n";
}

sub dir_copy_files_to_results
{
	print "copying ...\n";
	print "$_\n" for @files_to_process;
	print "to ...\n";
	
	foreach my $files (@formatted_filenames)
	{
		print $dir . "/" .  $results_multi_file_dir . "/" . $artist . " - " . $album . "/" . $files . "\n";
	}
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

sub file_determine_flac
{
	my $my_file = shift;
	my ($name, $path, $suffix) = fileparse($my_file, '\.[^\.]*');
	my $formatted_filename = undef;

	while ($my_file =~ /[^[:print:]]/g) 
	{
		print "Non Printable Characater detected:\t$&\n";
		$skip_flag = 1;
	}   

	if ($skip_flag == 0)
	{
		if (lc($suffix) eq ".flac")
		{
			$music_file_count  ++;
			# only get the flac tags for the first 2 files
			#if ($music_file_count <= 2)
			#{
				get_flac_tags($my_file);
			#}

			push @files_to_process, $my_file;
			push @formatted_filenames, $tracknum . ". " . $title . ".flac";
		}
	}
}

sub file_determine_cue
{
	my $my_file = shift;
	my ($name, $path, $suffix) = fileparse($my_file, '\.[^\.]*');
	if ($suffix eq ".cue")
	{
		print "cue file detected\n";
		push @files_to_process, $my_file;
		push @formatted_filenames, $current_dir . ".cue";
	}
}


sub file_accurip_log_exists
{
	my $my_file = shift;
	if ($my_file eq "accurip.log")
	{
		push @files_to_process, $my_file;
		push @formatted_filenames, $my_file;
		$accurip_log_found = 1;
		print "accurip found\n";
	}
}

sub reset_global_vars
{
	$accurip_log_found = 0;
	$music_file_count = 0;
	$various_artists = 0;


	$prev_artist = undef;
	
	$artist = undef;
	$album = undef;
	$title = undef;
	$tracknum = undef;
	
	splice(@files_to_process);
	splice(@formatted_filenames);
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
		$skip_flag = 0;
		dir_process_next;
	}
	else
	{
		if ($skip_flag == 0)
		{
			file_determine_flac($File::Find::name);
			file_determine_cue($_);
			file_accurip_log_exists($_);
		}
		
	}
}

mkdir($results_dir);
mkdir ($results_single_file_dir);
mkdir ($results_multi_file_dir);

find(\&store_foundfiles,$dir);
dir_process_next(1);

# determine if single file or multiple file
# determine if various artists or single artists
# filter unwanted files

# rename cue to the correct name
#
