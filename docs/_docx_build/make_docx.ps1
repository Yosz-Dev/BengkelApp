$ErrorActionPreference = 'Stop'

$buildDir   = 'D:\PROJEK MOBILE S7\docs\_docx_build'
$contentTxt = Join-Path $buildDir 'content.txt'
$outDocx    = 'D:\PROJEK MOBILE S7\docs\POS_Bengkel_Dokumentasi.docx'

# ---------- Helpers ----------
function Esc([string]$s) {
    $s = $s -replace '&', '&amp;'
    $s = $s -replace '<', '&lt;'
    $s = $s -replace '>', '&gt;'
    return $s
}

$bt = [char]96  # backtick
$pattern = '(\*\*.+?\*\*)|(' + [regex]::Escape($bt) + '[^' + [regex]::Escape($bt) + ']+' + [regex]::Escape($bt) + ')|([^*' + $bt + ']+)'
$rx = [regex]$pattern

function Get-Runs([string]$text) {
    $sb = New-Object System.Text.StringBuilder
    foreach ($m in $rx.Matches($text)) {
        $tok = $m.Value
        if ($tok.StartsWith('**')) {
            $inner = $tok.Substring(2, $tok.Length - 4)
            [void]$sb.Append('<w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">' + (Esc $inner) + '</w:t></w:r>')
        }
        elseif ($tok.StartsWith($bt)) {
            $inner = $tok.Substring(1, $tok.Length - 2)
            [void]$sb.Append('<w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:color w:val="A4286A"/></w:rPr><w:t xml:space="preserve">' + (Esc $inner) + '</w:t></w:r>')
        }
        else {
            [void]$sb.Append('<w:r><w:t xml:space="preserve">' + (Esc $tok) + '</w:t></w:r>')
        }
    }
    return $sb.ToString()
}

function New-Para([string]$style, [string]$runs) {
    if ($style) { return '<w:p><w:pPr><w:pStyle w:val="' + $style + '"/></w:pPr>' + $runs + '</w:p>' }
    return '<w:p>' + $runs + '</w:p>'
}

# ---------- Parse content ----------
$lines = Get-Content -Path $contentTxt -Encoding UTF8
$body = New-Object System.Text.StringBuilder
$inCode = $false
$bullet = [char]0x2022

foreach ($line in $lines) {
    if ($line.Trim() -eq '```') { $inCode = -not $inCode; continue }

    if ($inCode) {
        [void]$body.Append('<w:p><w:pPr><w:pStyle w:val="CodeBlock"/></w:pPr><w:r><w:t xml:space="preserve">' + (Esc $line) + '</w:t></w:r></w:p>')
        continue
    }

    $t = $line
    if ($t.Trim() -eq '') { continue }

    if ($t.StartsWith('TITLE: ')) { [void]$body.Append((New-Para 'DocTitle' (Get-Runs $t.Substring(7)))); continue }
    if ($t.StartsWith('#### ')) { [void]$body.Append((New-Para 'Heading4' (Get-Runs $t.Substring(5)))); continue }
    if ($t.StartsWith('### '))  { [void]$body.Append((New-Para 'Heading3' (Get-Runs $t.Substring(4)))); continue }
    if ($t.StartsWith('## '))   { [void]$body.Append((New-Para 'Heading2' (Get-Runs $t.Substring(3)))); continue }
    if ($t.StartsWith('# '))    { [void]$body.Append((New-Para 'Heading1' (Get-Runs $t.Substring(2)))); continue }
    if ($t.StartsWith('- ')) {
        $runs = '<w:r><w:t xml:space="preserve">' + $bullet + '   </w:t></w:r>' + (Get-Runs $t.Substring(2))
        [void]$body.Append((New-Para 'ListBullet' $runs)); continue
    }
    [void]$body.Append((New-Para $null (Get-Runs $t)))
}

$sectPr = '<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="709" w:footer="709" w:gutter="0"/></w:sectPr>'

$documentXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
'<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>' +
$body.ToString() + $sectPr + '</w:body></w:document>'

# ---------- Static parts ----------
$contentTypes = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>
'@

$relsXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
'@

$docRelsXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>
'@

$stylesXml = @'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:rPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:pPr><w:spacing w:after="120" w:line="276" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="DocTitle"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="120" w:after="240"/></w:pPr><w:rPr><w:b/><w:color w:val="1565C0"/><w:sz w:val="52"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="360" w:after="120"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:color w:val="0D47A1"/><w:sz w:val="34"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="240" w:after="100"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:color w:val="1565C0"/><w:sz w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="180" w:after="80"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:color w:val="333333"/><w:sz w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="160" w:after="60"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:i/><w:color w:val="555555"/><w:sz w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="ListBullet"><w:name w:val="List Bullet"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:after="60"/><w:ind w:left="360" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="CodeBlock"><w:name w:val="Code Block"/><w:basedOn w:val="Normal"/><w:pPr><w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/><w:spacing w:before="20" w:after="20" w:line="240" w:lineRule="auto"/><w:ind w:left="120" w:right="120"/></w:pPr><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="18"/></w:rPr></w:style>
</w:styles>
'@

# ---------- Build .docx (ZIP with forward-slash entries) ----------
Add-Type -AssemblyName System.IO.Compression | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null

$enc = New-Object System.Text.UTF8Encoding($false)

function Add-ZipEntry($zip, [string]$name, [string]$content) {
    $entry = $zip.CreateEntry($name, [System.IO.Compression.CompressionLevel]::Optimal)
    $s = $entry.Open()
    $bytes = $enc.GetBytes($content)
    $s.Write($bytes, 0, $bytes.Length)
    $s.Dispose()
}

if (Test-Path $outDocx) { Remove-Item $outDocx -Force }

$fs = [System.IO.File]::Open($outDocx, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)

Add-ZipEntry $zip '[Content_Types].xml' $contentTypes
Add-ZipEntry $zip '_rels/.rels' $relsXml
Add-ZipEntry $zip 'word/_rels/document.xml.rels' $docRelsXml
Add-ZipEntry $zip 'word/styles.xml' $stylesXml
Add-ZipEntry $zip 'word/document.xml' $documentXml

$zip.Dispose()
$fs.Dispose()

Write-Host ('OK -> ' + $outDocx)
Write-Host ('Size: ' + ((Get-Item $outDocx).Length) + ' bytes')
