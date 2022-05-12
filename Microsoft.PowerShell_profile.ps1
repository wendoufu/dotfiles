# set alias
$ShortWay = @{
    'IP' = 'Get-IPInfo'
    'j' = 'Invoke-ZLocation'
    's' = 'Select-Object'
    'vi' = 'vim'
    'cc' = 'clear-host'
}
$ShortWay.Keys | ForEach-Object { Set-Alias $_ $ShortWay.$_}

# wrap some commands
function 2ico { magick $args[0] -set filename:name '%t' -resize '128x128>' '%[filename:name].ico'} 
function Get-VideoInfo { youtube-dl $args[0] --write-sub --write-thumbnail --skip-download --quiet }
function cs { choco search @args -r}
function csi {
    $AppList = choco search @args -r
    if ( $AppList -is [string] ) {
        $AppName = $AppList.Split('|')[0]
        $null = Read-Host "Install $AppName ?"
        choco install $AppName -y
        break
    }
    $Length = $AppList.Length
    switch ($Length) {
        0 { Write-host 'No Result' ; break }
       { ($_ -ge 2) -and ($_ -le 30) } { 
           $AppName = $AppList | ForEach-Object { $_.Split('|')[0] } 
           $AppName = Show-Menu $AppName
           $null = Read-Host "Install $AppName ?"
           choco install $AppName -y
           break
        }
        { $_ -ge 31} { 
            'Too Many Items'
            break
        }
        Default {
            $AppName = $AppList | ForEach-Object { $_.Split('|')[0] } 
            # echo 'default!'
            $AppName}
    }
}
function cout { 
    $Outdated = choco outdated -r
    if ( $Outdated){
        $AppName = $outdated | ForEach-Object { $_.Split("|")[0] }
        $AppName -join '; '
        $null = Read-Host 'Enter / Ctrl + C'
        $SelectApp = Show-Menu $AppName -Multiselect
        choco upgrade $SelectApp -y
    }
    else {
        "No app need to update"
    }
 }

function compress { tinypng.exe compress $args[0] }
function open { explorer.exe $pwd }
function Set-SURL ([string]$path, [string]$url) {
    curl --location --request POST "https://link.mirtle.org" -H "x-preshared-key: $env:CurlCfKey" -H "Content-Type: application/x-www-form-urlencoded" --data-urlencode "url=$url" --data-urlencode "path=$path" -S
    if ($?){
        Set-Clipboard "https://link.mirtle.org/$path"
    }
}
function Remove-SURL([string]$path){
    curl --location --request DELETE "https://link.mirtle.org/$path" -H "x-preshared-key: $env:CurlCfKey" -S
}
function Get-SURL([string]$path){
    curl --location --request GET "https://link.mirtle.org/$path" -H "x-preshared-key: $env:CurlCfKey" -S
}
# set psrealine option
$PSOption = @{
    PredictionSource = 'HistoryAndPlugin'
    Colors = @{
        # InlinePrediction = '#6272a4'
        ContinuationPrompt = "DarkGray"
    }
    EditMode = 'Vi'
    ViModeIndicator = 'Script'
    ViModeChangeHandler = $Function:OnViModeChange
    # HistorySaveStyle = 'SaveAtExit'
    MaximumHistoryCount = '2000'
    PredictionViewStyle = 'ListView'
    ShowToolTips = $false
    ContinuationPrompt = '> '
    # PromptText = "> "
}
Set-PSReadLineOption @PSOption
function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}
# set prompt function

# Set key function
Set-PSReadLineKeyHandler -Chord Tab -function MenuComplete
Set-PSReadLineKeyHandler -Chord Ctrl+b,Ctrl+B -Function DeleteLine
Set-PSReadLineKeyHandler -Chord Ctrl+A,Ctrl+a -Function SelectAll

# import some modules
$module = @('Pscx','posh-git','C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1')
$module |  import-module

# gitpromptsettings
$GitPromptSettings.DefaultPromptPath = ''
$GitPromptSettings.DefaultPromptSuffix = ''
$GitPromptSettings.DefaultPromptWriteStatusFirst = $true
# is admin
$principal = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
$IsAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Prompt {
    $Status = (Get-Location).Path
    $host.UI.RawUI.WindowTitle = "$Status"
    if($Status.IndexOf("${home}\") -eq 0){
        $Status = $Status.Replace("$home","~")
    }
    if (Test-path .git){
        $GitStatus = & $GitPromptScriptBlock
        $Status = "[$Status]","$GitStatus" -join ''
    }
    else {
        $Status = "[$Status]"
    }
    $color =  (2,3,(6..12),14,15) | Get-Random
    $var = $IsAdmin ? "#" : "$"
    Write-Host "`n$Status`n" -NoNewline
    Write-Host $var -NoNewline -ForegroundColor  $color
    return " "
}
function ~{ Set-Location $home}
