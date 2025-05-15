#!/usr/bin/perl
# LinkFile.pl - Download latest version at https://marisa-apps.retro-os.live

use 5.012;		# so readdir assigns to $_ in a lone while test
use Cwd qw(cwd);	# Load in cwd command

# Globals
my $PHPBB_DATA="/var/www/html/phpBB3/files/dlext/downloads";	# The directory the other file dirs live under
my $VERSION="1.0.0";

# Init vars - don't change anything below here
my $DEST_DIR="";
my $CUR_FILE="";
my $BBS_DIR="";
my $SOURCE_DIR="";

print("linkfile.pl - Version $VERSION\n");
print("==============================\n");

sub ListDirs
{
        print "Following are the existing PHPBB download directories:\n";
        opendir(my $dh, "$PHPBB_DATA/") || die "Can't open '$PHPBB_DATA': $!";
	my @dirfiles= readdir $dh;
	closedir $dh;
	#my @sortedfiles = sort(@dirfiles);
	my @sortedfiles = sort{lc($a) cmp lc($b)} @dirfiles;
	foreach(@sortedfiles)
        {       
                if ($_ ne "." && $_ ne ".." && -d "$PHPBB_DATA/$_")
                {       
                        print "'$_'\n";
                }
        }
}

sub LinkFile
{
	my $dest_file;
	my $str;
	my $i = rindex($CUR_FILE, ".");
	$dest_file = $CUR_FILE;
	$dest_file =~ s/ /_/g;
	if (-f "$DEST_DIR/$dest_file")
	{
		print "File $DEST_DIR/$dest_file already exists, overwrite? [y/N]: ";
	        my $entered = <STDIN>;
		if ($entered ne "y")
		{
			return;
		}
	}
	my $link_cmd = "ln -fs '$SOURCE_DIR/$CUR_FILE' '$DEST_DIR/$dest_file'";
	print "Linking file $dest_file\n";
	#print "cmd = '$link_cmd'\n";
	# Link the file
	system($link_cmd);
}

# quit unless we have the correct number of command-line args
my $num_args = $#ARGV + 1;

if ($num_args != 2) {
    print "Incorrect number of arguments\n";
    print "Usage: linkfile.pl <FILE> <DOWNLOADDIR>\n";
    ListDirs();
    exit;
}

$CUR_FILE=$ARGV[0];
$BBS_DIR=$ARGV[1];

$DEST_DIR="$PHPBB_DATA/$BBS_DIR";

# Make sure target exists
if (!-d $DEST_DIR)
{
	# No, so list existing directories
	print "Destination directory '$DEST_DIR' not found\n";
	ListDirs();
	exit;
}

$SOURCE_DIR = cwd;

print "Working on '$CUR_FILE':\n";
if (! -f $CUR_FILE)
{
	print "File $CUR_FILE does not exist.\n";
	exit 0;
}

&LinkFile();

exit 0;
