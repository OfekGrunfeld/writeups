Like the previous level, if `r15` equals 1, the `main` function would call the `unlock_door` function.
At the `cmp.b @r13, 0x24000(r14)` line it seems like it's checking the password character by character with the `r13` register pointer with a hardcoded password which is at address `0x2400`: `{S*llwp`. 
Tried some combinations of the strings. Didn't work. Figured out I was on hex mode, disabled and solved with the string.

Side note: Didn't read other instructions in the function, I don't know what happening there just solved on the first direction I had.
### Solution
String sitting at the `0x2400` address:
```
>>> {S*llwp
```

##### Time taken
10 minutes