
#Helper function to process search results to select correct release
Function HL_GET_Movie_Results
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        $SelectedLink,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        #[ValidateSet('Farsi/Persian','English','Arabic','French')]
        [string]$Language,
        [Parameter(Mandatory=$False)]
        [switch]$AutoSelect
    )
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Creating Web Seassion" -Id 1 -PercentComplete 5
     # Constants
    $BASE_DOMAIN = "https://www.subscene.com"
    $USER_AGENT = ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)
    $SEARCH_URI = ($BASE_DOMAIN + $SelectedLink.Link)
    $WEB_SESSION = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $COOKIE = New-Object System.Net.Cookie("SortSubtitlesByDate","true","/","subscene.com")
    $RE_EX_LINKS = '(?<=<[aA] [hrefHREF]{4}=").+?(?=">)'
    $RE_EX_LANG = '(?<=icon">).+?(?=\s+<)'
    $RE_EX_RELEASE = '(?<=<SPAN>).+?(?=<\/SPAN>)'
    $RE_EX_OWNER = '(?<=">).+?(?=\s+<\/A>)'
    $RE_EX_COMMENT = '(?<=<DIV>).+?(?=&)'
    $TITLE=""
    $RESULT_LIST = New-Object System.Collections.ArrayList
    $COUNTER = 1
    
    
    # Retrieving Release/Title results form subscene.com
    #Write-Host -ForegroundColor Gray "Retriving Release/Title results from subscene.com..."
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Retriving Release/Title results from subscene.com..." -Id 1 -PercentComplete 25
    $WEB_SESSION.Cookies.Add($COOKIE)
    $WEB_SESSION.UserAgent= $USER_AGENT
    $RESPONSE = Invoke-WebRequest -uri $SEARCH_URI -WebSession $WEB_SESSION
    
    #Write-Host -ForegroundColor Gray "Proccessing the results"
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Processing retrieved results" -Id 1 -PercentComplete 50
    Foreach ($ELEMENT in $RESPONSE.AllElements)
    {
        if ($ELEMENT.tagName -eq "H2")
        {
            $TITLE = [regex]::Match($ELEMENT.InnerText,"^.+(?= Imdb)").Value
            if (-not $AutoSelect)
            {
                Write-Host -ForegroundColor Green ("Title : " + $TITLE)
                Write-Host -ForegroundColor Green ("Language : " + $Language)
                Write-Host ""
            }
        }
        if (($ELEMENT.tagName -eq "TR") -and ($ELEMENT.innerHTML -match $RE_EX_LANG))
        {
            if ($Matches[0] -eq $Language)
            {
                $OBJ = New-Object System.Object
                $OBJ | Add-Member -MemberType NoteProperty -Name "Language" -Value $Matches[0] 
                $ELEMENT.InnerHTML -match $RE_EX_LINKS | Out-Null
                $OBJ | Add-Member -MemberType NoteProperty -Name "Link" -Value $Matches[0]
                $ELEMENT.InnerHTML -match $RE_EX_RELEASE | Out-Null
                $OBJ | Add-Member -MemberType NoteProperty -Name "Release" -Value $Matches[0]  
                $ELEMENT.InnerHTML -match $RE_EX_OWNER | Out-Null
                $OBJ | Add-Member -MemberType NoteProperty -Name "Owner" -Value $Matches[0]  
                $ELEMENT.InnerHTML -match $RE_EX_COMMENT | Out-Null
                $OBJ | Add-Member -MemberType NoteProperty -Name "Comment" -Value $Matches[0] 
                $RESULT_LIST.Add($OBJ) | Out-Null
                if (-not $AutoSelect)
                {
                    Write-Host -ForegroundColor Cyan ("  " + $COUNTER + "- " + $OBJ.Release)
                    Write-Host -ForegroundColor Gray ("     " + $OBJ.Owner)
                    Write-Host -ForegroundColor Gray ("     " + $OBJ.Comment)
                    $COUNTER++
                }
                
            }
        }
    }
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Processing has been compeleted." -Id 1 -PercentComplete 75
    #if autoselect is disabled the user must select a correct value from search result list
    if (-not $AutoSelect)
    {
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Waiting for user input..." -Id 1 -PercentComplete 100
        [ValidatePattern("\d+")]$SELECTED= Read-Host -Prompt "Please select the correct title number from the list"
        Return $RESULT_LIST[$SELECTED -1]
    }

    #Automatically select the best match from the search result list
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Trying to select best match from the result list..." -Id 1 -PercentComplete 90
    if ($RESULT_LIST)
    {
        $BestMatch = ($RESULT_LIST | group Link | sort Count  -Descending | select -First 1).Group[0]
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status ("Selected Best Match : " + $BestMatch.Release) -Id 1 -PercentComplete 100
        Return $BestMatch
    }
    else
    {
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status ("We Could not find any suitable subtitle for the selected move") -Id 1 -PercentComplete 100
        Start-Sleep 2
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -id 1 -Completed

        return
    }
    
    
}