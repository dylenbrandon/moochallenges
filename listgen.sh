#!/bin/bash
#  Author: Dylen Brandon Rivera
#  Created on: 08/04/2019
#
#  Inform the user about this script and how to use it.
if [[ $# -eq 0 ]]; then
	echo -e "USAGE: listgen.sh <newlist>\n"
	echo "Description: A 15 character list generator." 
	echo "Two lists are created."
	echo "The first list is unaltered."
	echo "The second list excludes strings starting with an upper or lower case 'a'."
	exit 0
fi

# Assign filename to variable FILE for use later.
FILE="$1"

# If the target file exists, exit. Inform the user that the target file exists.
if [ -e "$FILE" ]; then
	echo "File exists. Exiting."
	exit 0
fi

# Create the file. The file has to be created first before the while loop.
# Running "ls -l $FILE" within the loop generates an error as the file doesnt exist yet.
touch $FILE

# Inform the user that the list is being generated.
echo "Generating list $FILE..."

# To control the size of the file I simply used a while loop.
# By creating a while loop I can ensure that the created list never exceeds 1MB.
# While the provided file is less than 1MB(1000000 Bytes), continue to generate the list.
# I instinctively wanted to use a long listing of the target file.
# Then piping the long listing into awk using 'space' as a delimiter to grab the file size.
# See example....
#          while [ $(ls -l "$FILE" | awk -F' ' '{print $5}') -lt 1000000 ]
# While perfectly acceptable, it didn't feel "clean" to me.
# I decided to use the stat command instead.
# This command gave me the exact same result as the above example with much cleaner code.
while [ $(stat -c %s "$FILE") -lt 1000000 ]
do
# Generate a random 15 character line and append to the file. 
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 2000 >> $FILE
# This is done by translating the output of /dev/urandom into the requested 
# format. By specifying [A-Za-z0-9] we are guaranteed to have each character
# in our string translated into 1 out of 62 available options.
# 26 Lower-Case Characters [a-z].
# 26 Upper-Case Characters [A-Z].
# 10 Numerical Characters [0-9].
# 62 Total possibilities per character.
#
# The 'fold' command allows us to wrap the output of the concatenation to
# the desired 15 characters per line.
#
# I tried to use head -n 1 to redirect the generated string line-by-line
# into the desired file. This method proved rather slow to complete the process.
# Using head -n 1 also gave me inconsistent file sizes at the end of the process.
# By feeding the file a larger amount of strings per cycle I was able to complete
# the process of generating the list much quicker. File sizes were also consistent
# at 1000000 bytes exactly.(As reported by the command 'ls -lh').
done

# Inform the user that the list has been generated.
echo "List \"$FILE\" created. Total lines generated: $(wc -l $FILE | awk -F' ' '{print $1}')."

# We sort the list and exclude any lines beginning with an uppercase or lowercase 'a'.
# I found that I didn't really need to sort in any specific manner.
# The sort defaults work just fine.
sort $FILE | grep -vE '\b[aA]' >$FILE-no-aA
# Inform the user that this list has also be created.
echo "List \"$FILE-no-aA\" created. Total lines: $(wc -l $FILE-no-aA | awk -F' ' '{print $1}')."
# To whowever is reviewing this. This was fun!
