#Helper function to process TV-Series search results
Function HL_GET_TV_Results
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        $SelectedLink,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Farsi/Persian','English','Arabic','French')]
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
    $RE_EX_EPISODE ='[eExXpP][0-9]{1,2}(?!\d)'
    $TITLE=""
    $RESULT_LIST = New-Object System.Collections.ArrayList
    
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Retriving Release/Title results from subscene.com..." -Id 1 -PercentComplete 25
    # Retrieving Release/Title results form subscene.com
    
    $WEB_SESSION.Cookies.Add($COOKIE)
    $WEB_SESSION.UserAgent= $USER_AGENT
    $RESPONSE = Invoke-WebRequest -uri $SEARCH_URI -WebSession $WEB_SESSION
    
   Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Processing retrieved results" -Id 1 -PercentComplete 50
    $count= $RESPONSE.AllElements.count
    $i=0
    Foreach ($ELEMENT in $RESPONSE.AllElements)
    {
         #Activity Percent Calculation
         $i++
         $precent=(($i / $count)  * 100)
         $status = [string]$i + " of " + [string]$count
          
         #Dome
        if ($ELEMENT.tagName -eq "H2")
        {
            $TITLE = [regex]::Match($ELEMENT.InnerText,"^.+(?= Imdb)").Value
            Write-Host -ForegroundColor Green ("TV-Series : " + $TITLE)
            
            Write-Host -ForegroundColor Green ("Language : " + $Language)
            Write-Host ""
            
        }
        if (($ELEMENT.tagName -eq "TR") -and ($ELEMENT.innerHTML -match $RE_EX_LANG))
        {
            if ($Matches[0] -eq $Language)
            {
                Write-Progress -Activity "Processing..." -Status $status -Id 2 -PercentComplete $precent
                $OBJ = New-Object System.Object
                $OBJ | Add-Member -MemberType NoteProperty -Name "Language" -Value $Matches[0] 
                if ($ELEMENT.InnerHTML -match $RE_EX_LINKS) {$OBJ | Add-Member -MemberType NoteProperty -Name "Link" -Value $Matches[0]}                
                if ($ELEMENT.InnerHTML -match $RE_EX_RELEASE) {$OBJ | Add-Member -MemberType NoteProperty -Name "Release" -Value $Matches[0]}                  
                if ($ELEMENT.InnerHTML -match $RE_EX_OWNER) {$OBJ | Add-Member -MemberType NoteProperty -Name "Owner" -Value $Matches[0]}                  
                if ($ELEMENT.InnerHTML -match $RE_EX_COMMENT) {$OBJ | Add-Member -MemberType NoteProperty -Name "Comment" -Value $Matches[0]}                 
                if ($ELEMENT.InnerHTML -match $RE_EX_EPISODE)
                {
                    [int]$EPNUM=[regex]::Match($Matches[0],"\d+").Value
                    $OBJ | Add-Member -MemberType NoteProperty -Name "Episode" -Value $EPNUM
                }                 
                $RESULT_LIST.Add($OBJ) | Out-Null
            }
        }
    }

    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Processing has been compeleted." -Id 1 -PercentComplete 75
    #if autoselect is disabled the user must select a correct value from search result list
    if (-not $AutoSelect)
    {      
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Waiting for user input..." -Id 1 -PercentComplete 100 
        for ($i=0; $i -lt $RESULT_LIST.Count; $i++)
        {
            
            Write-Host -ForegroundColor Cyan ("  " + $i + "- " + $RESULT_LIST[$i].Release)
            Write-Host -ForegroundColor Gray ("      Owner: " + $RESULT_LIST[$i].Owner)
            Write-Host -ForegroundColor Gray ("      Comment: " + $RESULT_LIST[$i].Comment) 
        }
        [ValidatePattern("\d+")]$SELECTED= Read-Host -Prompt "Please select the correct title number from the list"
         Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Waiting for user input..." -Id 1 -PercentComplete 100 -Completed
        Return $RESULT_LIST[$SELECTED]
    }
    
    #Automatically select the best match from the search result list
    Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status "Trying to select best match from the result list..." -Id 1 -PercentComplete 90
    if ($RESULT_LIST)
    {
        $BestMatch = $RESULT_LIST | where Episode -NotLike "" | group Episode | foreach {$_.Group | select -First 1}
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Id 1 -PercentComplete 100 -Completed
        Return $BestMatch
    }
    else
    {
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status ("We Could not find any suitable subtitle for the selected move") -Id 1 -PercentComplete 100
        Start-Sleep 1
        Write-Progress -Activity ("Processing Subtitle Results for " +$SelectedLink.Description) -Status ("We Could not find any suitable subtitle for the selected move") -Id 1 -PercentComplete 100 -Completed
        return
    }
}
