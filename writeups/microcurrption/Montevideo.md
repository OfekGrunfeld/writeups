The manual this level says something abstract about code change... Not leading us in any direction.

This time, the `login` function uses `strcpy` (which works with cstrings - till null 0x00 terminator) and `memset`. 
Reading `strcpy` the parameters seem to be:
- `r15` destination
- `r14` source
- `r13` ???

I'd always prefer the easy and fastest way, and therefore at a glance, I don't see any easy way to unlock the door and I'd prefer to try return address manipulation - which might be possible because I see the `3c44` (0x443c) address after the entered password was copied to the stack.

Checking with a > 16 length password, the return address can be overwritten. 
At this stage, I believe I'd need to do a shellcode similar to the previous level, but after trying to make an opcode with the `0x7f` interrupt (`3012 7f00 b012 3245 5836`) to open the door, the opcode following it wouldn't be copied because `0x7f` is entered as input as `0x7f00`  and `strcpy` sees that as a null terminator.

Using the *`MSP430 User Guide`* attached in the website, I chose a new direction to make the call with the `0x7f` interrupt;
I looked at how to put a shellcode that would manipulate a value on the stack which would turn out to be `0x7f` before the call to the interrupt (using `sxt`, `sub`, `add`), but that didn't lead to anything because we don't have much bytes to work with and some of the opcodes include the null terminator themselves...

I took a hint which was basically the answer - use the builtin `INT` function to make an interrupt, as it reads from the stack.
Because of my fatal flaw of not trying to use a shellcode after the return value manipulation, it took a while to understand that the `0x7f` interrupt code can be written after the return address - making it an input parameter for the interrupt!

### Solution
```
0e54 0e54 0e54 0e54 0e54 0e54 0e54 0e54 4c45 0e54 7f00
```
Where `4c45` (0x454c) is the `INT` function, and the `0e54` opcode is redundant.
Note: there needs to be another redundant opcode after the call address because the stack pointer moves forward.

### Time taken:
\> 1.5 hours with hint