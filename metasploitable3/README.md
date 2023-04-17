# metasploitable 3 workspace
My workspace on exploiting metasploitable3. Contains:
- Simple custom exploit for ProFTPd 1.3.5
- Payroll_app source code extracted with the exploit
- nmap scan result
- Some sample sql injection
- Writeup (the rest of this readme is the writeup).
- Vagrant file for starting the VM

## Path I followed to uid 0
I'm sure there are many more but here is mine:
1. Scan the machine and find that is running a vulnerable service, ProFTPd 1.3.5. Also, it is quite apparent that this is a LAMP setup
2. Create an exploit for the vulnerablilty. Easily done by reading about it.
3. Get some files, info about the system, users available...
4. Then you can explore the websites available. Payroll app seems particularly insecure. The chat also does.
5. Use the exploit for ProFTPd to get the php code of the app. It is in /var/www/html/payroll_app/index.php
6. You can see the credentials for accessing the DB in the source code of the app: user root and pass sploitme. Also we can see that the thing is vulnerable to the most basic sql injection, but there is no need to use it since we have the admin creds.
7. It is not possible to connect with a mysql client from your local machine because MySql is only accepting request from localhost, but we can use the phpmyadmin webservice available in port 80 to bypass this limitation, because the queries are done from localhost.
8. You can see a table called users in the payroll app, the credentials are in plain text.
9. This credentials happen to be usefull to login through ssh. After checking some users, the leia user happens to belong to the sudo group. So just do sudo su and you will have root access.

## Things to remediate/holes that I found
1. Update ProFTPd
2. Phpmyadmin shouldn't be accessible by the end user
3. Payroll app is vulnerable to SQL injection
4. User passwords are stored in plain text
