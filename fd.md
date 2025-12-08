### Description
```
Mommy! what is a file descriptor in Linux?
```
---
Using `ls -lah`:
```
d---------   2 root root   4.0K Jun 12  2014 .bash_history
-r-xr-sr-x   1 root fd_pwn  15K Mar 26  2025 fd
-rw-r--r--   1 root root    452 Mar 26  2025 fd.c
-r--r-----   1 root fd_pwn   50 Apr  1  2025 flag
----------   1 root root    128 Oct 26  2016 .gdb_history
dr-xr-xr-x   2 root root   4.0K Dec 19  2016 .irssi
drwxr-xr-x   2 root root   4.0K Oct 23  2016 .pwntools-cache

```
 We see the flag, which has write permission for the `fd_pwn` group, which we are not a part of (`id -Gn`).
And also we see the `fd` [`setgid`](https://redcanary.com/threat-detection-report/techniques/setuid-setgid/) binary, which we have the source code for. 


Copying to local:
```
scp -P 2222 fd@pwnable.kr:/home/fd/fd.c fd.c
```
And opening:
```C
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
char buf[32];
int main(int argc, char* argv[], char* envp[]){
        if(argc<2){
                printf("pass argv[1] a number\n");
                return 0;
        }
        int fd = atoi( argv[1] ) - 0x1234; // 4660
        int len = 0;
        len = read(fd, buf, 32);
        if(!strcmp("LETMEWIN\n", buf)){
                printf("good job :)\n");
                setregid(getegid(), getegid());
                system("/bin/cat flag");
                exit(0);
        }
        printf("learn about Linux file IO\n");
        return 0;

}
```
It's reading 32 bytes into `buf` from the inputted `fd` (Need to input fd number + `0x1234`), and those bytes must be equal to `LETMEWIN\n` to get the flag.

Now there's no `open` function so we can't create a new fd - so we can just use the `stdin` (`0`) fd:
```
// 0x1234 = 4660 in dec
fd@ubuntu:~$ ./fd 4660
>>> LETMEWIN
<<< good job :)
<<< Mama! Now_I_understand_what_file_descriptors_are!
fd@ubuntu:~$ 

```
