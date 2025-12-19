I solved this level at a different pc than mine, took about 2 hours.
The gist of this level is combining return address manipulation to the `unlock_door` function whilst passing the random inserted value which is used to length check;
`   4530:  f140 6c00 1100 mov.b	#0x6c, 0x11(sp)   `
`   4578:  f190 6c00 1100 cmp.b	#0x6c, 0x11(sp)   `
