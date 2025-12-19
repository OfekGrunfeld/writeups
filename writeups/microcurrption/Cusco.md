New update at the manual:
> *This is Software Revision 02. We have improved the security of the*
	*lock by  removing a conditional  flag that could  accidentally get*
	*set by passwords that were too long.*

I was stuck on this level for at least 1 hour, and then looked for a hint:
*This level focuses on return manipulation*.

After I understood what return address manipulation means, and got familiar with shellcoding, I deduced that in the `test_password_valid` function the return address is stored after the password input, so the line for adding 16 to the stack pointer in order to go to the return address can be manipulated to return to a shellcode, which will be the input, or straight to the unlock_door function - as it calls what we'd want to do in a shellcode (interrupt 0x7f).

### Solution
Enter a 16 character gibberish and then the address of the `unlock_door` function;
```
>>> 414141414141414141414141414141414644
```

### Time taken:
1.5 hours with hint