# Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction Ignore )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction Ignore )

# Dot source the files
Foreach($import in @($Public + $Private))
{
    Try { . $import.fullname }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}



Function Get-Subtitle
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory=$False)]
        $SearchQuery,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('TV-Series','Movie')]
        [string]$Type,
        [Parameter(Mandatory)]
        [string]$VideoDirectory,
        [Parameter(Mandatory=$False)]
        [switch]$AutoSelect=$False,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Farsi/Persian','English','Arabic','French','Indonesian')]
        [string]$Language
    )
    #Constants
    $SEARCHRESULT=""
    $SELECTEDLINKS=""
    $DIR_NAME = Split-Path -Path $VideoDirectory -Leaf
    $ORDINAL=@("","first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth","eleventh","twelfth","thirteenth","fourteenth","fifteenth","sixteenth","seventeenth","eighteenth","nineteenth","twentieth")

    Switch ($Type)
        {
            "Movie" 
            {
                 if ($SearchQuery)
                 {
                    if ($AutoSelect)
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery -AutoSelect
                        $SELECTEDLINKS = HL_GET_Movie_Results -SelectedLink $SEARCHRESULT -Language $Language -AutoSelect
                    }
                    else
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery
                        $SELECTEDLINKS = HL_GET_Movie_Results -SelectedLink $SEARCHRESULT -Language $Language
                    }
                 }
                 else
                 {
                    $SearchQuery = $DIR_NAME -replace "(\d{4}|\(|\)|^\s+|\s+$)",""
                    if ($AutoSelect)
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery -AutoSelect
                        $SELECTEDLINKS = HL_GET_Movie_Results -SelectedLink $SEARCHRESULT -Language $Language -AutoSelect
                    }
                    else
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery
                        $SELECTEDLINKS = HL_GET_Movie_Results -SelectedLink $SEARCHRESULT -Language $Language
                    }
                 }
                 if ($SELECTEDLINKS)
                 {
                    HL_Download_Subtitle -SelectedLinks $SELECTEDLINKS -Type $Type -VideoDirectory $VideoDirectory
                 }
                 else
                 { 
                    Return
                 }
            }
            "TV-Series" 
            {
                if ($SearchQuery)
                 {
                    if ($AutoSelect)
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery -AutoSelect
                        $SELECTEDLINKS = HL_GET_TV_Results -SelectedLink $SEARCHRESULT -Language $Language -AutoSelect
                    }
                    else
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery
                        $SELECTEDLINKS = HL_GET_TV_Results -SelectedLink $SEARCHRESULT -Language $Language
                    }
                 }
                 else
                 {
                    if ($DIR_NAME -match "season")
                    {
                        [int]$SEASON_NUM= [regex]::Match($DIR_NAME,"\d+").Value
                        $SERIES_NAME = Split-Path -Path (Split-Path -Path $VideoDirectory -Parent) -Leaf
                        $SearchQuery = ($SERIES_NAME + " - " + $ORDINAL[$SEASON_NUM] + " Season")
                    }
                    else
                    {
                        $SearchQuery = $DIR_NAME
                    }
                    if ($AutoSelect)
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery -AutoSelect
                        $SELECTEDLINKS = HL_GET_TV_Results -SelectedLink $SEARCHRESULT -Language $Language -AutoSelect
                    }
                    else
                    {
                        $SEARCHRESULT = HL_SEARCH_SUBSCENE -SearchQuery $SearchQuery
                        $SELECTEDLINKS = HL_GET_TV_Results -SelectedLink $SEARCHRESULT -Language $Language 
                    }
                 }
                 if ($SELECTEDLINKS)
                 {
                    HL_Download_Subtitle -SelectedLinks $SELECTEDLINKS -Type $Type -VideoDirectory $VideoDirectory
                 }
                 else
                 {
                    Return
                 }
            }
        }
        if ($SELECTEDLINKS)
        {
            HL_RENAME_SUBTITLE -VideoDirectory $VideoDirectory -Language $Language -Type $Type
        }
}
Export-ModuleMember -Function Get-Subtitle
