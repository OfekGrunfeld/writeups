```CPP
int __fastcall main(int argc, const char **argv, const char **envp)
{
  __int64 v3; // rax
  __int64 v4; // rax
  const char *v5; // rax
  __int64 v6; // rdx
  __int64 v7; // rax
  __int64 v8; // rax
  int v9; // ebx
  char v11; // [rsp+Bh] [rbp-45h] BYREF
  unsigned int v12; // [rsp+Ch] [rbp-44h]
  _BYTE v13[40]; // [rsp+10h] [rbp-40h] BYREF
  unsigned __int64 v14; // [rsp+38h] [rbp-18h]

  v14 = __readfsqword(0x28u);
  v3 = std::operator<<<std::char_traits<char>>(&std::cout, "Computing the MD5 hash of /root/flag.txt.... ", envp);
  v4 = std::ostream::operator<<(v3, &std::endl<char,std::char_traits<char>>);
  std::ostream::operator<<(v4, &std::endl<char,std::char_traits<char>>);
  sleep(2u);
  std::allocator<char>::allocator(&v11);
  std::string::basic_string(v13, "/bin/bash -c 'md5sum /root/flag.txt'", &v11);
  std::allocator<char>::~allocator(&v11);
  setgid(0);
  setuid(0);
  v5 = (const char *)std::string::c_str(v13);
  v12 = system(v5);
  if ( v12 )
  {
    v7 = std::operator<<<std::char_traits<char>>(&std::cerr, "Error: system() call returned non-zero value: ", v6);
    v8 = std::ostream::operator<<(v7, v12);
    std::ostream::operator<<(v8, &std::endl<char,std::char_traits<char>>);
    v9 = 1;
  }
  else
  {
    v9 = 0;
  }
  std::string::~string(v13);
  return v9;
}
```