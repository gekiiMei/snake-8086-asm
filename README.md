super fucking inefficient :kekw: iom sorry

tl;dr
read scores from file and put into scores array
insert current score into array
sort 
((not the best, better to do a linear search for the first possible slot during input, then just shift the rest of the bits to the right but this is the easiest way to do this rn))

structure of the array;
```
byte 1 = number of scores stored (this gets capped at 5 when storing into file. during sorting, it can go beyond 5 so it sortts properly, but any recrods beyond the 5th one are truncated when saving into the file)
bytes 2-4 = the username; first of the records
byte 5 = string terminator
bytes 6-7 = score
this repeats until the end of the file
ex.
            05h                   ;first byte, indicates that there are 5 records
            'JOE$', 000h, 010h    ;3 bytes for 'J''O''E', then the 4th byte for '$'. byte 5 for the higher byte of the score, byte 6 for the lower byte of the score
            'BEN$', 000h, 00Fh
            'GEK$', 000h, 009h
            'KIM$', 000h, 004h
            'JON$', 000h, 001h
```

FILES:
```
  fileio.asm <- my schizophrenia in all its glory, contains the logic for file i/o and sorting 
  scores.asm <- prints the records (not formatted for UI, just prints them for terminal and shows how u can read and access the records)
    NOTE: change the filename to the dir u want to put the sample data in. MAKE SURE this change is also reflected in fileio.asm
    
  main.asm <- actual game, w/ the implementation
    NOTE: has its own separate dir (snekscor.txt) for its file, u can change it. u can link scores.asm to this file to display its contents

  DATA.txt <- place it wherever u set it to (default as it is is TASM dir\progs\snek\data.txt)
  SNEKSCOR.txt <- smae thing 

NOTE! PLACE FILES IN PROGS\SNEK (OR WHEREVER SCORES.ASM AND MAIN.ASM ARE)! READING BECOMES FUCKED OTHERWISE
```
