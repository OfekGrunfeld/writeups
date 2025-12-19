20 minutes

The manual at this level seems pretty interesting:

> *To support rapid  development cycles  this lock  accepts a program* *from the old password input prompt. The program must be signed  by* *Lockitall,  so  engineering  aren't  concerned  it  will  be  used* *maliciously. There are two programs, one of which is below  in hex* *format  and  is used in the factory to test proper lock operation.* 
    *The  other  program,  not  reproduced here, is restricted and only* *available internally at Lockitall.*
    *Load address:*
    *8000*
    *Program text:*
    *3540088000450545054505450545054505450f433041*
	*Signature:*
8605e027f42368ea6bba9de66409f6a8ddedcd49614a4648281c47a7b4ad252f5639069b17ba8f104d371e2d8a625b038f0750667364087e7987e40ea81510f

Let's disassmble the program text:
```
3540 0880      mov	#0x8008, r5 
0045           br	r5 
0545           mov	r5, r5 
0545           mov	r5, r5 
0545           mov	r5, r5 
0545           mov	r5, r5 
0545           mov	r5, r5 
0545           mov	r5, r5 
0f43           clr	r15 
3041           ret
```
Interesting...

Suspicious:
- `sha<N>` functions
- `verify_ed25519` function 
	- private key in memory?
	- `0x33` seems to be the interrupt for verifying, maybe external


Signature length: 127 (0x7f)

Program length: 44 (0x2c)


`   446e:  3f50 4300      add	#0x43, r15   `