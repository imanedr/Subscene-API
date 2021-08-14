#The first step is to search form title on the subscene website
Function HL_SEARCH_SUBSCENE
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$True)]
        [string]$SearchQuery,
        [Parameter(Mandatory=$False)]
        [switch]$AutoSelect
    )
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Creating Web Seassion" -Id 1 -PercentComplete 5
    # Constants
    $BASE_DOMAIN = "https://www.subscene.com"
    $USER_AGENT = ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)
    $SEARCH_URI = ($BASE_DOMAIN + "/subtitles/searchbytitle")
    $BODY = ("query=" + $SearchQuery + "&1="); $BODY = $BODY -replace "\s","+"
    $CATEGORY=""
    $LINK =""
    $RE_EX_LINKS = '(?<=<[aA] [hrefHREF]{4}=").+?(?=">)'
    $RESULT_LIST = New-Object System.Collections.ArrayList
    $COUNTER = 1
    $SUB_TYPE = ""

    # Retrieving search results form subscene.com
    #Write-Host -ForegroundColor Gray "Retriving search results from subscene.com..."
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Retriving search results from subscene.com..." -Id 1 -PercentComplete 15
    $RESPONSE = Invoke-WebRequest -Method Post -uri $SEARCH_URI -UserAgent $USER_AGENT -Body $BODY
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Retriving search results from subscene.com..." -Id 1 -PercentComplete 35
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Processing search results..." -Id 1 -PercentComplete 45
    # Processing each element and extracting results link
    Foreach ($Element in $RESPONSE.AllElements)
    {
        if ($Element.TagName -eq "H2") 
        {
            $CATEGORY = $Element.InnerText
            if (-not $AutoSelect) {Write-Host -ForegroundColor Green $Element.innertext}
        }
        if ($CATEGORY)
        {
            if ($Element.Class -eq "title")
            {
                if ($Element.InnerHTML -match $RE_EX_LINKS) {$LINK = $Matches[0]}
                if ($Element.InnerText -match "Season")
                 {$SUB_TYPE = "TV-Series"}
                 else
                 {$SUB_TYPE = "Movie"}
                $OBJ= New-Object System.Object
                $OBJ | Add-Member -MemberType NoteProperty -Name "Category" -Value $CATEGORY
                $OBJ | Add-Member -MemberType NoteProperty -Name "Description" -Value $Element.InnerText
                $OBJ | Add-Member -MemberType NoteProperty -Name "Link" -Value $LINK
                $OBJ | Add-Member -MemberType NoteProperty -Name "Type" -Value $SUB_TYPE
                $RESULT_LIST.Add($OBJ) | Out-Null
                if (-not $AutoSelect) {Write-Host -ForegroundColor Cyan ("  " + $COUNTER + "- " + $OBJ.Description)}
                $COUNTER++
            } 
            if (-not $AutoSelect)
            {  
                if ($Element.Class -eq "subtle count") {Write-Host -ForegroundColor Gray ("     " + $Element.InnerText)}
            }
        }
         

    }
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Processing Compeleted." -Id 1 -PercentComplete 75

    
    #if autoselect is disabled the user must select a correct value from search result list
    if (-not $AutoSelect)
    {
        Write-Progress -Activity "Searchin in the subscene.com" -Status "Waiting for user input..." -Id 1 -PercentComplete 85
        [ValidatePattern("\d+")]$SELECTED= Read-Host -Prompt "Please select the correct title number from the list"
        Write-Progress -Activity "Searchin in the subscene.com" -Status "Search and process compeleted." -Id 1 -PercentComplete 100 -Completed
        
        Return $RESULT_LIST[$SELECTED -1]
    }
    
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Automatically selecting the best match..." -Id 1 -PercentComplete 85
    
    Write-Progress -Activity "Searchin in the subscene.com" -Status "Search and process compeleted." -Id 1 -PercentComplete 100 -Completed 
    
    #Automatically select the best match from the search result list
    Foreach ($Item in $RESULT_LIST)
    {
        switch ($Item.Category)
        {
            "Exact" {Return $Item}
            "Close" {Return $Item}
            "TV-Series" {Return $Item}
            "Popular" {Return $Item}
        }
    }
    
}