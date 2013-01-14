Disk-usage
==========

Disk usage and cleanup utils

disk_cleanup_90.pl
 
Use and additional info.

***Make sure you run it as sudo.*** 


The output takes up a good amount of space on the screen. You may need
to expand your terminal to accommodate all output without wrapping. 


This program will scan every users home directory and print information
on number of files and space used. The program takes some time to run.
The more files a user has in their home directory the longer it will
take to scan.

After the program is finished scanning it will display a list of all
users used space.

Total Number of files  
number of files  - total number of files in user directory  
MB used     - total used space on user home dir

Older than 90 Days  
number of files  - number of files in user directory over 90 days old  
MB used     - used space on user home dir from files over 90 days old

The program will then display a prompt asking the user if they wish to
delete files over 90 days old. If the user chooses to continue, they
will then be asked to enter a username. The program will then confirm
the removal of the files and then proceed with deletion. The prompt will
loop after this step.

 
Known issues:
 
The MB used in the total number of files and the files over than 90 days
do no match. This is more apparent when the total number of files and
the number of files over 90 days are the same. I’m guessing that a
rounding error may be the cause of the discrepancy. 
