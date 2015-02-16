:INIT
ECHO OFF
CLS
ECHO Backup script ****
rem This is a comment. 

rem WARNING !
rem We do not guarantee any possible DATA LOSS. Use this script with attention. Thank you. 

rem This script replicates folders from a source (left) to a destination (right).
rem You can select the subfolders you want to replicate in a file named "sync_robo_list.txt", one subfolder per line. 
rem The files different from the left side are overwritten on the right side. Deletes are replicated from the left side to the right side. 
rem So, once again, be careful !

rem Here is the source folder. 
rem Give the path without last backslash !
SET "left=D:"
rem The destination folder will be asked at run time. 

rem "sync_robo_list.txt" is the file containing the folder list
rem Write one folder per line. You can comment a line by using a semicolon (;)
rem Example:
rem Folder1\SubFolder\
rem ; this is a commented line
SET "fol=sync_robo_list.txt"
rem There is a log file in the working directory and in the destination folder. 
rem It records the times you ran this script. 
SET "hist=sync_robo_hist.log"
rem Another log file stores the synchronization screen output. 
SET "log=sync_robo.log"

rem User is prompted the destination folder here (right side). 
ECHO Do not include last backslash please
if [%1]==[] (SET /p right= Please give a destination folder: ) else (SET right=%1)

rem Options fot ROBOCOPY
rem CAUTION: this option (/Purge) deletes files on the destination side if they are not in the source side. 
rem This is useful if you rename or move files. You can remove this option for your tests. 
SET "opt=/Purge"
rem Parses the destination's drive letter.
SET letter=%right:~0,1%

rem Some user info.
:SUMMARY
ECHO:
ECHO Folders to sync:
type %fol%
ECHO:
ECHO:
ECHO Left = %left%
ECHO Right = %right%
rem Give volume information on destination
VOL %letter%:
ECHO Options %opt%
ECHO ----
CHOICE /C yn /N /M "Do you want to run ROBOCOPY (Y for OK) ?"
ECHO %ERRORLEVEL%
IF %ERRORLEVEL%==1 GOTO BACKUP
GOTO EOF

rem The core function. 
:BACKUP
ECHO Beginning ...
echo last sync on %date% at %time%; from %left% to %right%: > %log%
ECHO ON
:LOOP
rem The loop reads into the file given in %fol and skips lines beginning with ;. 
rem Output %i is in one column (no delimiters and 1 token) or else it would use %j, %k etc. 
for /F "eol=; tokens=1* delims=" %%i in (%fol%) do (
rem Uses ROBOCOPY
rem Robocopy only copies the new files from source to destination
rem Options /r,/w to have better accuracy (retry and wait), /e copies the whole folder hierarchy, /tee shows the screen output and /Purge deletes files deleted from the other side (declared in variable %opt)
rem The source and destination are parameterized
robocopy %left%\%%i %right%\%%i /e /r:1 /w:2 /log+:%log% /tee %opt%
)
:HIST
rem LOG file: keep track of the times you ran this script, on the destination and the source. 
ECHO %left%;%right%; %date%; %time%; >> %right%\%hist%
ECHO %left%;%right%; %date%; %time%; >> %hist%

ECHO OFF
ECHO:
ECHO:
ECHO ---
ECHO %left% to %right%, %date% %time%
VOL %letter%:
ECHO Finished. Open %log% to see the screen output again. 
:END
PAUSE
exit /B 0
:EOF
rem returns error code
exit /B 1
