## Praat script to extract pitch and and intensity based on annotated TextGrid file and sound file
## Author: Le Minh Thu (https://thule_5196@bitbucket.org/thule_5196/slp-2ndsem-phonetics-lab.git)

## Requirements:
### Sound files
### Textgrid files that had been annotated. 
#### When annotating: pitch is point tier, and is tier 2. Intensity is point tier and is tier 3
### praat.exe at a easy to access directory
### praatcon is no longer needed in recent version

## Run step: 
### "C:\Program Files\Praat.exe" --run "get_intensity_data.praat"
### I was lazy to rename it to a better name

## Prepare root directory for reading and writing files
directory$ = "D:\slp 2nd term assignment\Focus-assignment\Focus-assignment\"

## clear out old outputs: 
filedelete 'directory$'formant-log.csv
filedelete 'directory$'intensity-log.csv

## prepare header row of 2 new files, pitch and intensity are saved in seperate files 

header_row$ = "Sentence" + "," + "repetition" + "," + "Mel1" + "," + "Mel2" + "," + "wear1" + "," + "wear2" + "," + "li1" + "," + "ly2" + newline$

header_row$ > 'directory$'pitch-log.csv

header_row_intensity$ = "Sentence" + "," + "repetition" + "," + "Pt1" + "," + "Pt2" + "," + "Pt3"+ newline$

header_row_intensity$ > 'directory$'intensity-log.csv

## read data from root directory. Read all file name including extension in as a list, then loop through the list, chop off the extension
## and read in the text grid and process one by one.
## file list can also be specified to achieve different order in the results

Create Strings as file list...  list 'directory$'*.wav

number_files = Get number of strings

## main loop
for j from 1 to number_files

	## get current file name and chop off extension
    select Strings list
    current_token$ = Get string... 'j'
    appendInfo: current_token$ + ": "

    Read from file... 'directory$''current_token$'
    object_name$ = selected$ ("Sound")

	## create 2 more praat object, pitch and intensity
    select Sound 'object_name$'
    To Pitch... 0.01 100 250

	select Sound 'object_name$'
    To Intensity... 100 0.01

	## read in the text grid
    Read from file... 'directory$''object_name$'.TextGrid

    select TextGrid 'object_name$'

	## select tier 2 , which is pitch to start processing
    number_of_points = Get number of points... 2
    
    attempt = 1
	appendInfo: number_of_points
    for b from 1 to number_of_points
		## count attempts to split line 
		if b = 1 or b= 7 or b=13 
			fileappend "'directory$'pitch-log.csv" 'object_name$' ,  'attempt:0' ,
			attempt = attempt +1
		endif

		## by the end of the loop, context changes, the selected object is no longer the textgrid so need to call it here to switch it back
		select TextGrid 'object_name$'
		p = Get time of point: 2, b 

		## extract pitch
		select Pitch 'object_name$'
		f_zero = Get value at time... 'p' Hertz Linear

		## format it into csv format and dump to file
		if b = 6 or b = 12 or b = 18
			endl$ = newline$
		else
			endl$ =  ","
		endif
		fileappend "'directory$'pitch-log.csv" 'f_zero:3' 'endl$'

    endfor

	## switch context to textgrid, select tier 3 to processing which is intensity
	select TextGrid 'object_name$'
    number_of_points_intensity = Get number of points... 3

    appendInfo: number_of_points_intensity
    
    attempt = 1
    for b from 1 to number_of_points_intensity
		## count attempts to split line   
		if b = 1 or b= 4 or b=7 
			fileappend "'directory$'intensity-log.csv" 'object_name$' ,  'attempt:0' ,
			attempt = attempt +1
		endif
		
		## by the end of the loop, context changes, the selected object is no longer the textgrid so need to call it here to switch it backS
		select TextGrid 'object_name$'
		
		p = Get time of point: 3, b 

		## extract intensity
		select Intensity 'object_name$'
		intensity = Get value at time... 'p' Cubic
		
		## format it into csv format and dump to file
		if b = 3 or b = 6 or b = 9
			endl$ = newline$
		else
			endl$ =  ","
		endif

		fileappend "'directory$'intensity-log.csv" 'intensity:3' 'endl$'

    endfor

endfor


## remove all objects loaded into memory, clean up
select all
Remove







