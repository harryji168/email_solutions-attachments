$repoPath = "C:\email_solutions-attachments"
cd $repoPath

# Set remote (use credentials from Git credential manager)
$remoteUrl = "https://github.com/harryji168/email_solutions-attachments.git"
git remote set-url origin $remoteUrl
git config http.postBuffer 524288000

# Add index files first
git add public/index.html public/_headers public/_redirects
git commit -m "Initial commit: redirects and headers [skip ci]"
git push -u origin main --force

# Get all attachments relative to repo root
$files = Get-ChildItem public/attachments -File

$batchSize = 300
$total = $files.Count
for ($i = 0; $i -lt $total; $i += $batchSize) {
    $end = [Math]::Min($i + $batchSize - 1, $total - 1)
    $batch = $files[$i..$end]
    foreach ($file in $batch) {
        if ($file) {
            # Use relative path
            $relPath = "public/attachments/$($file.Name)"
            git add $relPath
        }
    }
    $batchNum = ($i / $batchSize) + 1
    $totalBatches = [Math]::Ceiling($total / $batchSize)
    # Use [skip ci] to prevent Cloudflare from building until we are ready
    git commit -m "Batch $batchNum of $totalBatches attachments [skip ci]"
    Write-Host "Pushing batch $batchNum of $totalBatches..."
    git push origin main
}
