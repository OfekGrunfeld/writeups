This time, the function to unlock the door was removed. I assume we'l be needing to use the interrupt ourselves, because the only interrupt available to unlock the door is `0x7e` which opens the door if the password is correct at the external module.

As I discovered in the previous levels, the return address is saved on the stack after the passwords - and this level is no exception.
Looking at the stack on a breakpoint in the `conditional_unlock_door` function, there is a value which seems to correspond to the `__stop_progExec__` function - `3c44` (0x443c).

Because the code doesn't contain the `0x7f` interrupt, I've taken a look with trial and error on how to create a shellcode;
What I discovered is that I can change the `0x443c` return address to the start of the input - then we can just write `push #00x7f, call INT`

### Solution
```
0e54 0e54 0e54 0e54 3012 7f00 b012 3245 5836
```
(the `0e54` opcode corresponds to a valid operation which we don't care about, it's just a buffer)

### Time taken
25 minutes