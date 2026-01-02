# Description
```
How much can you control memory with unlink corruption?
```
---
Source code:
```C
// gcc -o unlink unlink.c -m32 -fno-stack-protector -no-pie  
#include <stdio.h>  
#include <stdlib.h>  
#include <string.h>  
#include <unistd.h>  
  
typedef struct tagOBJ{  
    struct tagOBJ* fd;  
    struct tagOBJ* bk;  
    char buf[8];  
}OBJ;  
  
void shell(){  
    setregid(getegid(), getegid());  
    system("/bin/sh");  
}  
  
void unlink(OBJ* P){  
    OBJ* BK;  
    OBJ* FD;  
    BK=P->bk;  
    FD=P->fd;  
    FD->bk=BK;  
    BK->fd=FD;  
}  
int main(int argc, char* argv[]){  
    malloc(2048);  
    OBJ* A = (OBJ*)malloc(sizeof(OBJ));  
    OBJ* B = (OBJ*)malloc(sizeof(OBJ));  
    OBJ* C = (OBJ*)malloc(sizeof(OBJ));  
  
    // double linked list: A <-> B <-> C  
    A->fd = B;  
    B->bk = A;  
    B->fd = C;  
    C->bk = B;  
  
    printf("here is stack address leak: %p\n", &A);  
    printf("here is heap address leak: %p\n", A);  
    printf("now that you have leaks, get shell!\n");  
    // heap overflow!  
    gets(A->buf);  
  
    // exploit this unlink!  
    unlink(B);  
    return 0;  
}
```

We are hinted to overflow the heap, so I first made a sketch of what the heap supposedly looks like and went over the `unlink` function with normal input - I understood it just makes A point to C at its `fd`, and C point to A at its `bk`. As expected. Heap:

| A start |     |     |     | B start |     |     |     | C start |     |     |     |
| ------- | --- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
| 4       | 4   | 8   | 8?  | 4       | 4   | 8   | 8?  | 4       | 4   | 8   | 8?  |
| B*      | N   | b   | M   | C*      | A*  | b   | M   | N       | B*  | b   | M   |
Where:
- A*, B*, C* are addresses to the object on the heap
- N is unusued value (junk)
- b is the buffer from the struct
- M is `malloc` metadata

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
It seems like it is loaded to `esp` (meaning the stack pointer points to it), then we pop its value into `ecx`, and at the second to last line, it moves `esp` to `$ecx-4`?? What is this? Seems like we have found the value we could overwrite to - as the `main` function returns to whatever is pointed by `$ecx -4`. Therefore, we'd need to make `$ebx - 8` hold `&shell + 4`.


#### Overriding the heap 
Before overwriting this is how the heap and stack look like this;
Heap:

| A start |      |     |     | B start |     |     |     | C start |     |     |     |
| ------- | ---- | --- | --- | ------- | --- | --- | --- | ------- | --- | --- | --- |
| 4       | 4    | 8   | 8?  | 4       | 4   | 8   | 8?  | 4       | 4   | 8   | 8?  |
| &B      | ---- | b   | --- | &C      | &A  | b   | --- | ---     | &B  | b   | --- |
(&N = address on heap, b = buffer, --- = IDC - unallocated/ `malloc` chunk metadata)
Stack:

| ebp+4    | &main    |               |
| -------- | -------- | ------------- |
| ebp      | &ebp     |               |
| ebp - 4  | OVERRIDE | Future return |
| ebp - 8  | &A       | != &A heap    |
| ebp - 0C | &B       | ""            |
| EBP -10  | &C       | ""            |
|          |          |               |

We control `&A+8` and forwards --->
That means we can use the logic of `unlink` to our advantage and make `$ebp-4` point to wherever we want.

```C
# Logic happening inside `unlink` regarding this heap example
*(*(&B)+4) = *((&B+4));
*((&B+4)) = *(&B);

/** After override we want to achieve this;
 * 1. &B = &A+8; 
 *	Where &A+8 = &shell+4 (+4 for `&ecx-4` jump),
 *	Also because we use the +4 to make sure our return address doesn't get ovewritten later. We can use other addresses as well with this logic.
 *
 * 2. &B+4 = $ebp-4
*/
*(&A+8+4) = *(&ebp-4);
*(&ebp-4) = *(&A+8);
```


Applying this logic, we need to input the following to `gets`:
```python
python2 -c 'print "&shell+4" + "A" * 12 + "&A<heap>+8" + "&A<stack>+4"
```

Let's write it with `pwntools`:

```python

```


# Flag
```

```