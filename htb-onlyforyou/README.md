# onlyforyou

## General info
ip `10.10.11.210`

hackthebox medium

linux

## Info gathering

From the outside I only see port 80 and 22.
80 10.10.11.210 nginx/1.18.0 (Ubuntu)
```
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.5 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    nginx 1.18.0 (Ubuntu)
|_http-server-header: nginx/1.18.0 (Ubuntu)
|_http-title: Only4you
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

There's virtual hosting enabled. We do have to add the header `Host: onlyforyou.htb` to the requests in order to see the website.

It does not seem interesting. Plain http, html and css website. However, after browsing it we can see a reference to [beta.only4you.htb](http://beta.only4you.htb/).

This one is indeed interesting. The source code is available and it's a python webapp for resizing and converting images.

## First look inside the machine

After a while, I realize that the /download endpoint is vulnerable to directory traversal and I exploit it to gain access to files. Exploit available in `exploits/file-retrieval.sh`.

non system users: `john` and `dev`

other interesting users: `mysql`, `neo4j` and `lxd`. The first two services must be either down or only available from inside.


Webapps in `/var/www/beta.only4you.htb` and `/var/www/beta.only4you.htb`. Nginx does a proxypass to the unix sockets `proxy_pass http://unix:/var/www/only4you.htb/only4you.sock` and `proxy_pass http://unix:/var/www/beta.only4you.htb/beta.sock` respectively.

SSH allows password authentication.


