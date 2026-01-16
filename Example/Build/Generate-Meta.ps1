<#
.Synopsis
    Generatess the wordlists.json file for the published WordLists repository,
.Parameter InputMetaPath
    The JSON file Content (meta) that describes the word lists.
    e.g. $(ProjectDir)Assets\wordlists.json (meta)
.Parameter AssetsDir
    The path to the assets directory containing the word lists.
    e.g. $(ProjectDir)Assets
.Parameter PublishDir
    The output directory where the generated wordlists.json file will be saved.
    e.g. $(SoltionDir)..\WordLists\Lists
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $InputMetaPath,

    [Parameter(Mandatory = $true)]
    [string] $AssetsDir,

    [Parameter(Mandatory = $true)]
    [string] $PublishDir
)

function Throw-Error 
{
       param(
        [Parameter(Mandatory)]
        [string] $message
    )
    Write-Host $message -ForegroundColor Red
    throw $message
}

# Trim any stray quotes and normalize to full paths
# A trailing quote is seen in VS 2026 for the last parameter on the Exec command-line.
$InputMetaPath = [System.IO.Path]::GetFullPath($InputMetaPath.Trim('"'))
$AssetsDir     = [System.IO.Path]::GetFullPath($AssetsDir.Trim('"'))
$PublishDir    = [System.IO.Path]::GetFullPath($PublishDir.Trim('"'))

if (-not (Test-Path $InputMetaPath))
{
    Throw-Error "Input JSON (meta) file not found:" + $InputMetaPath
}

if (-not (Test-Path $AssetsDir)) 
{
   Throw-Error "AssetsDir not found:" + $AssetsDir
}

if (-not (Test-Path $PublishDir))
{
    Throw-Error = "PublishDir not found:" + $PublishDir
}

# Use the input meta filename as the output meta filename
$metaFileName = Split-Path $InputMetaPath -Leaf

$metaJson = Get-Content -Raw -Path $InputMetaPath | ConvertFrom-Json

$result = @()

foreach ($entry in $metaJson) 
{
    if (-not $entry.FileName) 
    {
        throw "Meta entry is missing FileName: $($entry | ConvertTo-Json -Compress)"
    }

    $assetFileName = $entry.FileName
    $assetPath = Join-Path $AssetsDir $assetFileName
    if (-not (Test-Path $assetPath)) 
    {
        throw "Asset file not found for '$($entry.Name)': $assetPath"
    }

    $assetInfo = Get-Item $assetPath
    $lastModifiedUtc = $assetInfo.LastWriteTimeUtc
    $lastModifiedString = $lastModifiedUtc.ToString("o")
   
    $obj = [pscustomobject]@{
        Name         = $entry.Name
        Description  = $entry.Description
        LastModified = $lastModifiedString
    }

    $result += $obj
}

# Output JSON: same file name as meta, but in PublishDir
$outputJsonPath = Join-Path $PublishDir $metaFileName
$result | ConvertTo-Json -Depth 4 | Out-File -FilePath $outputJsonPath -Encoding utf8
