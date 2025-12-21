# Description
```
Are you tired of hacking?, take some rest here.
Just help me out with my small experiment regarding memcpy performance. 
after that, flag is yours.
```
---
`~/readme`:
```
the compiled binary of "memcpy.c" source code (with real flag) will be executed under memcpy_pwn privilege if you connect to port 9022.
execute the binary by connecting to daemon(nc 0 9022).

nc 0 2000 if service is down
```

`nc 0 9022`:
```
Hey, I have a boring assignment for CS class.. :(
The assignment is simple.
-----------------------------------------------------
- What is the best implementation of memcpy?        -
- 1. implement your own slow/fast version of memcpy -
- 2. compare them with various size of data         -
- 3. conclude your experiment and submit report     -
-----------------------------------------------------
This time, just help me out with my experiment and get flag
No fancy hacking, I promise :D
specify the memcpy amount between 8 ~ 16 :
```

Running the program with the most minimal inputs makes it stuck on `fast_copy` for 128 bytes:
```
specify the memcpy amount between 8 ~ 16 : 8
specify the memcpy amount between 16 ~ 32 : 16
specify the memcpy amount between 32 ~ 64 : 32
specify the memcpy amount between 64 ~ 128 : 64
specify the memcpy amount between 128 ~ 256 : 128
specify the memcpy amount between 256 ~ 512 : 256
specify the memcpy amount between 512 ~ 1024 : 512
specify the memcpy amount between 1024 ~ 2048 : 1024
specify the memcpy amount between 2048 ~ 4096 : 2048
specify the memcpy amount between 4096 ~ 8192 : 4096
ok, lets run the experiment with your configuration
experiment 1 : memcpy with buffer size 8
ellapsed CPU cycles for slow_memcpy : 5344
ellapsed CPU cycles for fast_memcpy : 802

experiment 2 : memcpy with buffer size 16
ellapsed CPU cycles for slow_memcpy : 946
ellapsed CPU cycles for fast_memcpy : 1072

experiment 3 : memcpy with buffer size 32
ellapsed CPU cycles for slow_memcpy : 1550
ellapsed CPU cycles for fast_memcpy : 1626

experiment 4 : memcpy with buffer size 64
ellapsed CPU cycles for slow_memcpy : 2744
ellapsed CPU cycles for fast_memcpy : 412

experiment 5 : memcpy with buffer size 128
ellapsed CPU cycles for slow_memcpy : 5346
...
```

That means we at least have to understand what the `fast_copy` function does:
```C
char* fast_memcpy(char* dest, const char* src, size_t len){  
    size_t i;  
    // 64-byte block fast copy  
    if(len >= 64){  
       i = len / 64;  
       len &= (64-1);  
       while(i-- > 0){  
          __asm__ __volatile__ (  
          "movdqa (%0), %%xmm0\n"  
          "movdqa 16(%0), %%xmm1\n"  
          "movdqa 32(%0), %%xmm2\n"  
          "movdqa 48(%0), %%xmm3\n"  
          "movntps %%xmm0, (%1)\n"  
          "movntps %%xmm1, 16(%1)\n"  
          "movntps %%xmm2, 32(%1)\n"  
          "movntps %%xmm3, 48(%1)\n"  
          ::"r"(src),"r"(dest):"memory");  
          dest += 64;  
          src += 64;  
       }  
    }  
  
    // byte-to-byte slow copy  
    if(len) slow_memcpy(dest, src, len);  
    return dest;  
}
```
`XMM` register usage here seems to be fine, so let's try to find something about the opcodes:

Reading about `movdqa` (_Move alligned double quadword_) and `movntps` (_Store Packed Single Precision Floating-Point Values Using Non-Temporal Hint_).
- Alignment seems to be the issue
Reading up on `movdqa` I saw that an exception can occur:
> If a memory operand is not aligned on a 16-byte boundary, regardless of segment. If any part of the operand lies outside the effective address space from 0 to FFFFH. 

I don't quite understand what that means, but I assume there is something to do with aligning the `memvpy` to a `16-byte` aligned address.

When compiling both on my machine and on the remote, then testing with minimal input I got these addresses which are all divisible by 16:
```
addressses = [0x5af1e5b0, 0x5af1e5c0, 0x5af1e5e0, 0x5af1e610, 0x5af1e660, 0x5af1e6f0, 0x5af1e800, 0x5af1ea10, 0x5af1ee20, 0x5af1f630]
```
That means `memcpy` what compiled with a `malloc` which doesn't work as expected for this program.
Reading up on `malloc` implementation online, I learned that it can allocate a bigger block then needed in order to save information about the block it allocates, so in order to make it 16 aligned, we'll need to add up to that extra allocation.

Trying it on both on my machine and on the remote gave me +16 bytes for every allocation. Meaning it is always allocated correctly... 

At this point I was sure something is wrong with the remote, because when compiling and testing it seems to be the same as my machine, but not like the program sitting at `nc 0 9022`. Reading a writeup afterwards, I was right about self aligning with the extra block size, it was 8 instead of 16.

```shell
printf '8\n16\n32\n72\n136\n264\n520\n1032\n2056\n4104\n' | nc 0 9022
```
# Flag
```
b0thers0m3_m3m0ry_4lignment
```