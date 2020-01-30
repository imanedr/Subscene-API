#Helper function to download subtitle from subscene and put it next to video file
Function HL_Download_Subtitle
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        $SelectedLinks,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('TV-Series','Movie')]
        [string]$Type,
        [Parameter(Mandatory)]
        [string]$VideoDirectory
    )
    Write-Progress -Activity "Downloading the subtitle file from subscene.com" -Status "Creating Web Seassion" -Id 1 -PercentComplete 5
    
    # Constants
    $BASE_DOMAIN = "https://www.subscene.com"
    $USER_AGENT = ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)
    $SEARCH_URI = ""
    $WEB_SESSION = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $COOKIE = New-Object System.Net.Cookie("SortSubtitlesByDate","true","/","subscene.com")  
    $PATH= $VideoDirectory
    $RE_SUBT_FILE = '(^.+(?=\.(fa|fr|ar|en))|^.+(?!\.(fa|fr|ar|en)))'
    $LS_EXISTED_SUB = New-Object System.Collections.ArrayList
    $FileName=""
    
    Write-Progress -Activity "Downloading the subtitle file from subscene.com" -Status "Checking if subtitle already exist" -Id 1 -PercentComplete 15
    
    #Check if subtitle already exist
    $DIR_SUB_LIST = Get-ChildItem -LiteralPath $PATH -Filter *.srt
    $DIR_VID_LIST = Get-ChildItem -Path ($PATH + "\*") -Include *.mkv,*.mp4
    if ($Type -eq "Movie") 
    {
        if ($DIR_SUB_LIST)
        {
            if ($DIR_VID_LIST[0].BaseName -eq ([regex]::Match($DIR_SUB_LIST[0].BaseName,$RE_SUBT_FILE).Value))
            {
                Write-Output "Subtitle already exist`nNoting to do`nExiting"
                Return
            }
        }
    }
    elseif ($Type -eq "TV-Series")
    {
        foreach ($VID in $DIR_VID_LIST)
        {
            foreach ($SUB in $DIR_SUB_LIST)
            {
                if ($VID.BaseName -eq ([regex]::Match($SUB.BaseName,$RE_SUBT_FILE).Value))
                {
                    $LS_EXISTED_SUB.Add($SUB) | Out-Null
                }
            }
        }
        if ($DIR_VID_LIST.Count -eq $LS_EXISTED_SUB.Count)
        {
            Write-Output "Subtitle already exist`nNoting to do`nExiting"
            Return
        }
    }

    Write-Progress -Activity "Downloading the subtitle file from subscene.com" -Status "Downloading the subtitles..." -Id 1 -PercentComplete 25
    #Download Subtitle from subscene.com
    $count= $SelectedLinks.count
    $i=0
    Foreach ($ITEM in $SelectedLinks)
    {
        #Activity Percent Calculation
         $i++
         $precent=(($i / $count)  * 100)
         $status = [string]$i + " of " + [string]$count
         $CurrentOp = ("Processing " + $ITEM.Release )
         Write-Progress -Activity "Downloading..." -Status $status -Id 2 -PercentComplete $precent -CurrentOperation $CurrentOp
         if ($precent -ge 100) {Write-Progress -Activity "Downloading..." -Status $status -Id 2 -PercentComplete $precent -CurrentOperation $CurrentOp -Completed}
        #Done
        $FileName = $ITEM.Link -replace "/","_"
        $FileName = ($PATH + "\" + $FileName + ".zip")
        $WEB_SESSION.Cookies.Add($COOKIE)
        $WEB_SESSION.UserAgent= $USER_AGENT
        $SEARCH_URI = ($BASE_DOMAIN + $ITEM.Link)
        $RESPONSE = Invoke-WebRequest -uri $SEARCH_URI -WebSession $WEB_SESSION
        Foreach ($LINK in $RESPONSE.Links)
        {
            if ($LINK.id -eq "downloadButton")
            {
                
                Write-Progress -Activity "Download Zipped Subtitle" -status ("Downloading Subtitle zip file : " + $ITEM.Release)  -Id 3 -PercentComplete 20
                $SEARCH_URI = ($BASE_DOMAIN + $LINK.href)
                Invoke-WebRequest -uri $SEARCH_URI -WebSession $WEB_SESSION -OutFile $FileName
                
                Write-Progress -Activity "Download Zipped Subtitle" -status ("Download Compeleted.")  -Id 3 -PercentComplete 35
                
                Write-Progress -Activity "Download Zipped Subtitle" -status ("Unzipping downloaded file...")  -Id 3 -PercentComplete 55
                
                Expand-Archive -LiteralPath $FileName -DestinationPath $PATH -ErrorAction SilentlyContinue
                Write-Progress -Activity "Download Zipped Subtitle" -status ("Unzipping Compeleted.")  -Id 3 -PercentComplete 75
                
                Write-Progress -Activity "Download Zipped Subtitle" -status ("Removing the zip file...")  -Id 3 -PercentComplete 95
                
                Remove-Item -LiteralPath $FileName
                Write-Progress -Activity "Download Zipped Subtitle" -status ("Done.") -Id 3 -PercentComplete 100 -Completed
            }
        }
    }
    Write-Progress -Activity "Downloading the subtitle file from subscene.com" -Status "Downloading the subtitles..." -Id 1 -PercentComplete 100 -Completed
}
