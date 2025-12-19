At this level, the manual says that the code communicates with an outside module - the `HSM-1`.

I searched for the `HSM-1` in google and found a link to the micocurrption website for a user guide pdf of the `Locktail LockIT Pro` which we are working on.

In the `pdf` I found that the lock supports interrupts, and there is one which communicates with the `HSM-1`:

> *INT 0x7D.*
	*Interface with the HSM-1. Set a flag in memory if the password passed in is*
	*correct.*
	*Takes two arguments. The first argument is the password to test, the*
	*second is the location of a flag to overwrite if the password is correct.*

Interesting, maybe we could manipulate something about the parameters which are sent to the interrupt function.

Looking at the `login` function, there is a suspicious string which is outputted to the display which wasn't there is previous levels: *`Remember: passwords are between 8 and 16 characters.`*

This level, again, there a couple of instructions which have some magic values:
`   4534:  3e40 1c00      mov	#0x1c, r14   `
`   454c:  f240 0300 1024 mov.b	#0x3, &0x2410   `
`   455a:  f290 9300 1024 cmp.b	#0x93, &0x2410   `

Also, looking at the `test_password_valid` I presume it only calls the interrupt because it looks like most other function (`puts`, `getchar` etc.) but I still can't mark that off the list, though I don't really understand the use of the function because the `login` function does another "test" with the suspicious `cmp.b	#0x93, &0x2410`.

Let's try to debug with a 16 characters long password.
Seems like the password was entered at `0x2400`, exactly where the suspicious compare is.
Basically, I need to enter a 16 length gibberish password and then 0x93. 
Nice, it worked.

### Solution
```
1111111111111111111111111111111193
```

##### Time taken
30 minutes