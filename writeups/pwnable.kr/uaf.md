# Description
```
Do you wanna try some Use-After-Free vulnerability exploitation?
```
---
Using IDA and naming some variables:
```C++
int __fastcall __noreturn main(int argc, const char **argv, const char **envp)
{
  Human *human_1; // rbx
  __int64 v4; // rdx
  Human *woman_1; // rbx
  int fd_on_argv2; // eax
  __int64 useless_stdout_temp; // rax
  Human *human_1_pointer_2; // rbx
  Human *woman_1_pointer_2; // rbx
  unsigned int char_allocator; // [rsp+1Ch] [rbp-64h] BYREF
  Human *human_1_pointer; // [rsp+20h] [rbp-60h]
  Human *woman_1_pointer; // [rsp+28h] [rbp-58h]
  size_t nbytes; // [rsp+30h] [rbp-50h]
  void *buf; // [rsp+38h] [rbp-48h]
  _BYTE name[40]; // [rsp+40h] [rbp-40h] BYREF
  unsigned __int64 v16; // [rsp+68h] [rbp-18h]

  v16 = __readfsqword(0x28u);

  std::allocator<char>::allocator(&char_allocator, argv, envp);
  std::string::basic_string<std::allocator<char>>(name, "Jack", &char_allocator);
  human_1 = (Human *)operator new(0x30u);
  Man::Man(human_1, name, 25);
  human_1_pointer = human_1;
  // Destruct
  std::string::~string(name);
  std::allocator<char>::~allocator(&char_allocator);

  std::allocator<char>::allocator(&char_allocator, name, v4);
  std::string::basic_string<std::allocator<char>>(name, "Jill", &char_allocator);
  woman_1 = (Human *)operator new(0x30u);
  Woman::Woman(woman_1, name, 21);
  woman_1_pointer = woman_1;
  // Destruct
  std::string::~string(name);
  std::allocator<char>::~allocator(&char_allocator);
  while ( 1 )
  {
    while ( 1 )
    {
      std::operator<<<std::char_traits<char>>(&std::cout, "1. use\n2. after\n3. free\n");
      // inputing string into freed std:allocator<char>
      std::istream::operator>>(&std::cin, &char_allocator);
      if ( char_allocator == 3 )
        break;
      if ( char_allocator <= 3 )
      {
        if ( char_allocator == 1 )
        {
          (*(void (__fastcall **)(Human *))(*(_QWORD *)human_1_pointer + 8LL))(human_1_pointer);
          (*(void (__fastcall **)(Human *))(*(_QWORD *)woman_1_pointer + 8LL))(woman_1_pointer);
        }
        else if ( char_allocator == 2 )
        {
          // Open fd on argv[2], read (int)argv[1] bytes
          // - never closed
          // - stdin, stdout
          nbytes = atoi(argv[1]);
          buf = (void *)operator new[](nbytes);
          fd_on_argv2 = open(argv[2], 0);
          read(fd_on_argv2, buf, nbytes);
          useless_stdout_temp = std::operator<<<std::char_traits<char>>(&std::cout, "your data is allocated");
          std::ostream::operator<<(useless_stdout_temp, &std::endl<char,std::char_traits<char>>);
        }
      }
    }
    // Check pointers of humans not falsey -> delete
    human_1_pointer_2 = human_1_pointer;
    if ( human_1_pointer )
    {
      Human::~Human(human_1_pointer);
      operator delete(human_1_pointer_2, 0x30u);
    }
    woman_1_pointer_2 = woman_1_pointer;
    if ( woman_1_pointer )
    {
      Human::~Human(woman_1_pointer);
      operator delete(woman_1_pointer_2, 0x30u);
    }
  }
}
```

## Directions
- allocator usage
`std::allocator<char>::allocator(&char_allocator, name, v4);`

- name string
`_BYTE name[40]`

- Write into buffer
We have some arbitrary access for writing bytes into a buffer (see section `char_allocator == 2`), and we also have the power to execute a function which is `0x8` bytes after the `human_1_pointer.`

- `give_shell`
Whilst debugging, I found that the Human structs holds a function called `give_shell` which runs "/bin/sh".
For this to run, we'll need to make this line:
```C++
(*(void (__fastcall **)(Human *))(*(_QWORD *)human_1_pointer + 8LL))(human_1_pointer);
```
execute `human_1_pointer` and not `human_1_pointer + 8LL`