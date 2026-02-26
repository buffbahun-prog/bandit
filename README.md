# bandit
bandit wargames shell access

First lets talk about the sturucture of the shell-script (bandit_solution.sh). It sources utils.sh which just contains animation for the loading state. I have kept the bash commands which fetches the password of the next level on array level_cmd. Later I can loop through this array to automate getting the passwords through this loop. On the loop I have ketp the password of each level on files with the level number on which is used for ssh access on that level. There are simple error handeling when there is no such password files. After I get the password of the current level, I can execute the command (from the array) on remote shell, which gives the password. And the password of the next level is stored on a file, with level indicated.

Now lets have a deep look on each level:

## Level 0 -> 1
This is simple as reading the content of the readme file on the remote shell home directory, and piping it throug grep and cut to get the exact password string from other strings.

## Level 1 -> 2
For this level the password is stored in a file named "-". As the shell interprates this character as argument flags, we can access the file with "./" relative path followed by "-"(file name), so that the shell will not interprate otherwise and treat is as a file path.

## Level 2 -> 3
For this level the password is stored in a file which contains spaces. As shell interprated the as multiple arguments because of the spaces, we enclose the file name in double-quotes so that the argument is treated as one single file and we get the password.

## Level 3 -> 4
As with the previous level, the file name contains not spaces but "." characters. As the shell interprates as relative path, we again can enclose the filename in double-quotes and we can access the file content.

## Level 4 -> 5
The instructions for getting access to the password for this level is that inhere/ directory contains multiple files and a file which is human-readable "ASCII", is the one containing the password. So simply we run file command in the directory with wildcard * so that every files in the directory is included. The file command determines type of the specified file. And for human-readable file it outputs "ASCII". Now we grep the output for getting the human-readable file and put the filename as argument for cat so that we are able to read the content of the file which contains the password. the xargs here simply puts whatever we get from standard output as argument for cat.

## Level 5 -> 6
The instruction for thsi level is that, the file containing password is somewhere in inhere directory, which is human-readable, 1033 bytes in size and has no execute permission on that file. For this we use find command which helps us find a specific file/files with certain criteria. We then provide criterias to the find command such as file size "-size", file type "-type" as f for file, not executable as negate of executable "! -executable". After doing the search we pass the output to file command and get the files which is human-readable. And thus reading the contain so this file we get the password for next level.

## Level 6 -> 7
Similar to the previous level, the password for the next level is stored in a file and can we anywhere on the filesystem. The properties of this file are: owned by user bandit7, owned by group bandit6 and 33 bytes in size. So using the utility find, we pass arguments for file size, owner user(-user) and owner group(-group). After getting this file we use cat for reading the content of this file which contains the password.

## Level 7 -> 8
For this level we have a file data.txt in the home directory, which contanis large amount of lines of text. The password for the next level is next to the word millionth. So we use the utility grep to do the job. We grep the file with "millionth" as the search string and it outputs the line on stdout if it finds one, which we can process the line text to extract the password string using utilities such as tr and cut.

## Level 8 -> 9
For this level we have a file data.txt in the home directory, which contains large amount of lines of text. The password for the next level is the only line of text that occurs only once. So we can use the uniq utility which filters adjacent matching lines from a text file or standard input. But the text lines are not adjacent so it wont work properly. Wecan use sort utility which arranges lines of text in a specific order. After arranging the text lines we can use the "-u" flag on uniq command to print out the no repeating line text. This way we get the password for the next level.

## Level 9 -> 10
For this level we have a file data.txt in the home directory, which contains large amount of text which only few human-readavle strings. The password of the next level is preceded by several ‘=’ characters. So we first read the binary file with strings utility which prints printable characters and used grep utility to search text with multiple '=' characters. Here we used regex to filter the file and after getting the text we transformed it to just get the password string.

## Level 10 -> 11
For this level we have a file data.txt in the home directory, which contains base64 encoded data. Base-64 is a encoding method where the data(binary) is encoded by mapping it to 64 printable characters. On unix/linux system we have utility "base64" which encodes/decodes binary/base64-encoded files respectively. Using the "-d" flag we decode the file and read the password content in the file.

## Level 11 -> 12
For this level we have a file data.txt in the home directory which contains strings that are rotated 13 positions for alphabetic characters. rotating 13 positions basically is chnaging a/A to m/M, b/B to n/N and so forth. So we are using tr utility to translate the chacaters back from m/M to a/A as an example. We are reversing the albhabetic string which gives the decoded text and we get the password for the nect level.

## Level 12 -> 13
For this level we have a file data.txt in the home directory which contains hexdump of a file that has been repeatedly compressed. So as we need to automate the decompression of the file that has been repatedily compressed, I have used a script called parse.sh which runs the decompression in loop until it gets the text file. As the file could be compressed in different formats(gzip, bzip2 or tar), we check the file format and decompress the file in loop. As the file is a hexdump, we convert the hexdump to binary format with xxd utility. Now we have the parser script, we pass the file to the remote shell by converting it to base64 and convert it back to the script and put it in a directory somewhere in tmp. After we pass the file to the script as argument we can get the password to the next level.

## Level 13 -> 14
For this level we get the private ssh key for next level in the home directory, with which we can simply login to the remote server to that level and get the password stored in "/etc/bandit_pass/bandit{level}".

## Level 14 -> 15
For this level we have to listen to the server running on localhost on port 3000 and by passing the password of this level to the server it outputs the password to the next level. Here we use nc networking utility used for reading from and writing to network connections. By passing the password of the current level to stdin of the server we get the password as stdout printed.

## Level 15 -> 16
For this level to retrive the password of the next level its similar to the previous level but with a added secutity SSL/TLS encryption layer on the server. For this we use ncat utility with the "--ssl" flag. This flag allows SSL/TLS encryption this allows ncat to act as an SSL client. So doing this and sending the password of this level to the server gives back the password for the next level.

## Level 16 -> 17
For this level the password for the next level can be retrieved by submitting the password of the current level to a port on localhost in the range 31000 to 32000. The connection is also SSL/TLS encrypted. First we use nmap utility which is used to scan and identify active ports. we provide the range to scan with the "-p" flag. Now after getting open tcp ports we loop it on socat utility which with the OPENSSL option encrypts the connection and with verify=0 option we are not rejected by the server for self-signed certificates. So one of the port gives the password to the next level this way.

## Level 17 -> 18
For this level the password is stored somewhere in password.new file but we have another file password.old which contains exectly the same content to password.new the only change is the password line/string only. So we use diff utility which compare the contents of two files line by line. Comparing these two files we get the password to the next level on the line different on the password.new file.

## Level 18 -> 19
The password for the next level is stored on a file readme in home directory, but the only problem is the .bashrc is modified to log us out when we log in with SSH. But we dont have any problem accessing this file as we use commands as argument on the remote shell using ssh which gives us the next password.

## Level 19 -> 20
For this level we have a setuid binary file on the home directory. Setuid is a previleged permission of the program/file owner when executing it. Now the file owner is the user of the next level so passing argument of a file it reads the content of that file. We have passwords for every level on /etc/bandit_pass with password files with permissions to that specific level users. So we can use the setuid program and read the password of the next level with this uplifted previlage.

## Level 20 -> 21
For this level we have another setuid binary program that makes connection to localhost on the port you specify as a argument. It on reading line of text from the connection compares it to the current level password and on match gives password to the next level. So we first establist a connection with a specific port with the nc utility and sent the current password which will run on background. We then listen to the connection with our setuid program. This way the program outputs the password for the next level.

## Level 21 -> 22
For this level a program is running automatically at regular intervals from cron, the time-based job scheduler. Looking at /etc/corn.d for the command running on cron we see a script at path /usr/bin/cornjob_bandit22.sh, we can get the password for the next level on the scriptcontent.

## Level 22 -> 23
For this level which is quite similar to the previous one, with cron job running on regular interval, and looking on the content of the script that is running from the cron, we see the script is storing the password on a file within tmp directory with a file name which is a hash of string 'I am user bandit23'. Now using this path we can access the password for the next level.

## Level 23 -> 24
For this level as with the previous levels with cron job, looking on the content of the script that is running from te cron, we see the script is running other scripts present in /var/spool/bandit24/foo with the previlage of user bandit24. So we create a script which creates a file in tmp that gets the password of next level from the /etc/bandit_pass/bandit24(has bandit24 read access). And when the cron job running the previlaged script which in-trun runs our script which copies the password content of next level we get the password for the next level.

## Level 24 -> 25
For this level we have a deamon which is listening on port 30002 and will give us the password for bandit25 if given the password for bandit24 and a secret numeric 4-digit pincode. A deamon is just a program runing in background. So we create a script which outputs the given passcode 'bandit24_password<space>4_digit_pincode' one at a time. And runing this script on the remote server and redirecting the output on the server we get the password for next level eith brute force.
