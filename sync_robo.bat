:INIT
ECHO OFF
rem Usage: no arguments -> source set to default and destination prompted
rem        %1           -> default source and %1 is destination
rem        %1 %2        -> backup from %1 to %2
rem Update here: https://github.com/xiao-shen/sync_robo
rem 
rem Use of variables replaced at execution time (enclosed with exlamation marks instead of percent characters)	
setlocal EnableDelayedExpansion
CLS
ECHO Backup script ****
ECHO Do not include last backslash in path names please
ECHO Launched from %~dp0
ECHO:
rem This is a comment. 

rem WARNING !
rem We do not guarantee any possible DATA LOSS. Use this script with attention. Thank you. 
rem If you misuse this script, you can lose all the data on your PC. 
rem We recommend you to manually copy your data on an external drive. And disconnect it before testing this script!

rem This script replicates folders from a source (left) to a destination (right).
rem You can select the subfolders you want to replicate in a file named "sync_robo_list.txt", one subfolder per line. 
rem The files different from the left side are overwritten on the right side. Deletes are replicated from the left side to the right side. 
rem So, once again, be careful !

rem Choice between relative or absolute path
GOTO RELATIVEPATH
:ABSOLUTEPATH
SET "usualSource=D:"
if [%2]==[] (
  rem v v v v v v v v v v v v v v v v v v v v v v v v v
  rem Here is the source folder !!!
  rem Give the path without last backslash !
  SET "left=D:"
  rem      ^^^
  rem The destination folder will be asked at run time. 
  rem ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
  rem Set to 1 if you need to confirm the source
  SET "confirmSource=1"
  rem Source confirmation
  if [!left!]==[%usualSource%] (
    ECHO Copying from '!left!' as usual.
  ) else (
    ECHO WARNING: Source was changed from usual to !left! 
    SET "confirmSource=1"
  )
)
GOTO AFTERPATH
  
:RELATIVEPATH
if [%2]==[] (
  rem The source folder is determined by the location of the script file
  rem v v v v v v v v v v v v v v v v v v v v v v v v v
  rem Here is the source folder, defined relative to the batch file location !!!
  rem Give the path without last backslash !
  SET "left=%~dp0..\.."
  rem            ^^^
  rem The destination folder will be asked at run time. 
  rem ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^
  rem Set to 1 if you need to confirm the source
  SET "confirmSource=1"
  ECHO:
  ECHO Source set by default to relative path: !left!
)

:AFTERPATH
if not [%2]==[] (
  rem Source from first argument if present
  SET left=%1
  ECHO Source set by argument to: !left! 
  SET "confirmSource=1"
)

rem Source confirmation by user
if %confirmSource%==1 (
  CHOICE /C YN /T 5 /D Y /M "Do you confirm the source folder "
  IF ERRORLEVEL ==2 (
    SET /p left= Please give the source folder: 
  )
)
ECHO:

rem Options fot ROBOCOPY
rem CAUTION  !!!!
rem This option (/Purge) deletes files on the destination side if they are not in the source side. 
rem This is useful if you rename or move files. You can remove this option for your tests. 
SET "opt=/Purge"
rem  OPT^^^^^^^

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
if [%1]==[] (
  SET /p right= Please give a destination folder: 
) else (
  if [%2]==[] (
    SET right=%1
  ) else (
    SET right=%2
  )
  ECHO Destination set by argument to: !right! 
  CHOICE /C YN /T 5 /D Y /M "Do you confirm the destination folder "
  IF ERRORLEVEL ==2 (
    SET /p right= Please give a destination folder: 
  )
)

rem Parses the source's drive letter.
SET Lletter=%left:~0,1%
rem Parses the destination's drive letter.
SET Rletter=%right:~0,1%

rem Some user info.
:SUMMARY
ECHO:
ECHO Folders to sync:
type %fol%
ECHO:
ECHO:
ECHO ----
ECHO Left Source From = %left%
rem Give volume information on source and skip a line
VOL %Lletter%:
ECHO ----
ECHO Right Destination To = %right%
rem Give volume information on destination
VOL %Rletter%:
ECHO ----
ECHO Options %opt%
ECHO ----
CHOICE /C YN /M "Do you want to run ROBOCOPY " 
ECHO %ERRORLEVEL%
IF %ERRORLEVEL%==1 GOTO BACKUP
ECHO Canceled
GOTO EOF



rem The core function. 
:BACKUP
ECHO Beginning ...
SET "now=%date%; %time%"
echo last sync at %now%; from %left% to %right%: > %log%
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
ECHO %left%;%right%; %now%; >> %right%\%hist%
ECHO %left%;%right%; %now%; >> %hist%



ECHO OFF
ECHO:
ECHO:
ECHO ---
ECHO %left% to %right%, %now%
VOL %Rletter%:
ECHO Finished. Open %log% to see the screen output again. 
:END
PAUSE
exit /B 0
:EOF
rem returns error code
exit /B 1
