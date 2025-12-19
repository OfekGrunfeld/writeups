Manual:
*Something something military grade encryption, something something not in memory...*

At first glance `main` is only calling two function , where the second seems arbitrary and might be manipulable, but thanks to this section of the debugger:

![[Pasted image 20251128151905.png]]
I understood that there is a function lying in `0x2400` (which is generated in the in the `enc` function) and I need to disassemble it.
I downloaded the memory dump and used this line in order to get copy the machine code:

```sh
xxd memory.bin| grep -A 20 2400 | cut -c11-50 
```
After assembly:
```
0b12           push	r11 
0412           push	r4 
0441           mov	sp, r4 
2452           add	#0x4, r4 
3150 e0ff      add	#0xffe0, sp 
3b40 2045      mov	#0x4520, r11 
@2410: 073c           jmp	$+0x10 ; (-> 6f4b)
1b53           inc	r11 
8f11           sxt	r15 
0f12           push	r15 
0312           push	#0x0 
b012 6424      call	#0x2464 
2152           add	#0x4, sp 
@2420: 6f4b           mov.b	@r11, r15 ; (<- 073c)
4f93           tst.b	r15 
f623           jnz	$-0x12 (-> 1b53)
3012 0a00      push	#0xa ; start of IDC
0312           push	#0x0 
b012 6424      call	#0x2464 
2152           add	#0x4, sp 
3012 1f00      push	#0x1f 
3f40 dcff      mov	#0xffdc, r15 
0f54           add	r4, r15 
0f12           push	r15 
2312           push	#0x2 
@2440: b012 6424      call	#0x2464 
3150 0600      add	#0x6, sp ; 
@2448 b490 e362 dcff cmp	#0x62e3, -0x24(r4) ; cmp #0x00, ???
0520           jnz	$+0xc
3012 7f00      push	#0x7f ; G O L D
b012 6424      call	#0x2464 
2153           incd	sp 
3150 2000      add	#0x20, sp 
3441           pop	r4 
3b41           pop	r11 
3041           ret 
```

After plainly following the function before and after the line which I marked as `GOLD`, it it just seems like the return address is saved 0x20 (36 dec) bytes after the password, so we can solve it by calling the address to `GOLD`, input this string:
```
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH$
```

Though because my input is limited to 31 characters, I can't reach that address.

It then took me about 30 minutes to realize `#0x62e3` is not an address, but a hardcoded value...
So i just need to make sure the 7th and 8th characters of my password match that;
### Solution
```
11111111111162e3

```

### Time taken
1 hour 10 minutes