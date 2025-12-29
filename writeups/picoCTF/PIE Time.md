# Description
```
Can you try to get the flag? Beware we have PIE!

Additional details will be available after launching your challenge instance.
```
---
We are given the `vuln` binary along its source code.
When debugging the binary, it gives the following input:
> Address of main: 0x61189d16c33d
> Enter the address to jump to, ex => 0x12345: ...

So they want us to find the address of the `win` function and jump to it.
Using `readelf -a` I found the following addresses:
```
	66: 00000000000012a7   150 FUNC    GLOBAL DEFAULT   16 win
    70: 000000000000133d   204 FUNC    GLOBAL DEFAULT   16 main
```

The address of `main` doesn't match what we got whilst debugging, meaning there is some ASLR mechanism enabled. But the offset seems very familiar - both the addresses end in `33d`, which I assume means we could just switch those numbers to match the `win` address as `main` and `win` both start with `1`.


# Flag
```
picoCTF{b4s1c_p051t10n_1nd3p3nd3nc3_28a46dcd}
```