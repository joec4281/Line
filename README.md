# Line
Display line *n* from a text file,   
or line *n* from the Windows Clipboard,   
based on the value of Windows Environment Variable **OptionBase**  
  
I wrote this utility for use with Take Command Console (TCC).

TCC uses option base 0 for many,  
if not all,  
of its functions.  
  
I prefer the first line in a file to be line 1,  
not line 0. 

```dos
E:\...\Line>set optionbase=1

E:\...\Line>line.exe r:\test.txt 1
Line 1

E:\...\Line>set optionbase=0

E:\...\Line>line.exe r:\test.txt 1
Line 2
```

I have created a User-Defined Function to replace the internal **@LINE** function;

```dos
E:\...\Line>function line=`%@execstr[line.exe %1 %2]`

E:\...\Line>which @LINE
@LINE is a user-defined variable function (%@execstr[line.exe %1 %2])
```

It is used the same as the internal **@LINE** function.  
  
**NOTE:** The internal **@LINE** function does not support the -0 argument.

```dos
E:\...\Line>set optionbase=0

E:\...\Line>echo %@LINE[r:\test.txt 0]
Line 1

E:\...\Line>echo %@LINE[r:\test.txt -0]
Line 5

E:\...\Line>set optionbase=1

E:\...\Line>echo %@LINE[r:\test.txt 0]
EOF

E:\...\Line>echo %@LINE[r:\test.txt 1]
Line 1

E:\...\Line>echo %@LINE[r:\test.txt -0]
Line 5
```
  
**Line.exe** does **NOT** support;  
* the line number in hexadecimal format
* input from standard input if you specify **CON** as the filename
* redirected input to **@LINE**
* the TCC clipboards (**CLIP0: - CLIP9**:)
* the TCC temporary files (**TMP0: - TMP9:**)
  
Here's how I compile **line.cs** on my Windows 10 system;

```dos
E:\...\Line>which csc
csc is an alias : "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\Roslyn\csc.exe"

E:\...\Line>csc line.cs
Microsoft (R) Visual C# Compiler version 4.14.0-3.26424.7 (a528c90a)
Copyright (C) Microsoft Corporation. All rights reserved.
```
  
Review the contents of **LineTest.btm** for a demonstration on how to use **Line.exe**
  
---
**2026/10/26**  
I have created **Line.ps1**,    
which does the same thing as **Line.cs**  
  
Review the contents of **LineTestPS1.btm** for a demonstration on how to use **Line.ps1** from Take Command Console (TCC).  
