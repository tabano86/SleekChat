param(
    [string]$SourceDirectory = "C:\Users\Taban\IdeaProjects\SleekChat\src"  # Update as needed
)

$clipboardContent = ""

# Retrieve and process all .lua, .loc, and .xml files (with recursion), ignoring files under any "Libs" folder
Get-ChildItem -Path $SourceDirectory -Recurse -Include *.lua, *.loc, *.xml -File |
        Where-Object { $_.FullName -notmatch '(\\|/)Libs(\\|/)' } |
        ForEach-Object {
            # Build a relative path (including folder name) unless it's just the file name
            $relativePath = $_.FullName.Replace($SourceDirectory, "")
            $relativePath = $relativePath.TrimStart('\','/')

            # If $relativePath is empty (root folder), just use the file name
            if ([string]::IsNullOrWhiteSpace($relativePath)) {
                $relativePath = $_.Name
            }

            $clipboardContent += "File: $relativePath" + [Environment]::NewLine
            $clipboardContent += '```'
            $clipboardContent += (Get-Content -Path $_.FullName -Raw)
            $clipboardContent += '```' + [Environment]::NewLine
        }

$clipboardContent += "" + [Environment]::NewLine
$clipboardContent += "" + [Environment]::NewLine

# Only set the clipboard if we actually have content; handle empty results gracefully
if ([string]::IsNullOrWhiteSpace($clipboardContent))
{
    Write-Host "No content found to copy. No .lua, .loc, or .xml files are present in $SourceDirectory (outside Libs folders)."
}
else
{
    Set-Clipboard -Value $clipboardContent
    Write-Host "All relevant files (excluding those under Libs) have been processed, and their contents have been copied to your clipboard."
}
