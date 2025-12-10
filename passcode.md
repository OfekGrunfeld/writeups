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

Trying to input the `123456` (`0x1e240`) for trial & error:
```
python2 -c "print '\x40\xe2\x01' * 33" > payload
gdb ~/passcode 
gdbb >>> r < payload
```
`passcode1` actually held that value, but `passcode2` had a random value - because it is exactly 100 bytes from out input to `name` in `welcome()` - as I thought.

0xff9e2ce8