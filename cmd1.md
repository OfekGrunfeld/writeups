# Description
```
Mommy! what is PATH environment in Linux?
```
---
We are given a minimal, simple script:
```C
#include <stdio.h>  
#include <string.h>  
  
int filter(char* cmd){  
    int r=0;  
    r += strstr(cmd, "flag")!=0;  
    r += strstr(cmd, "sh")!=0;  
    r += strstr(cmd, "tmp")!=0;  
    return r;  
}  
int main(int argc, char* argv[], char** envp){  
    putenv("PATH=/thankyouverymuch");  
    if(filter(argv[1])) return 0;  
    setregid(getegid(), getegid());  
    system( argv[1] );  
    return 0;  
}
```
Which is trying to detect whether `flag | sh | tmp` are in `argv[1]`. Then it runs `argv[1]` if the former was false.
This would be a very simple "shell escape", there should be many solutions, but the first one that came to mind is giving `python` (${which python));
```shell
./cmd1 $(which python)
```
Then we're onto an intractable python shell (as the desired user), and we can read the flag:
```python
>>> from pathlib import Path
>>> Path("./flag").read_text()
'PATH_environment?_Now_I_really_g3t_it,_mommy!\n'
```

# Flag
```
PATH_environment?_Now_I_really_g3t_it,_mommy!
```