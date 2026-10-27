param(
    [string]$DocxPath,
    [string]$PdfPath
)

$word = $null
$doc = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    
    $fullDocx = [System.IO.Path]::GetFullPath($DocxPath)
    $fullPdf = [System.IO.Path]::GetFullPath($PdfPath)
    
    Write-Host "Opening: $fullDocx"
    $doc = $word.Documents.Open($fullDocx, $false, $true)
    
    Write-Host "Exporting to PDF: $fullPdf"
    $wdExportFormatPDF = 17
    $doc.ExportAsFixedFormat($fullPdf, $wdExportFormatPDF)
    
    Write-Host "SUCCESS: PDF created successfully."
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    if ($doc -ne $null) {
        $doc.Close([ref]$false)
    }
    if ($word -ne $null) {
        $word.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
