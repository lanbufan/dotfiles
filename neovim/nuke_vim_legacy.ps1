# ================================
# Neovim FULL Reset Script (Windows)
# ⚠️ Deletes entire .vim directory
# ================================

$paths = @(
    "$env:LOCALAPPDATA\nvim",
    "$env:LOCALAPPDATA\nvim-data",
    "$env:LOCALAPPDATA\tree-sitter",
    "$env:USERPROFILE\.vim"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Deleting $path" -ForegroundColor Red
        Remove-Item -Recurse -Force -Path $path
    } else {
        Write-Host "Skipping (not found): $path" -ForegroundColor DarkGray
    }
}

Write-Host "`nFULL Neovim reset complete." -ForegroundColor Green
