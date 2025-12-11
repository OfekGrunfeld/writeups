# Description
```
Daddy, teach me how to use random value in programming!
```
---
This time we need to crack a pseudo random number generator.
Source:
```C
#include <stdio.h>  
  
int main(){  
    unsigned int random;  
    random = rand();   // random value!  
  
    unsigned int key=0;  
    scanf("%d", &key);  
  
    if( (key ^ random) == 0xcafebabe ){  
       printf("Good!\n");  
       setregid(getegid(), getegid());  
       system("/bin/cat flag");  
       return 0;  
    }  
  
    printf("Wrong, maybe you should try 2^32 cases.\n");  
    return 0;  
}
```

Read about some cryptography exploits on `rand` for a couple of minutes which basically stated that rand works with a seed and therefore will always return the same value into `random`.
But before jumping on that, I noticed the random number is generated before out input - so we could just debug it and apply the inverse of `xor` (`=xor`) with `0xcafebabe`; `random ^ 0xcafebabe = key`.
The value generated was:
```
random = 0x6b8b4567
```
Using our equation:
```
key = 0x6b8b4567 ^ 0xcafebabe
key = 0xa175ffd9 (decimal 2708864985)
```

# Flag
```
m0mmy_I_can_predict_rand0m_v4lue!
```