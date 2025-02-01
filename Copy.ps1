param(
    [string]$SourceDirectory = "C:\Users\Taban\IdeaProjects\SleekChat\src"  # Update as needed
)

$clipboardContent = ""

# Retrieve and process all .lua and .loc files (with recursion), ignoring files under any "Libs" folder
Get-ChildItem -Path $SourceDirectory -Recurse -Include *.lua, *.loc, *.xml -File |
        Where-Object { $_.FullName -notmatch '(\\|/)Libs(\\|/)' } |
        ForEach-Object {
            $clipboardContent += "File: $( $_.Name )" + [Environment]::NewLine
            $clipboardContent += '```'
            $clipboardContent += (Get-Content -Path $_.FullName -Raw)
            $clipboardContent += '```' + [Environment]::NewLine
        }
$clipboardContent += "" + [Environment]::NewLine
#$clipboardContent += "Groupster is a transformative addon for WoW Classic, designed to revolutionize the group formation process with a focus on intelligent automation and seamless user experience. The project's core goal is to replace the cumbersome, manual process of the native LFG system with an advanced, AI-driven solution that handles matchmaking, role management, and communication with unparalleled efficiency. By leveraging robust technologies like Ace3 and LibDataBroker, Groupster aims to provide a highly extensible, debuggable, and user-friendly interface, while ensuring backward compatibility with players who do not use the addon. Ultimately, this project seeks to perfect the group finding experience, allowing players to effortlessly form balanced and effective parties for any dungeon, thereby enhancing gameplay and fostering a more connected community." + [Environment]::NewLine
$clipboardContent += "" + [Environment]::NewLine

# Only set the clipboard if we actually have content; handle empty results gracefully
if ( [string]::IsNullOrWhiteSpace($clipboardContent))
{
    Write-Host "No content found to copy. No .lua or .loc files are present in $SourceDirectory (outside Libs folders)."
}
else
{
    Set-Clipboard -Value $clipboardContent
    Write-Host "All .lua and .loc files (excluding those under Libs) have been processed, and their contents have been copied to your clipboard."
}
