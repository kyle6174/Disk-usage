#!/usr/bin/perl
#
#  Report how much disk space each user is consuming.
#  version 2.0
#
# TODO:  maybe check more than just /home
#

my %users;

# $users{$username} --> [ UID, Description, Home dir, MB used in home dir ]

#
# Collect RAW data
#

my $date = `date`;
chomp $date;

my $dftxt = `/bin/df -P /home | /usr/bin/tail -n 1`;
chomp $dftxt;

my $pwtxt = `/bin/cat /etc/passwd`;
chomp $pwtxt;

my $dutxt = `/usr/bin/du -ms /home/\*`;
chomp $dutxt;

my $numFiles = 0;
my $homeDir  = 0;

#
# make sense of the data
#

my @dfhome = split( '\s+', $dftxt );

foreach my $l ( split( '\n', $pwtxt ) ) {
    my @fields = split( ':', $l );
    my $uid = $fields[2];

    #if ( $uid > 499 && $uid < 1001 ) {
    if ( $uid > 501 && $uid < 1000 ) {
        $users{ $fields[0] } = [ $uid, $fields[4], $fields[5], 0 ];
    }
}

my %duinfo;
foreach my $l ( split( '\n', $dutxt ) ) {
    my @fields = split( '\s+', $l );
    $duinfo{ $fields[1] } = $fields[0];
}

foreach my $u ( sort keys %users ) {
    # get du info for the home dir
    $users{$u}[3] = $duinfo{ $users{$u}[2] };
}

my $i = 0;
foreach my $u ( sort keys %users ) {
    screen($u);

    @store[$i] = 
       [findAllFiles( $users{$u}[2] ), $users{$u}[3], returnNumber( $users{$u}[2] ), byteSize(), $users{$u}[2],$users{$u}[1], $u ];
    $i = $i + 1;
}

my @sortedStore = sort { $b->[3] <=> $a->[3] || $b->[1] <=> $a->[1] } @store;

#
# Print out the info
#

print " \n";
print "Disk usage report for MICROCORE\n";
print "-------------------------------\n";
print " \n";
print "  $date \n";
print " \n";

print " \n";
print " Usage per drive: \n";
print " \n";
print "  MB used  Mount Point   % Full \n";
print "---------  ------------  ------\n";
printf( "%8d    %-12s %4s \n", $dfhome[2] / (1024), $dfhome[5], $dfhome[4] );
print "---------  ------------  ------\n";
print " \n";

print " \n";
print " Usage per directory: \n";
print " \n";
print
  "                                                                        \n";
print
  " Total Number of files      Older than 90 Days                          \n";
print
"-------------------------  -------------------------                      \n";
print
"# of Files     MB used     # of Files     MB used       Home Directory            User \n";
print
"------------ ------------  ------------ ------------  ------------------------  ------------------------\n";

$arraySize = @sortedStore;
for ( $i = 0 ; $i < $arraySize ; $i++ ) {
    printf( "%12d %12d  %12d %12d  %-24s  %-24s \n", $sortedStore[$i][0], $sortedStore[$i][1], $sortedStore[$i][2], $sortedStore[$i][3], $sortedStore[$i][4], $sortedStore[$i][5] );
}

print
"------------ ------------  ------------ ------------  ------------------------  ------------------------\n";
print " \n";

print " \n";

interact();

my $size;
my @filelist;

# Find all files older than 90 days
sub findFiles {
    $username = $_[0];
    @filelist = split( /\n/,`/usr/bin/find /home/$username  \\( ! -name '.*' \\) -type f  -mtime +90 -user $username` );
}

#file all files
sub findAllFiles {
    $username = strip( $_[0] );
    @filelist = split( /\n/,`/usr/bin/find /home/$username  \\( ! -name '.*' \\) -type f -user $username` );
    $arraySize = @filelist;
    return ($arraySize);
}

sub byteSize {
    $size = 0;
    foreach (@filelist) {
        my $var = "$_";
        $size += `du -ms "$var" | awk '{print $1}'`;
    }
    return $size;
}

# return number of files found
sub arraySize {
    $arraySize = @filelist;
    return ($arraySize);
}

# Find number of files older than 90 days
sub returnNumber {
    $homeDir  = $_[0];
    $username = strip($homeDir);
    findFiles($username);
    return arraySize;
}

# Strip the leading /home/ from the home directory return username
sub strip {
    $homeDir = $_[0];
    $homeDir =~ s/.+\///;
    return ($homeDir);
}

# update screen to show progress
sub screen {
    $msg = $_[0];
    printf("\r                                        ");
    printf("\rProcessing user $msg ");
}

sub interact {
    print "\nWould you like to delete user files over 90 days old? ";
    $userinput = <STDIN>;
    chomp($userinput);
    if (   $userinput eq 'Y' || $userinput eq 'Yes' || $userinput eq 'y' || $userinput eq 'yes' ) {
        print "\nWhich user? ";
        $user = null;
        $user = <STDIN>;
        chomp($user);
        print "\nThis will permanently delete user files are you sure you want to delete $user 90+ old files? ";
        $userinput = null;
        $userinput = <STDIN>;
        chomp($userinput);

        if (   $userinput eq 'Y' || $userinput eq 'Yes' || $userinput eq 'y' || $userinput eq 'yes' ) {
            deleteFiles($user);
        }
        print "\nWould you like to delete more user files? ";
        $userinput = null;
        $userinput = <STDIN>;
        chomp($userinput);
        if (   $userinput eq 'Y' || $userinput eq 'Yes' || $userinput eq 'y' || $userinput eq 'yes' ) {
            interact();
        }
    }

    sub deleteFiles {
        $username = $_[0];
        print `/usr/bin/find /home/$username  \\( ! -name '.*' \\) -type f  -mtime +90 -user $username -exec rm {} \\\;`;
        print "\n";

    }
}
