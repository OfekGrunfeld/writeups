# Description
```
We all make mistakes, let's move on.
(don't take this too seriously, no fancy hacking skill is required at all)
This task is based on real event
```
---

Source:
```C
#include <stdio.h>
#include <fcntl.h>

#define PW_LEN 10
#define XORKEY 1

void xor(char* s, int len){
	int i;
	for(i=0; i<len; i++){
		s[i] ^= XORKEY;
	}
}

int main(int argc, char* argv[]){
	
	int fd;
	if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
		printf("can't open password %d\n", fd);
		return 0;
	}

	printf("do not bruteforce...\n");
	sleep(time(0)%20);

	char pw_buf[PW_LEN+1];
	int len;
	if(!(len=read(fd,pw_buf,PW_LEN) > 0)){
		printf("read error\n");
		close(fd);
		return 0;		
	}

	char pw_buf2[PW_LEN+1];
	printf("input password : ");
	scanf("%10s", pw_buf2);

	// xor your input
	xor(pw_buf2, 10);

	if(!strncmp(pw_buf, pw_buf2, PW_LEN)){
		printf("Password OK\n");
		setregid(getegid(), getegid());
		system("/bin/cat flag\n");
	}
	else{
		printf("Wrong Password\n");
	}

	close(fd);
	return 0;
}
```
In the same manner as one of the previous levels, we could debug this program and see what is copied to `pw_buf`, then enter our input accordingly - which will be the inverse of the `xor` function. Inverting xor is quite simple:
```python
xor(pw_buf2) = [ch ^ 1 for ch in pw_buf2] 
so
xor(xor(pw_buf2)) = [ch ^ 1 for ch in [ch ^ 1 for ch in pw_buf2]] = pw_buf2
```

- Debugging doesn't work as intended, it can't open the `password` file for some reason.
Noting that, I saw at first glance that the following if statement seems syntactically wrong:
```C
if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
	...
}
```
I read online about what happens when you use an assignment and a boolean operation in this manner, and found about `C Operator Precedence` in [cppreference](https://en.cppreference.com/w/c/language/operator_precedence.html). Based on that table, the relational operator happens before assignment in the if statement, meaning that:
```C
fd = (open("/home/mistake/password",O_RDONLY,0400) < 0)
```
At this assignment, `open` should return a positive `fd` (3), so `fd` will always equal `3 < 0` which is `0` (false) - meaning `stdin` (I believe that's the reason we are prompted for two inputs in `stdin` when starting `~/mistake` normally).

So `pw_buf` is inputted via `stdin`, as well as `pw_buf2`... We just have to put two strings which match the xor mathematical proof I provided earlier;
```C
$ ./mistake
> AAAAAAAAAA // 0x41
> input password: @@@@@@@@@@
```

# Flag
```
Mommy_the_0perator_priority_confuses_me
```

