# Subscene-API
Powershell Subscene-API for downloading subtitles automatically from subscene.com website
# Features
- Automatically Download Move or TV-Series Subtitles form the subscene.com website
- Automatically rename subtitles to the vidoe file name 
- Automatically generate search keywords based on the folders structure
- Manual search and download are also possible
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
## Autoselect Mode
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
### Examples
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
## Manual Mode
In this mode, you will be interactively involved in each step of downloading subtitles.
### Examples
```
Get-Subtitle -SearchQuery "The Lighthouse" -Type Movie -VideoDirectory 'D:\Videos\Movie\The Lighthouse (2019)\' -Language English
```
#### Search Results Page
```
Exact
  1- The Lighthouse (2016)
     9 subtitles
  2- The Lighthouse (2019)
     62 subtitles
Close
  3- Edgar Allan Poe's Lighthouse Keeper (2016)
     10 subtitles
  4- El faro de las orcas (The Lighthouse of the Whales) (2016)
     6 subtitles
  5- G.R.L.- Lighthouse (2015)
     1 subtitles (Music Video)
  6- Lighthouse (1999)
     2 subtitles
  7- Mayak (The Lighthouse / Маяк) (2006)
     2 subtitles
  8- The Girl in the Bikini AKA The Lighthouse-Keeper's Daughter (Manina, la fille sans voiles) (1952)
     2 subtitles
  9- The Lighthouse (2016)
     9 subtitles
  10- The Lighthouse (2019)
     62 subtitles
  11- To the Lighthouse (1983)
     1 subtitles
  12- Westlife - Lighthouse (2011)
     1 subtitles (Music Video)
Popular
  13- The Lighthouse (2019)
     62 subtitles
  14- Edgar Allan Poe's Lighthouse Keeper (2016)
     10 subtitles
  15- The Lighthouse (2016)
     9 subtitles
  16- El faro de las orcas (The Lighthouse of the Whales) (2016)
     6 subtitles
  17- The Girl in the Bikini AKA The Lighthouse-Keeper's Daughter (Manina, la fille sans voiles) (1952)
     2 subtitles
  18- Mayak (The Lighthouse / Маяк) (2006)
     2 subtitles
  19- Lighthouse (1999)
     2 subtitles
  20- To the Lighthouse (1983)
     1 subtitles
  21- G.R.L.- Lighthouse (2015)
     1 subtitles (Music Video)
  22- Westlife - Lighthouse (2011)
     1 subtitles (Music Video)
Please select the correct title number from the list: 1
```
#### Realse results page
```
Title : The Lighthouse
Language : English

  1- The.Lighthouse.2016.BDRiP.x264-GUACAMOLE
     The.Lighthouse.2016.BDRiP.x264-GUACAMOLE
     HI | Works with all BluRay/BDRip/BRRip versions -- Please don't reupload on Subscene and give credit where it's due. Thanks!
  2- The.Lighthouse.2016.720p.BluRay.x264-GUACAMOLE
     The.Lighthouse.2016.720p.BluRay.x264-GUACAMOLE
     HI | Works with all BluRay/BDRip/BRRip versions -- Please don't reupload on Subscene and give credit where it's due. Thanks!
  3- The.Lighthouse.2016.1080p.BluRay.x264-GUACAMOLE
     The.Lighthouse.2016.1080p.BluRay.x264-GUACAMOLE
     HI | Works with all BluRay/BDRip/BRRip versions -- Please don't reupload on Subscene and give credit where it's due. Thanks!
  4- The.Lighthouse.2016.BRRip.XviD.MP3-XVID
     The.Lighthouse.2016.BRRip.XviD.MP3-XVID
     HI | Works with all BluRay/BDRip/BRRip versions -- Please don't reupload on Subscene and give credit where it's due. Thanks!
  5- The.Lighthouse.2016.1080p.BluRay.x264.DTS-FGT
     The.Lighthouse.2016.1080p.BluRay.x264.DTS-FGT
     HI | Works with all BluRay/BDRip/BRRip versions -- Please don't reupload on Subscene and give credit where it's due. Thanks!
Please select the correct title number from the list: 1
```
