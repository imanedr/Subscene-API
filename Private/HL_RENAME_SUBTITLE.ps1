Function HL_RENAME_SUBTITLE  
{
 [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]$VideoDirectory,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Farsi/Persian','English','Arabic','French','Indonesian')]
        [string]$Language,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Movie','TV-Series')]
        [string]$Type
    )

    Switch ($Language) 
    {
        "Farsi/Persian" {$EXTENSION=".fa.srt"}
        "English" {$EXTENSION=".en.srt"}
        "Arabic" {$EXTENSION=".ar.srt"}
        "French" {$EXTENSION=".fr.srt"}
		"Indonesian" {$EXTENSION=".ind.srt"}
    }
    Write-Progress -Activity "Renaming Subtitles to vide file name..." 

    $SUB_NAME=""
    
    $VIDEO_FILES= Get-childItem -Path ($VideoDirectory + "\*") -Include *.mkv, *.mp4
    
    $SUB_FILES= Get-childItem -Path $VideoDirectory -Filter *.srt
    If ($Type -eq "TV-Series")
    {
        $RE_EX_EPISODES="((s\d+e\d+|x\d+)|(\d+x\d+))"
        foreach ($VID in $VIDEO_FILES)
        {
        	if ($VID.BaseName -Match $RE_EX_EPISODES)
            {
        		$match1=$Matches[0]
        		foreach ($sub in $SUB_FILES)
                {
        			if ($sub.BaseName -Match $match1)
                    {
        				$SUB_NAME=$VID.BaseName + $EXTENSION
        				Write-Host -ForegroundColor Cyan $sub.name "==>" $SUB_NAME
        				Rename-Item -LiteralPath $sub.fullname -NewName $SUB_NAME -ErrorAction Ignore
                       
        			}
        		}
        	}
        }
    }
    else
    {
        if ($VIDEO_FILES -and $SUB_FILES)
        {
            Rename-Item -LiteralPath $SUB_FILES[0].FullName -NewName ($VIDEO_FILES[0].BaseName + $EXTENSION) -ErrorAction Ignore
        }
    }
    Write-Progress -Activity "Renaming Subtitles to vide file name..."  -Completed
}
