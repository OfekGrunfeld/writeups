### Description
```
Daddy told me about cool MD5 hash collision today.
I wanna do something like that too!
```
---

Same gist like last level in terms of getting the flag - `setgid` binary which we have the source code for.

Source:
```C
#include <stdio.h>  
#include <stdlib.h>  
#include <string.h>  
#include <unistd.h>  
unsigned long hashcode = 0x21DD09EC; 
  
unsigned long check_password(const char *p) {  
    int *ip = (int *) p;  
    int i;  
    int res = 0;  
    for (i = 0; i < 5; i++) {  
        res += ip[i];  
    }  
    return res;  
}  
  
int main(int argc, char *argv[]) {  
    if (argc < 2) {  
        printf("usage : %s [passcode]\n", argv[0]);  
        return 0;  
    }  
    if (strlen(argv[1]) != 20) {  
        printf("passcode length should be 20 bytes\n");  
        return 0;  
    }  
  
    if (hashcode == check_password(argv[1])) {  
        setregid(getegid(), getegid());  
        system("/bin/cat flag");  
        return 0;  
    } else  
        printf("wrong passcode.\n");  
    return 0;  
}
```
- We need our input through `check_password` to equal `0x21DD09EC` (568134124 in dec, in unicode - `!Ý\tì`)

`check_password`'s logic seems a bit weird - its adding up the first 5 values of a char pointer converted to int pointer? Really unsure what that means. Let's try to figure it out:
- The `ip` pointer points to the `argv` input
- Using array style access on `ip` it interpreters the `argv` in memory as 5 integers - 4 bytes each (`col@pwnable.kr` is `amd64` - `/proc/version`).
- Meaning we need an input a fifth of the size of `0x21DD09EC` and seperate it into memory correctly (signed int)

#### Seperating input
It's not so easy as to inputting `0x21DD09EC` because we can't enter null chars because of `argv` (`0x00`) - so let's try to use `0x01010101` 4 times and check how much we need to add to that:
Using ipython:
```python
In [7]: 0x21DD09EC - (0x01010101 * 4)
Out[7]: 500762088

In [8]: hex(500762088)
Out[8]: '0x1dd905e8'
```

So we basically need to enter this escaped string:
```
\x1D\xD9\x05\xE8\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01
```

Debugging in `CLion` I saw that I haven't accounted for the int -> unsigned long implicit conversion:
```
// Memory view
21 dd 09 ec  ff ff ff ff
```
The sign bit is on, seems like I did something wrong
Simply checking my string, I saw that I haven't accounted for endianness:
```
// AMD64 = Little Endian
\xE8\x05\xD9\x1D\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01
```



### Inputting the payload
I haven't documented much, but I thought of using the `print` or `printf` commands, but had trouble getting them work, but in the end bash saved me with supported C escape strings synax:
```
col@ubuntu:~$ ./col $'\xE8\x05\xD9\x1D\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01'
```
And I got the flag.

# Flag
```
Two_hash_collision_Nicely
```