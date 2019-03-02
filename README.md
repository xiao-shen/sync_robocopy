# sync_robo_copy
Windows script to replicate your files from a source directory (left) to a destination directory (right). Only the modified files are copied thanks to robocopy, according to the modification date. 

The files different from the left side are overwritten on the right side. 
Deletes are replicated from the left side to the right side. 
So be careful !

__WARNING !__
We do not guarantee any possible _DATA LOSS_. Use this script with attention. Thank you. 
We recommend you to manually copy your data on a third external drive before. And to disconnect it before testing this script!

## Script customisation

Please read this section before using the script. 

### Default source directory
The source directory can either be set at an absolute location or a path relative to the script location. 
At line 80, replace the `GOTO` command by:
- `GOTO RELATIVEPATH` in order to set a default source which is relative to the script location. The path can be customized line 110 for example `SET "left=%scriptLocation%"` or `SET "left=%scriptLocation%\..\.."`. 
- `GOTO ABSOLUTEPATH` in order to set a constant source directory. The directory can be customized line 87 for example `SET "left=D:"`. 

### Subfolder list
You must define the subfolders of the source directory you want to replicate in a file named "sync_robo_list.txt", one subfolder per line. This text file must be located in the same folder as the script. 
The format for the text file is the following. The first backslash (__\__) at the beginning of each line is important.
```
; this is a comment
\Subfolder1\
\Subfolder2\
```

### Specifying the source and destination

You must not enter the last backslash when specifying the source and destination. For instance, `D:` is correct whereas `D:\` is incorrect

## Usage of the script
```
<no arguments> -> source set to default and destination prompted
%1             -> default source and %1 is destination
%1 %2          -> backup from %1 to %2
```

