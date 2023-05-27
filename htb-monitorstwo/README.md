# HTB MonitorsTwo

## Info
ip: 10.10.11.211

## Info gathering
When doing ping we can see that we are against a Linux VM since ping is close to 64

After an nmap scan through the whole port range we spot open ports 22 and 80.

Then we can investigate more on those ports and get
```
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    nginx 1.18.0 (Ubuntu)
|_http-server-header: nginx/1.18.0 (Ubuntu)
|_http-title: Login to Cacti
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```
Seems like it's running cacti. A network monitoring software. after a simple GET / request to the port 80 we see that it is running Cacti 1.2.22. Which has a dangerous vulnerability `CVE-2022-46169`


## Exploitation to get first access
In the port 80 it's running cacti, a network monitoring software. After a simple GET / request to the port 80 we see that it is running Cacti 1.2.22. Which has a dangerous vulnerability `CVE-2022-46169` which allows RCE. CVE score is 9.8.

I used https://github.com/FredBrave/CVE-2022-46169-CACTI-1.2.22 to open a shell into the machine.

Cacti seems to have a mysql/mariadb backend but I don't see any on localhost.

The machine runs Debian 11.

When reading [the manual of cacti](https://files.cacti.net/docs/html/unix_configure_cacti.html) we see that the config file is in `include/config.php`. So we can go there and expect to see the db credentials. And that was indeed the case:

```
$database_type     = 'mysql';
$database_default  = 'cacti';
$database_hostname = 'db';
$database_username = 'root';
$database_password = 'root';
$database_port     = '3306';
$database_retries  = 5;
$database_ssl      = false;
$database_ssl_key  = '';
$database_ssl_cert = '';
$database_ssl_ca   = '';
$database_persist  = false;
```
The hostname is `db`, but I don't see it on `/etc/hosts`.

I dont have neither nc, dig, nslookup or telnet to test connectivity with the DB or resolve the name.
But with getent I was able to resolve the hostname
```
bash-5.1$ getent hosts db
172.19.0.2      db
```
Seems like a separate host in the network or some container inside this one.

Then I went to connect to the DB with `mysql -h db -u root -proot`. And found credentials for accessing the web application.

Then I was able to get the users credentials from the users_auth table in the cacti schema:
```
admin    | *16514332FCBE9BCB313176EE624C6481BB31BDF3
guest    | 43e9a4ab75570f5b
marcus   | $2y$10$vcrYth5YcCLlZaPDj6PwqOYTw68W1.3WeKlBn70JonsdW/MhFYK4C
```
I tried to login into the service but it's not going trough.

This machine is weird for a regular VM. This DB hostname seems weird to me. And the /etc/hosts also, seems like this is running in a docker. I checked for the `/.dockerenv` and it exists, so we can confirm that we are inside of a docker container.

I had to reset the password, which is an md5 to get access. Nothing interesting inside cacti.

I don't see any interesting vulnerability in mysql or nginx. At this point I'm guessing that marcus password is also reused as the password of the main host.

Decripted the md5 online and resulted on `funkymonkey`. So trying that for logging though SSH as `marcus`. It goes though and I get to retrieve the user flag.