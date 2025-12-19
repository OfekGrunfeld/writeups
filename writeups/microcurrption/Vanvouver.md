21:30
This level they give us a *"debug"* code: `8000023041`, which after following the function appears like is just a 2 byte call address, 1 byte hardcoded check, and 2 bytes which are copied to the start of the function. 
Splitting the debug code along these simple discoveries we get:
- Call address: 0x8000
- Check byte: 0x02
- Copied opcode: 3041 (return)

So we just need to create a shellcode, jump to it and ensure we are copying first two bytes of the shellcode.
Also we'd need to end program execution as it doesn't happen naturally with a call to `__stop_progExec__`
### Solution
```
240a 0230 1200 8c10 8c10 3012 7f00 b012 a844 
```


### Time taken
15 minutes