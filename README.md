# Subscene-API
Powershell Subscene-API for downloading subtitles automatically from subscene.com website
# Installation
- Create "Subscene-API" folder in the C:\Program Files\WindowsPowerShell\Modules
- Copy all files and folders into the "Subscene-API" folder
- The folder structure should be like this :
```
 └───Subscene-API
	    │   Subscene-API.psd1
	    │   Subscene-API.psm1
	    │
	    ├───Private
	    │       HL_Download_Subtitle.ps1
	    │       HL_GET_Movie_Results.ps1
	    │       HL_GET_TV_Results.ps1
	    │       HL_RENAME_SUBTITLE.ps1
	    │       HL_SEARCH_SUBSCENE.ps1
	    │
 	    └───Public
```
# Usage
There are to download mode in the API :
### Autoselect Mode
- Based on the folder naming tries to extract search keywords from Movie and TV-Series folders and download the best match for the selected
- For the best accuracy, the folder naming for Movie and TV-Series should be like this :
```
	For Movie : [Movie Name] (Year) ==> for Example : The Lighthouse (2019)
	For TV-Series : [Series Name] \ Season [Season Number] ==> For Example : Friends\Season 01
```

	└───Friends
   	 ├───Season 01
   	 ├───Season 02
    	 ├───Season 03
    	 ├───Season 04
    	 └───Season 05

