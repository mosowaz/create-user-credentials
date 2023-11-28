#!/bin/bash

if [ $UID -ne 0 ]; then
   echo -e "Run script as root user" \\n
   exit 1
fi

while [ $UID -eq 0 ]; do
    # exits after 20 secs of idling
    read -t 20 -p "Do you want to create a new user account? " answer
    echo

    if [ $answer = Yes ] || [ $answer = yes ]
    then
	# Checks if password generator softwares are installed
	which makepasswd >& /dev/null && which mkpasswd >& /dev/null
	if [ $? -ne 0 ]; then
   	echo "Installing prerequisite password generator..." 
   	apt install -y makepasswd >& /dev/null && apt install -y whois >& /dev/null
   	echo -e "Installation completed!" \\n
   	sleep 2   
    fi
    	echo -n "Enter the username: "; read username
    	echo -n "Enter the Full name: "; read comment
    	echo -n "Enter the user's primary group: "; read group
   	echo

	if grep -qi "$username" /etc/passwd; then
	       echo -e "$username already exist" \\n
               continue 
	fi
	
	if ! grep -qi "$group" /etc/group; then
	       groupadd $group            
	fi
	
	pass=$(/usr/bin/makepasswd --chars=5)
          
    	useradd -m -c "$comment" "$username" -d /home/"$username" -g "$group" -s /bin/bash -p `mkpasswd "$pass"`
    	chmod 750 /home/"$username"
	echo "$pass" > /home/$username/password.txt 2> /dev/null #sends password to user's home directory

	echo -e "Created new account: "
	echo -e \\t "- Username: $username" 
    	echo -e \\t "- Full name: $comment"
    	echo -e \\t "- Group name: $group"
    	echo -e \\t "- password: $pass" \\n
    else
    	echo "Exiting script!"
    	echo -e 'Reply with "Yes" to create a new user' \\n
    	exit 2
    fi
sleep 2

done
