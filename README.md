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
For this level we have a file data.txt in the home directory, which contains large amount of text which only few human-readavle strings. The password of the next level is preceded by several ‘=’ characters. So we used grep utility to search text with multiple '=' characters. Here we used regex to filter the file and after getting the text we transformed it to just get the password string.

## Level 10 -> 11
For this level we have a file data.txt in the home directory, which contains base64 encoded data. Base-64 is a encoding method where the data(binary) is encoded by mapping it to 64 printable characters. On unix/linux system we have utility "base64" which encodes/decodes binary/base64-encoded files respectively. Using the "-d" flag we decode the file and read the password content in the file.
