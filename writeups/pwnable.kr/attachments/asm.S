#define O_RDONLY    0
#define O_WRONLY    0
#define O_CREAT     64

#define N_READ  0
#define N_WRITE 1
#define N_OPEN  2

#define SYSCALL(x) do { mov x, %rax; syscall} while(0);

#define SYSCALL_READ SYSCALL(N_READ)
#define SYSCALL_WRITE SYSCALL(N_WRITE)
#define SYSCALL_OPEN SYSCALL(N_OPEN)


// open("./file", O_RDONLY, 0)
xor eax, eax
push rax
mov rbx, 0x656c69662f2e
push rbx
mov rdi, rsp
mov rsi, O_RDONLY
mov edx, 0
SYSCALL_OPEN;
// r12 = fd
mov r12, rax

// open("./flie", O_WRONLY | O_CREAT, 0)
xor eax, eax
push rax
mov rbx, 0x65696c662f2e
push rbx
mov rdi, rsp
mov rsi, (O_WRONLY | O_CREAT)
mov edx, 644
SYSCALL_OPEN;
// r13 = fd
mov r13, rax


// create buffer r14[0x100]
sub $0x100, %rsp
mov %rsp, %r14

// read(3, buffer, 10)
mov rdi, r12
mov rsi, r14
mov edx, 10
SYSCALL_READ;

// write(4, buffer, 10)
mov rdi, r13
mov rsi, r14
mov edx, 10
SYSCALL_WRITE;

