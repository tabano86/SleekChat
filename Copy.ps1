param(
    [string]$SourceDirectory = (Get-Location).Path
)

$clipboardContent = ""

Get-ChildItem -Path $SourceDirectory -Recurse -Include *.toc, *.md, *.lua -File |
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
            $clipboardContent += '```powershell'
            $clipboardContent += (Get-Content -Path $_.FullName -Raw)
            $clipboardContent += '```' + [Environment]::NewLine
        }

$clipboardContent += "" + [Environment]::NewLine
$clipboardContent += "" + [Environment]::NewLine

# Only set the clipboard if we actually have content
if ([string]::IsNullOrWhiteSpace($clipboardContent)) {
    Write-Host "No content found to copy. No .toc, .md, or .lua files (outside Libs folders) in $SourceDirectory."
}
else {
    Set-Clipboard -Value $clipboardContent
    Write-Host "All relevant files (excluding 'Libs' folder) have been processed, and their contents have been copied to your clipboard."
}
