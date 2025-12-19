First observation: 
- `check_password` seems to be the only interesting function.
- From `main` it seems I need `r15` to be equal to 1, which happens only if the `cmp #0x9, r12` in `check_password` to equal 0.

After reading the first section of `check_password` seems like (tried half blackbox trial and error) there is a direct correlation between password length and the value in `r12` at the `cmp` line.

### Solution
Password needs to be 8 characters long.
```
>>> AAAAAAAA
```