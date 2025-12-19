At this level, the manual says that the password was removed from memory, but was it removed hard-coded as a string or is there something similar logically which stayed?

Seems like main still works with setting `r15` as 1.

Tried looking at `check_password`. Seems like it is comparing `r15`, which was moved to the stack pointer (our input), and an arbitrary memory address, `0x4b3d`.
Every `cmp` which evaluates to 0 will make `r15` 0, as for the last two lines of the function which `clr` `r14`, then move its value to `r15`. 
So the chain of logic we need is for the first 3 arbitrary compares to not evaluate to 0, and then for the last one we do need.

In order to understand what lies at those addresses, I typed `help` and found the `read` command.
Wasn't sure how to use `read` after a minute, so I downloaded the memory dump and used instead:

```sh
xxd memory.bin | grep -A 5 <address>
```
This is what I got:
1. 0x00
2. 0x12
3. 0x00
4. 0x00

Failing whilst entering`00120000` (as hex).

After looking at the function for the second time, I was surprised to see that the hex values at the `cmp` lines aren't addresses, even though they seem like it - they are hardcoded values;
1. 0x4b3d
2. 0x4542
3. 0x3f33
4. 0x3d35

Applying the logic from before about which `cmp` needs to be evaluated to 0 we get:
```
4b3d45423f333d35
```
Didn't work. Let's try different endianess;
```
3d4b4245333f353d
```
Correct!


### Solution
```
3d4b4245333f353d
```

##### TIme taken
25 minutes