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
```
Get-Subtitle [[-SearchQuery] <string>] [-Type] <string> [-VideoDirectory] <string> [-Language] <string> [-AutoSelect] [<CommonParameters>]
```
##### SearchQuery
Optional string parameter for a search query that will be submitted in the subscene.com, if you don't define it, it will be generated automatically
##### Type
Mandatory Autocomplete subtitle type parameter, it could be "Movie" or "TV-Series".
#### VideoDirectory
Mandatory string parameter it shoud point to the video files directory. For example :
```
D:\Videos\Movies\The Lighthouse (2019)\
D:\Videos\TV-Series\Friends\Season 01\
```
#### Language
Mandatory autocomplete string parameter that accepts these values :
```
Farsi/Persian
English
Arabic
French
```
#### AutoSelect
Optional switch parameter, if you enable it, the script tries to do all tasks without user interaction.
### Autoselect Mode
- Based on the folder naming tries to extract search keywords from Movie and TV-Series folders and download the best match for the selected
- For the best accuracy, the folder naming for Movie and TV-Series should be like this :
```
	For Movie : [Movie Name] (Year) ==> for Example : The Lighthouse (2019)
	For TV-Series : [Series Name] \ Season [Season Number] ==> For Example : Friends\Season 01
```
```
└───Friends
    ├───Season 01
    ├───Season 02
    ├───Season 03
    ├───Season 04
    └───Season 05
```
#### Examples
##### with SearchQuery :
```
Get-Subtitle -SearchQuery "The Lighthouse" -Type Movie -VideoDirectory 'D:\Videos\Movie\The Lighthouse (2019)\' -Language English -AutoSelect
```
##### Without SearchQuery :
```
Get-Subtitle -Type Movie -VideoDirectory 'D:\Videos\Movie\The Lighthouse (2019)\' -Language English -AutoSelect
```
##### Search for TV-Series
```
Get-Subtitle -SearchQuery "Friends - Season one" -Type TV-Series -VideoDirectory 'D:\Videos\TV-Series\Friends\Season 01\' -Language English -AutoSelect
or
Get-Subtitle -Type TV-Series -VideoDirectory 'D:\Videos\TV-Series\Friends\Season 01\' -Language English -AutoSelect
```
