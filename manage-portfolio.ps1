# =============================================================================
#  MAKA Portfolio Manager v7.0
#  Gerenciador do portfolio em src/data.tsx
#
#  Menu:      .\manage-portfolio.ps1
#  Exemplos: .\manage-portfolio.ps1 -Action List -Category art
#            .\manage-portfolio.ps1 -Action Add -Category art -Url "https://..." -Type image
#            .\manage-portfolio.ps1 -Action Validate
# =============================================================================

[CmdletBinding()]
param(
    [string]$Action = "Menu",
    [string]$Category = "",
    [int]$Index = 0,
    [int]$To = 0,
    [string]$Type = "",
    [string]$Url = "",
    [string]$Layout = "normal",
    [string]$WipeMode = "url",
    [double]$Rate = 0,
    [double]$FeePercent = 4.5,
    [string]$CommitMessage = "",
    [switch]$ClearUrl,
    [switch]$Yes,
    [switch]$DryRun,
    [switch]$NoBrowser,
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"

$script:ManagerVersion = "7.0"
$script:DataFile = Join-Path $PSScriptRoot "src\data.tsx"
$script:LegacyBackupFile = Join-Path $PSScriptRoot "src\data.tsx.bak"
$script:BackupDir = Join-Path $PSScriptRoot "src\.portfolio-backups"
$script:SiteUrl = "https://DiogoAlbq.github.io/PortfolioMaka/"
$script:DryRunMode = $DryRun.IsPresent
$script:LastAction = ""
$script:Utf8NoBom = New-Object System.Text.UTF8Encoding $false

$script:Categories = [ordered]@{
    hero = @{
        Key = "hero"
        Kind = "portfolio"
        ArrayName = "heroBgImages"
        Label = "Carrossel inicial"
        Hint = "Imagens de fundo do inicio do site"
        Color = "Magenta"
        DefaultType = "image"
    }
    social = @{
        Key = "social"
        Kind = "portfolio"
        ArrayName = "socialItems"
        Label = "Redes Sociais"
        Hint = "Links para X, Instagram, TikTok, etc."
        Color = "Blue"
        DefaultType = "image"
    }
    art = @{
        Key = "art"
        ArrayName = "artItems"
        Label = "Artes"
        Hint = "Ilustracoes e imagens publicas"
        Color = "Yellow"
        DefaultType = "image"
    }
    video = @{
        Key = "video"
        ArrayName = "videoItems"
        Label = "Videos"
        Hint = "YouTube, TikTok ou arquivos MP4/WebM"
        Color = "Cyan"
        DefaultType = "video"
    }
    nsfw = @{
        Key = "nsfw"
        ArrayName = "nsfwItems"
        Label = "NSFW"
        Hint = "Itens protegidos pelo aviso 18+"
        Color = "Red"
        DefaultType = "image"
    }
}

function Write-OK {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  ! $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [ERRO] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  - $Message" -ForegroundColor DarkGray
}

function Write-Header {
    param([string]$Subtitle = "")

    Clear-Host
    Write-Host ""
    Write-Host "  +================================================================+" -ForegroundColor DarkCyan
    Write-Host "  |  MAKA Portfolio Manager                                      |" -ForegroundColor Cyan
    Write-Host "  |  Conteudo, preview e deploy em um so lugar                   |" -ForegroundColor White
    Write-Host "  +================================================================+" -ForegroundColor DarkCyan
    Write-Host "  v$script:ManagerVersion  |  data.tsx" -ForegroundColor DarkGray

    if ($Subtitle) {
        Write-Host ""
        Write-Host "  $Subtitle" -ForegroundColor White
        $rule = "-" * [Math]::Min(64, [Math]::Max(18, $Subtitle.Length))
        Write-Host "  $rule" -ForegroundColor DarkGray
    }

    if ($script:DryRunMode) {
        Write-Warn "Modo simulacao ativo: nenhuma alteracao sera gravada."
    }

    if ($script:LastAction) {
        Write-OK "Ultima acao: $script:LastAction"
    }

    Write-Host ""
}

function Write-Section {
    param([string]$Title, [string]$Color = "DarkCyan")
    Write-Host ""
    Write-Host "  $Title" -ForegroundColor $Color
    $rule = "-" * [Math]::Min(64, [Math]::Max(12, $Title.Length))
    Write-Host "  $rule" -ForegroundColor DarkGray
}

function Write-MenuItem {
    param(
        [string]$Key,
        [string]$Title,
        [string]$Description,
        [string]$Color = "White"
    )

    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host $Key -NoNewline -ForegroundColor $Color
    Write-Host "] " -NoNewline -ForegroundColor DarkGray
    Write-Host $Title.PadRight(18) -NoNewline -ForegroundColor White
    Write-Host $Description -ForegroundColor DarkGray
}

function Pause-Screen {
    Write-Host ""
    Write-Host "  Pressione qualquer tecla para continuar..." -ForegroundColor DarkGray
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        $null = Read-Host
    }
}

function Read-Choice {
    param(
        [string]$Prompt,
        [string[]]$Options,
        [string]$Default = ""
    )

    $valid = @($Options | ForEach-Object { $_.ToUpperInvariant() })
    $defaultUpper = $Default.ToUpperInvariant()

    while ($true) {
        $suffix = if ($Default) { " [$Default]" } else { "" }
        Write-Host ("  {0}{1}: " -f $Prompt, $suffix) -NoNewline -ForegroundColor White
        $raw = (Read-Host).Trim()

        if ([string]::IsNullOrWhiteSpace($raw) -and $Default) {
            return $defaultUpper
        }

        $choice = $raw.ToUpperInvariant()
        if ($valid -contains $choice) {
            return $choice
        }

        Write-Warn "Escolha uma opcao valida: $($Options -join ', ')."
    }
}

function Read-Number {
    param(
        [string]$Prompt,
        [int]$Min,
        [int]$Max,
        [int]$Default = -1
    )

    while ($true) {
        $suffix = if ($Default -ge 0) { " [$Default]" } else { "" }
        Write-Host ("  {0}{1}: " -f $Prompt, $suffix) -NoNewline -ForegroundColor White
        $raw = (Read-Host).Trim()
        if ([string]::IsNullOrWhiteSpace($raw) -and $Default -ge 0) {
            return $Default
        }

        $value = 0
        if ([int]::TryParse($raw, [ref]$value) -and $value -ge $Min -and $value -le $Max) {
            return $value
        }

        Write-Warn "Digite um numero entre $Min e $Max."
    }
}

function Confirm-Action {
    param(
        [string]$Message,
        [switch]$DefaultYes
    )

    if ($Yes) {
        return $true
    }

    $default = if ($DefaultYes) { "S" } else { "N" }
    $choice = Read-Choice -Prompt "$Message (S/N)" -Options @("S", "N") -Default $default
    return $choice -eq "S"
}

function Resolve-Action {
    param([string]$Value)

    $normalized = $Value.Trim().ToLowerInvariant()
    $map = @{
        "" = "Menu"
        "menu" = "Menu"
        "stats" = "Stats"
        "status" = "Stats"
        "list" = "List"
        "listar" = "List"
        "add" = "Add"
        "adicionar" = "Add"
        "update" = "Update"
        "url" = "Update"
        "remove" = "Remove"
        "remover" = "Remove"
        "move" = "Move"
        "mover" = "Move"
        "wipe" = "Wipe"
        "rate" = "Rate"
        "cambio" = "Rate"
        "preview" = "Preview"
        "build" = "Build"
        "validate" = "Validate"
        "validar" = "Validate"
        "deploy" = "Deploy"
        "forcedeploy" = "ForceDeploy"
        "forçar" = "ForceDeploy"
        "undo" = "Undo"
        "desfazer" = "Undo"
        "help" = "Help"
        "ajuda" = "Help"
    }

    if ($map.ContainsKey($normalized)) {
        return $map[$normalized]
    }

    throw "Acao invalida: '$Value'. Use -Action Help para ver as opcoes."
}

function Resolve-Category {
    param([string]$Value)

    $normalized = $Value.Trim().ToLowerInvariant()
    switch ($normalized) {
        "" { return $null }
        "1" { return $script:Categories.art }
        "art" { return $script:Categories.art }
        "arts" { return $script:Categories.art }
        "arte" { return $script:Categories.art }
        "artes" { return $script:Categories.art }
        "artitems" { return $script:Categories.art }
        "2" { return $script:Categories.video }
        "video" { return $script:Categories.video }
        "videos" { return $script:Categories.video }
        "videos" { return $script:Categories.video }
        "videoitems" { return $script:Categories.video }
        "3" { return $script:Categories.nsfw }
        "nsfw" { return $script:Categories.nsfw }
        "18" { return $script:Categories.nsfw }
        "nsfw" { return $script:Categories.nsfw }
        "4" { return $script:Categories.hero }
        "carrossel" { return $script:Categories.hero }
        "carousel" { return $script:Categories.hero }
        "herobgimages" { return $script:Categories.hero }
        "5" { return $script:Categories.social }
        "social" { return $script:Categories.social }
        "socialitems" { return $script:Categories.social }
        default { throw "Categoria invalida: '$Value'. Use art, video, nsfw, carousel ou social." }
    }
}

function Select-Category {
    Write-Section "Escolha uma galeria"
    foreach ($entry in $script:Categories.GetEnumerator()) {
        $cat = $entry.Value
        $key = switch ($cat.Key) {
            "art" { "1" }
            "video" { "2" }
            "nsfw" { "3" }
            "hero" { "4" }
            "social" { "5" }
        }
        Write-MenuItem -Key $key -Title $cat.Label -Description $cat.Hint -Color $cat.Color
    }
    Write-MenuItem -Key "0" -Title "Voltar" -Description "Cancelar esta acao" -Color "DarkGray"

    $choice = Read-Choice -Prompt "Galeria" -Options @("1", "2", "3", "4", "5", "0")
    if ($choice -eq "0") {
        return $null
    }

    return Resolve-Category $choice
}

function Assert-DataFile {
    if (-not (Test-Path -LiteralPath $script:DataFile)) {
        throw "Arquivo nao encontrado: $script:DataFile"
    }
}

function Get-DataContent {
    Assert-DataFile
    return [System.IO.File]::ReadAllText($script:DataFile, [System.Text.Encoding]::UTF8)
}

function Get-LineEnding {
    param([string]$Content)
    if ($Content.Contains("`r`n")) {
        return "`r`n"
    }
    return "`n"
}

function Backup-Data {
    param([string]$Reason = "alteracao")

    if ($script:DryRunMode) {
        return
    }

    Assert-DataFile
    if (-not (Test-Path -LiteralPath $script:BackupDir)) {
        New-Item -ItemType Directory -Path $script:BackupDir -Force | Out-Null
    }

    $safeReason = ($Reason -replace "[^a-zA-Z0-9_-]", "-").Trim("-")
    if ([string]::IsNullOrWhiteSpace($safeReason)) {
        $safeReason = "backup"
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = Join-Path $script:BackupDir "data-$timestamp-$safeReason.tsx.bak"

    Copy-Item -LiteralPath $script:DataFile -Destination $backupPath -Force
    Copy-Item -LiteralPath $script:DataFile -Destination $script:LegacyBackupFile -Force

    return $backupPath
}

function Get-LatestBackup {
    $candidates = @()

    if (Test-Path -LiteralPath $script:BackupDir) {
        $candidates += Get-ChildItem -LiteralPath $script:BackupDir -Filter "*.bak" -File -ErrorAction SilentlyContinue
    }

    if (Test-Path -LiteralPath $script:LegacyBackupFile) {
        $candidates += Get-Item -LiteralPath $script:LegacyBackupFile
    }

    return $candidates | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}

function Restore-LatestBackup {
    $backup = Get-LatestBackup
    if ($null -eq $backup) {
        Write-Warn "Nenhum backup encontrado."
        return $false
    }

    if ($script:DryRunMode) {
        Write-Warn "Simulacao: restauraria $($backup.FullName)."
        return $true
    }

    Copy-Item -LiteralPath $backup.FullName -Destination $script:DataFile -Force
    Write-OK "Restaurado de: $($backup.Name)"
    return $true
}

function Save-DataContent {
    param(
        [string]$Content,
        [string]$Reason = "alteracao"
    )

    if ($script:DryRunMode) {
        Write-Warn "Simulacao: src/data.tsx nao foi alterado."
        return
    }

    Backup-Data -Reason $Reason | Out-Null
    [System.IO.File]::WriteAllText($script:DataFile, $Content, $script:Utf8NoBom)
}

function Get-ArraySection {
    param(
        [string]$Content,
        [string]$ArrayName
    )

    $escapedName = [regex]::Escape($ArrayName)
    $pattern = "(?s)(export\s+const\s+$escapedName\s*:\s*(?:PortfolioItem|SocialItem)\[\]\s*=\s*\[)(.*?)(\r?\n?\s*\];)"
    $match = [regex]::Match($Content, $pattern)
    if (-not $match.Success) {
        throw "Array '$ArrayName' nao encontrado em src/data.tsx."
    }

    return [PSCustomObject]@{
        Match = $match
        Prefix = $match.Groups[1].Value
        Body = $match.Groups[2].Value
        Suffix = $match.Groups[3].Value
    }
}

function Get-TopLevelObjectRanges {
    param([string]$Text)

    $ranges = New-Object System.Collections.ArrayList
    $depth = 0
    $start = -1
    $quote = ""
    $escaped = $false

    for ($i = 0; $i -lt $Text.Length; $i++) {
        $ch = [string]$Text[$i]

        if ($quote) {
            if ($escaped) {
                $escaped = $false
                continue
            }
            if ($ch -eq "\") {
                $escaped = $true
                continue
            }
            if ($ch -eq $quote) {
                $quote = ""
            }
            continue
        }

        if ($ch -eq "'" -or $ch -eq '"' -or $ch -eq "``") {
            $quote = $ch
            continue
        }

        if ($ch -eq "{") {
            if ($depth -eq 0) {
                $start = $i
            }
            $depth++
            continue
        }

        if ($ch -eq "}") {
            if ($depth -gt 0) {
                $depth--
                if ($depth -eq 0 -and $start -ge 0) {
                    $ranges.Add([PSCustomObject]@{
                        Start = $start
                        Length = $i - $start + 1
                    }) | Out-Null
                    $start = -1
                }
            }
        }
    }

    if ($depth -ne 0) {
        throw "Nao consegui ler um dos itens do portfolio. Ha chaves '{ }' desbalanceadas."
    }

    return $ranges.ToArray()
}

function Get-QuotedProperty {
    param(
        [string]$Raw,
        [string]$Name
    )

    $pattern = [regex]::Escape($Name) + "\s*:\s*(?:'([^']*)'|`"([^`"]*)`")"
    $match = [regex]::Match($Raw, $pattern)
    if (-not $match.Success) {
        return ""
    }

    if ($match.Groups[1].Success) {
        return $match.Groups[1].Value
    }

    return $match.Groups[2].Value
}

function Get-PortfolioItems {
    param([string]$ArrayName)

    $content = Get-DataContent
    $section = Get-ArraySection -Content $content -ArrayName $ArrayName
    $ranges = @(Get-TopLevelObjectRanges -Text $section.Body)
    $items = New-Object System.Collections.ArrayList
    $index = 0

    foreach ($range in $ranges) {
        $raw = $section.Body.Substring($range.Start, $range.Length)
        
        if ($ArrayName -eq "socialItems") {
            $platform = Get-QuotedProperty -Raw $raw -Name "platform"
            $url = Get-QuotedProperty -Raw $raw -Name "url"
            $nsfw = ($raw -match "\bnsfw\s*:\s*true\b")
            
            $items.Add([PSCustomObject]@{
                Index = $index
                Type = "image"
                Color = ""
                IconColor = ""
                Double = $false
                Vertical = $false
                MediaUrl = $url
                Platform = $platform
                Url = $url
                Nsfw = $nsfw
                Raw = $raw
                ArrayName = $ArrayName
            }) | Out-Null
        } else {
            $typeValue = Get-QuotedProperty -Raw $raw -Name "type"
            $color = Get-QuotedProperty -Raw $raw -Name "color"
            $iconColor = Get-QuotedProperty -Raw $raw -Name "iconColor"
            $mediaUrl = Get-QuotedProperty -Raw $raw -Name "mediaUrl"

            $items.Add([PSCustomObject]@{
                Index = $index
                Type = $typeValue
                Color = $color
                IconColor = $iconColor
                Double = ($raw -match "\bdouble\s*:\s*true\b")
                Vertical = ($raw -match "\bvertical\s*:\s*true\b")
                MediaUrl = $mediaUrl
                Raw = $raw
                ArrayName = $ArrayName
            }) | Out-Null
        }

        $index++
    }

    return $items.ToArray()
}

function Escape-TsString {
    param([AllowNull()][string]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return $Value.Replace("\", "\\").Replace("'", "\'")
}

function Get-DefaultStyle {
    param(
        [hashtable]$CategoryInfo,
        [string]$ItemType
    )

    if ($CategoryInfo.Key -eq "nsfw") {
        return @{ Color = "from-red-200 to-rose-200"; IconColor = "text-red-600" }
    }

    if ($ItemType -eq "video" -or $CategoryInfo.Key -eq "video") {
        return @{ Color = "from-orange-200 to-yellow-200"; IconColor = "text-orange-600" }
    }

    return @{ Color = "from-amber-200 to-yellow-200"; IconColor = "text-amber-600" }
}

function Format-PortfolioItem {
    param([object]$Item)

    if ($Item.ArrayName -eq "socialItems") {
        $parts = New-Object System.Collections.ArrayList
        $parts.Add("platform: '$(Escape-TsString $Item.Platform)'") | Out-Null
        $parts.Add("url: '$(Escape-TsString $Item.Url)'") | Out-Null
        if ($Item.Nsfw) {
            $parts.Add("nsfw: true") | Out-Null
        }
        return "  { $($parts -join ', ') },"
    }

    $typeValue = if ($Item.Type -eq "video") { "video" } else { "image" }
    $color = if ($Item.Color) { $Item.Color } else { "from-amber-200 to-yellow-200" }
    $iconColor = if ($Item.IconColor) { $Item.IconColor } else { "text-amber-600" }
    $icon = if ($typeValue -eq "video") { "<VideoIcon />" } else { "<ImageIcon />" }

    $parts = New-Object System.Collections.ArrayList
    $parts.Add("type: '$typeValue'") | Out-Null
    $parts.Add("color: '$(Escape-TsString $color)'") | Out-Null
    $parts.Add("iconColor: '$(Escape-TsString $iconColor)'") | Out-Null
    $parts.Add("icon: $icon") | Out-Null

    if ($Item.Double) {
        $parts.Add("double: true") | Out-Null
    }

    if ($Item.Vertical) {
        $parts.Add("vertical: true") | Out-Null
    }

    if (-not [string]::IsNullOrWhiteSpace($Item.MediaUrl)) {
        $parts.Add("mediaUrl: '$(Escape-TsString $Item.MediaUrl.Trim())'") | Out-Null
    }

    return "  { $($parts -join ', ') },"
}

function Set-PortfolioItems {
    param(
        [string]$ArrayName,
        [object[]]$Items,
        [string]$Reason
    )

    $content = Get-DataContent
    $lineEnding = Get-LineEnding -Content $content
    $section = Get-ArraySection -Content $content -ArrayName $ArrayName

    $formatted = @($Items | ForEach-Object { Format-PortfolioItem $_ })
    $body = if ($formatted.Count -gt 0) {
        $lineEnding + ($formatted -join $lineEnding) + $lineEnding
    } else {
        $lineEnding
    }

    $newArray = $section.Prefix + $body + "];"
    $newContent = $content.Substring(0, $section.Match.Index) + $newArray + $content.Substring($section.Match.Index + $section.Match.Length)

    Save-DataContent -Content $newContent -Reason $Reason
}

function Get-PortfolioStats {
    $stats = [ordered]@{
        Total = 0
        Filled = 0
        Empty = 0
        Images = 0
        Videos = 0
        Normal = 0
        Wide = 0
        Vertical = 0
    }

    foreach ($cat in $script:Categories.Values) {
        $items = @(Get-PortfolioItems -ArrayName $cat.ArrayName)
        foreach ($item in $items) {
            $stats.Total++
            if ($item.MediaUrl) { $stats.Filled++ } else { $stats.Empty++ }
            if ($item.Type -eq "video") { $stats.Videos++ } else { $stats.Images++ }
            if ($item.Vertical) { $stats.Vertical++ }
            elseif ($item.Double) { $stats.Wide++ }
            else { $stats.Normal++ }
        }
    }

    return $stats
}

function Get-LayoutName {
    param([object]$Item)
    if ($Item.Vertical) { return "vertical" }
    if ($Item.Double) { return "wide" }
    return "normal"
}

function Get-ShortUrl {
    param([string]$Value, [int]$Max = 54)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "(vazio)"
    }

    if ($Value.Length -le $Max) {
        return $Value
    }

    return $Value.Substring(0, $Max - 3) + "..."
}

function Show-Stats {
    $stats = Get-PortfolioStats
    $filledPercent = if ($stats.Total -gt 0) { [math]::Round(($stats.Filled / [double]$stats.Total) * 100) } else { 0 }
    $barSize = 28
    $filledSize = [Math]::Round(($filledPercent / 100) * $barSize)
    $emptySize = $barSize - $filledSize
    $bar = ("#" * $filledSize) + ("-" * $emptySize)
    $barColor = if ($filledPercent -ge 75) { "Green" } elseif ($filledPercent -ge 40) { "Yellow" } else { "Red" }

    Write-Section "Status do portfolio"
    Write-Host "  Itens totais : " -NoNewline -ForegroundColor DarkGray
    Write-Host $stats.Total -ForegroundColor White
    Write-Host "  Com midia    : " -NoNewline -ForegroundColor DarkGray
    Write-Host $stats.Filled -NoNewline -ForegroundColor Green
    Write-Host " preenchidos, " -NoNewline -ForegroundColor DarkGray
    Write-Host $stats.Empty -NoNewline -ForegroundColor Yellow
    Write-Host " vazios" -ForegroundColor DarkGray
    Write-Host "  Tipos        : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($stats.Images) imagens, $($stats.Videos) videos" -ForegroundColor White
    Write-Host "  Layouts      : " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($stats.Normal) normal, $($stats.Wide) wide, $($stats.Vertical) vertical" -ForegroundColor White
    Write-Host "  Preenchido   : " -NoNewline -ForegroundColor DarkGray
    Write-Host "[$bar] $filledPercent%" -ForegroundColor $barColor
}

function Show-Items {
    param([hashtable]$CategoryInfo)

    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    Write-Section "$($CategoryInfo.Label) ($($items.Count) item(ns))" $CategoryInfo.Color

    if ($items.Count -eq 0) {
        Write-Info "Galeria vazia."
        return
    }

    Write-Host "  #   Tipo    Layout    Estado       URL" -ForegroundColor DarkGray
    Write-Host "  --  ------  --------  -----------  ------------------------------------------------------" -ForegroundColor DarkGray

    foreach ($item in $items) {
        $number = ($item.Index + 1).ToString().PadLeft(2)
        $typeValue = $item.Type.PadRight(6)
        $layoutValue = (Get-LayoutName $item).PadRight(8)
        $state = if ($item.MediaUrl) { "preenchido" } else { "vazio" }
        $stateColor = if ($item.MediaUrl) { "Green" } else { "Yellow" }

        Write-Host "  $number  " -NoNewline -ForegroundColor Cyan
        Write-Host "$typeValue  " -NoNewline -ForegroundColor White
        Write-Host "$layoutValue  " -NoNewline -ForegroundColor Magenta
        Write-Host $state.PadRight(11) -NoNewline -ForegroundColor $stateColor
        Write-Host "  $(Get-ShortUrl $item.MediaUrl)" -ForegroundColor DarkGray
    }
}

function Get-MediaKindFromUrl {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "unknown"
    }

    if ($Value -match "(youtu\.be|youtube\.com|tiktok\.com)" -or $Value -match "\.(mp4|webm|ogg|mov)(\?.*)?$") {
        return "video"
    }

    if ($Value -match "\.(jpg|jpeg|png|gif|webp|avif|svg)(\?.*)?$" -or $Value -match "cloudinary\.com/.*/image/upload") {
        return "image"
    }

    return "unknown"
}

function Normalize-ItemType {
    param(
        [string]$Value,
        [hashtable]$CategoryInfo,
        [string]$MediaUrl = ""
    )

    $normalized = $Value.Trim().ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($normalized) -or $normalized -eq "auto") {
        $fromUrl = Get-MediaKindFromUrl $MediaUrl
        if ($fromUrl -ne "unknown") {
            return $fromUrl
        }
        return $CategoryInfo.DefaultType
    }

    switch ($normalized) {
        "1" { return "image" }
        "img" { return "image" }
        "image" { return "image" }
        "imagem" { return "image" }
        "2" { return "video" }
        "vid" { return "video" }
        "video" { return "video" }
        "video" { return "video" }
        default { throw "Tipo invalido: '$Value'. Use image ou video." }
    }
}

function Normalize-Layout {
    param(
        [string]$Value,
        [string]$MediaUrl = ""
    )

    $normalized = $Value.Trim().ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($normalized) -or $normalized -eq "auto") {
        if ($MediaUrl -match "tiktok\.com") {
            return "vertical"
        }
        if ($MediaUrl -match "(youtu\.be|youtube\.com)") {
            return "wide"
        }
        return "normal"
    }

    switch ($normalized) {
        "n" { return "normal" }
        "normal" { return "normal" }
        "quadrado" { return "normal" }
        "square" { return "normal" }
        "h" { return "wide" }
        "wide" { return "wide" }
        "horizontal" { return "wide" }
        "duplo" { return "wide" }
        "v" { return "vertical" }
        "vertical" { return "vertical" }
        default { throw "Layout invalido: '$Value'. Use normal, wide ou vertical." }
    }
}

function New-PortfolioItemObject {
    param(
        [hashtable]$CategoryInfo,
        [string]$ItemType,
        [string]$MediaUrl,
        [string]$LayoutName
    )

    $style = Get-DefaultStyle -CategoryInfo $CategoryInfo -ItemType $ItemType
    return [PSCustomObject]@{
        Index = -1
        Type = $ItemType
        Color = $style.Color
        IconColor = $style.IconColor
        Double = ($LayoutName -eq "wide")
        Vertical = ($LayoutName -eq "vertical")
        MediaUrl = $MediaUrl.Trim()
        Raw = ""
        ArrayName = $CategoryInfo.ArrayName
    }
}

function Add-PortfolioItem {
    param(
        [hashtable]$CategoryInfo,
        [string]$ItemType,
        [string]$MediaUrl,
        [string]$LayoutName,
        [string]$Platform = "other",
        [bool]$Nsfw = $false
    )

    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    $newItem = New-PortfolioItemObject -CategoryInfo $CategoryInfo -ItemType $ItemType -MediaUrl $MediaUrl -LayoutName $LayoutName
    $newItem | Add-Member -MemberType NoteProperty -Name "Platform" -Value $Platform -Force
    $newItem | Add-Member -MemberType NoteProperty -Name "Url" -Value $MediaUrl -Force
    $newItem | Add-Member -MemberType NoteProperty -Name "Nsfw" -Value $Nsfw -Force
    $items += $newItem

    Set-PortfolioItems -ArrayName $CategoryInfo.ArrayName -Items $items -Reason "add-$($CategoryInfo.Key)"
    Write-OK "Item adicionado em $($CategoryInfo.Label)."
}

function Update-PortfolioItemUrl {
    param(
        [hashtable]$CategoryInfo,
        [int]$OneBasedIndex,
        [string]$NewUrl
    )

    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    if ($OneBasedIndex -lt 1 -or $OneBasedIndex -gt $items.Count) {
        throw "Indice invalido. Use um numero entre 1 e $($items.Count)."
    }

    $items[$OneBasedIndex - 1].MediaUrl = $NewUrl.Trim()
    Set-PortfolioItems -ArrayName $CategoryInfo.ArrayName -Items $items -Reason "update-url-$($CategoryInfo.Key)"
    Write-OK "URL do item $OneBasedIndex atualizada."
}

function Remove-PortfolioItem {
    param(
        [hashtable]$CategoryInfo,
        [int]$OneBasedIndex
    )

    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    if ($OneBasedIndex -lt 1 -or $OneBasedIndex -gt $items.Count) {
        throw "Indice invalido. Use um numero entre 1 e $($items.Count)."
    }

    $kept = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $items.Count; $i++) {
        if ($i -ne ($OneBasedIndex - 1)) {
            $kept.Add($items[$i]) | Out-Null
        }
    }

    Set-PortfolioItems -ArrayName $CategoryInfo.ArrayName -Items ($kept.ToArray()) -Reason "remove-$($CategoryInfo.Key)"
    Write-OK "Item $OneBasedIndex removido de $($CategoryInfo.Label)."
}

function Move-PortfolioItem {
    param(
        [hashtable]$CategoryInfo,
        [int]$FromIndex,
        [int]$ToIndex
    )

    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    if ($items.Count -lt 2) {
        throw "Esta galeria precisa de pelo menos 2 itens para reordenar."
    }
    if ($FromIndex -lt 1 -or $FromIndex -gt $items.Count) {
        throw "Indice de origem invalido. Use 1 a $($items.Count)."
    }
    if ($ToIndex -lt 1 -or $ToIndex -gt $items.Count) {
        throw "Posicao de destino invalida. Use 1 a $($items.Count)."
    }
    if ($FromIndex -eq $ToIndex) {
        Write-Warn "Origem e destino sao iguais. Nada mudou."
        return
    }

    $list = [System.Collections.ArrayList]@($items)
    $item = $list[$FromIndex - 1]
    $list.RemoveAt($FromIndex - 1)
    $list.Insert($ToIndex - 1, $item)

    Set-PortfolioItems -ArrayName $CategoryInfo.ArrayName -Items ($list.ToArray()) -Reason "move-$($CategoryInfo.Key)"
    Write-OK "Item movido da posicao $FromIndex para $ToIndex."
}

function Invoke-Wipe {
    param(
        [string]$TargetType,
        [string]$Mode
    )

    $itemType = Normalize-ItemType -Value $TargetType -CategoryInfo $script:Categories.art
    $normalizedMode = $Mode.Trim().ToLowerInvariant()
    if ($normalizedMode -notin @("url", "slots", "slot", "delete", "deletar")) {
        throw "Modo de wipe invalido. Use url ou slots."
    }

    $deleteSlots = $normalizedMode -in @("slots", "slot", "delete", "deletar")
    $affected = New-Object System.Collections.ArrayList

    foreach ($cat in $script:Categories.Values) {
        $items = @(Get-PortfolioItems -ArrayName $cat.ArrayName)
        foreach ($item in $items) {
            if ($item.Type -eq $itemType -and ($deleteSlots -or $item.MediaUrl)) {
                $affected.Add([PSCustomObject]@{
                    Category = $cat
                    Item = $item
                }) | Out-Null
            }
        }
    }

    if ($affected.Count -eq 0) {
        Write-Warn "Nenhum item encontrado para limpar."
        return
    }

    Write-Section "Previa da limpeza" "Yellow"
    foreach ($entry in $affected) {
        Write-Host "  $($entry.Category.Label) #$($entry.Item.Index + 1) " -NoNewline -ForegroundColor Red
        Write-Host "$(Get-ShortUrl $entry.Item.MediaUrl 64)" -ForegroundColor DarkGray
    }

    $modeLabel = if ($deleteSlots) { "deletar slots" } else { "zerar URLs" }
    if (-not (Confirm-Action "Confirmar $modeLabel em $($affected.Count) item(ns)?")) {
        Write-Warn "Operacao cancelada."
        return
    }

    foreach ($cat in $script:Categories.Values) {
        $items = @(Get-PortfolioItems -ArrayName $cat.ArrayName)
        if ($deleteSlots) {
            $newItems = @($items | Where-Object { $_.Type -ne $itemType })
        } else {
            foreach ($item in $items) {
                if ($item.Type -eq $itemType) {
                    $item.MediaUrl = ""
                }
            }
            $newItems = $items
        }

        Set-PortfolioItems -ArrayName $cat.ArrayName -Items $newItems -Reason "wipe-$itemType"
    }

    Write-OK "Limpeza concluida."
}

function Set-ExchangeRate {
    param([double]$NewRate)

    if ($NewRate -le 0) {
        throw "A taxa precisa ser maior que zero."
    }

    $content = Get-DataContent
    $rateText = $NewRate.ToString("0.00", [System.Globalization.CultureInfo]::InvariantCulture)
    $pattern = "export\s+const\s+exchangeRate\s*=\s*[\d\.]+;"

    if (-not [regex]::IsMatch($content, $pattern)) {
        throw "Nao encontrei 'export const exchangeRate = ...;' em src/data.tsx."
    }

    $newContent = [regex]::Replace($content, $pattern, "export const exchangeRate = $rateText;", 1)
    Save-DataContent -Content $newContent -Reason "exchange-rate"
    Write-OK "Taxa de cambio atualizada para R$ $rateText."
}

function Update-ExchangeRateFromApi {
    Write-Info "Buscando cotacao em open.er-api.com..."
    $response = Invoke-RestMethod -Uri "https://open.er-api.com/v6/latest/USD" -Method Get -TimeoutSec 20
    $usdToBrl = [double]$response.rates.BRL

    if ($usdToBrl -le 0) {
        throw "A API nao retornou uma cotacao valida."
    }

    $finalRate = [Math]::Round($usdToBrl * (1 - ($FeePercent / 100)), 2)
    Write-Host "  Cotacao USD/BRL : R$ $($usdToBrl.ToString('0.00'))" -ForegroundColor Green
    Write-Host "  Desconto/taxa   : $FeePercent%" -ForegroundColor DarkGray
    Write-Host "  Valor final     : R$ $($finalRate.ToString('0.00'))" -ForegroundColor Magenta

    if (Confirm-Action "Salvar esta taxa?") {
        Set-ExchangeRate -NewRate $finalRate
    }
}

function Test-PortfolioData {
    $errors = New-Object System.Collections.ArrayList
    $warnings = New-Object System.Collections.ArrayList

    foreach ($cat in $script:Categories.Values) {
        try {
            $items = @(Get-PortfolioItems -ArrayName $cat.ArrayName)
        } catch {
            $errors.Add($_.Exception.Message) | Out-Null
            continue
        }

        for ($i = 0; $i -lt $items.Count; $i++) {
            $item = $items[$i]
            $label = "$($cat.Label) #$($i + 1)"

            if ($item.Type -notin @("image", "video")) {
                $errors.Add(("{0}: tipo invalido '{1}'." -f $label, $item.Type)) | Out-Null
            }

            if ($item.Double -and $item.Vertical) {
                $errors.Add(("{0}: nao pode ser wide e vertical ao mesmo tempo." -f $label)) | Out-Null
            }

            if ([string]::IsNullOrWhiteSpace($item.Color) -or [string]::IsNullOrWhiteSpace($item.IconColor)) {
                $warnings.Add(("{0}: cores ausentes; o manager corrigira ao editar este item." -f $label)) | Out-Null
            }

            if (-not [string]::IsNullOrWhiteSpace($item.MediaUrl)) {
                $kind = Get-MediaKindFromUrl $item.MediaUrl
                if ($kind -eq "unknown") {
                    $warnings.Add(("{0}: nao reconheci o tipo da URL." -f $label)) | Out-Null
                } elseif ($kind -ne $item.Type) {
                    $errors.Add(("{0}: URL parece '{1}', mas o item esta como '{2}'." -f $label, $kind, $item.Type)) | Out-Null
                }
            }
        }
    }

    Write-Section "Validacao"
    if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-OK "Tudo certo com os dados do portfolio."
        return $true
    }

    foreach ($warning in $warnings) {
        Write-Warn $warning
    }

    foreach ($error in $errors) {
        Write-Err $error
    }

    if ($errors.Count -eq 0) {
        Write-Warn "Validacao passou com avisos."
        return $true
    }

    return $false
}

function Test-CommandAvailable {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-NpmBuild {
    if (-not (Test-CommandAvailable "npm")) {
        throw "NPM nao encontrado no PATH."
    }

    Push-Location $PSScriptRoot
    try {
        Write-Section "Build de producao"
        Write-Info "Executando npm run build..."
        & npm run build
        if ($LASTEXITCODE -ne 0) {
            throw "Build falhou. Corrija os erros acima antes de publicar."
        }
        Write-OK "Build concluido."
    } finally {
        Pop-Location
    }
}

function Test-PortOpen {
    param(
        [string]$HostName = "127.0.0.1",
        [int]$Port = 5173
    )

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $async = $client.BeginConnect($HostName, $Port, $null, $null)
        $connected = $async.AsyncWaitHandle.WaitOne(500, $false)
        if (-not $connected) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

function Start-LocalPreview {
    if (-not (Test-CommandAvailable "npm")) {
        throw "NPM nao encontrado no PATH."
    }

    $url = "http://localhost:5173"
    Write-Section "Preview local"

    if (Test-PortOpen -Port 5173) {
        Write-OK "Servidor ja esta ativo em $url."
    } else {
        Write-Info "Iniciando Vite em segundo plano..."
        $command = "Set-Location -LiteralPath '$($PSScriptRoot.Replace("'", "''"))'; npm run dev -- --host 127.0.0.1"
        Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoExit", "-Command", $command) -WindowStyle Hidden | Out-Null
        Start-Sleep -Seconds 3

        if (Test-PortOpen -Port 5173) {
            Write-OK "Servidor iniciado em $url."
        } else {
            Write-Warn "O servidor foi iniciado, mas a porta 5173 ainda nao respondeu. Aguarde alguns segundos e tente abrir o preview."
        }
    }

    if (-not $NoBrowser) {
        Start-Process $url | Out-Null
        Write-OK "Navegador aberto."
    }
}

function Get-GitCurrentBranch {
    Push-Location $PSScriptRoot
    try {
        $branch = (& git branch --show-current 2>$null).Trim()
        if ([string]::IsNullOrWhiteSpace($branch)) {
            return "main"
        }
        return $branch
    } finally {
        Pop-Location
    }
}

function Invoke-Deploy {
    param([switch]$Force)

    if (-not (Test-CommandAvailable "git")) {
        throw "Git nao encontrado no PATH."
    }

    if (-not $NoBuild) {
        $valid = Test-PortfolioData
        if (-not $valid) {
            if ($Force) { Write-Warn "Validacao falhou, mas continuando (Force Deploy)." }
            else { throw "Validacao falhou. Deploy cancelado." }
        }
        Invoke-NpmBuild
    }

    Push-Location $PSScriptRoot
    try {
        Write-Section "Deploy GitHub"
        $status = & git status --short
        if ([string]::IsNullOrWhiteSpace($status)) {
            Write-Warn "Nenhuma alteracao local para commitar."
            if ($Force) {
                Write-Info "Criando commit vazio para forcar deploy..."
                & git commit --allow-empty -m "Force deploy via manager"
                if ($LASTEXITCODE -ne 0) { throw "git commit vazio falhou." }
            } else {
                return
            }
        } else {
            Write-Host "  Arquivos alterados:" -ForegroundColor DarkGray
            $status | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }

            if (-not $Force -and -not (Confirm-Action "Adicionar e commitar estas alteracoes?")) {
                Write-Warn "Deploy cancelado antes do commit."
                return
            }

            & git add -A
            if ($LASTEXITCODE -ne 0) { throw "git add falhou." }

            $message = if ($CommitMessage) { $CommitMessage } else { "Update portfolio via manager v$script:ManagerVersion" }
            if ($Force -and -not $CommitMessage) { $message = "Force deploy: $message" }
            & git commit -m $message
            if ($LASTEXITCODE -ne 0) { throw "git commit falhou." }
            Write-OK "Commit criado."
        }

        $branch = Get-GitCurrentBranch
        if ($Force -or (Confirm-Action "Enviar branch '$branch' para origin?")) {
            if ($Force) {
                Write-Info "Fazendo force push para origin $branch..."
                & git push -u origin $branch --force
            } else {
                & git push -u origin $branch
            }
            if ($LASTEXITCODE -ne 0) { throw "git push falhou." }
            Write-OK "Push concluido. Site: $script:SiteUrl"
        } else {
            Write-Warn "Push cancelado."
        }
    } finally {
        Pop-Location
    }
}

function Show-Help {
    Write-Header "Ajuda rapida"
    Write-Host "  Uso interativo:" -ForegroundColor White
    Write-Host "    .\manage-portfolio.ps1" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Comandos uteis:" -ForegroundColor White
    Write-Host "    .\manage-portfolio.ps1 -Action Stats" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action List -Category art" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Add -Category video -Type video -Url `"https://youtu.be/...`" -Layout wide" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Update -Category art -Index 1 -Url `"https://.../image.png`"" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Update -Category art -Index 1 -ClearUrl" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Remove -Category nsfw -Index 2" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Move -Category art -Index 3 -To 1" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Validate" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Build" -ForegroundColor DarkGray
    Write-Host "    .\manage-portfolio.ps1 -Action Preview" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Seguranca:" -ForegroundColor White
    Write-Host "    Use -DryRun para simular alteracoes. Backups ficam em src\.portfolio-backups." -ForegroundColor DarkGray
}

function Read-InteractiveType {
    param(
        [hashtable]$CategoryInfo,
        [string]$MediaUrl
    )

    $detected = Get-MediaKindFromUrl $MediaUrl
    $default = if ($detected -ne "unknown") {
        if ($detected -eq "video") { "2" } else { "1" }
    } elseif ($CategoryInfo.DefaultType -eq "video") { "2" } else { "1" }

    Write-Section "Tipo de conteudo"
    Write-MenuItem -Key "1" -Title "Imagem" -Description "PNG, JPG, WEBP, Cloudinary image" -Color "Yellow"
    Write-MenuItem -Key "2" -Title "Video" -Description "YouTube, TikTok, MP4, WebM" -Color "Cyan"
    $choice = Read-Choice -Prompt "Tipo" -Options @("1", "2") -Default $default
    return Normalize-ItemType -Value $choice -CategoryInfo $CategoryInfo -MediaUrl $MediaUrl
}

function Read-InteractiveLayout {
    param([string]$MediaUrl)

    $defaultLayout = Normalize-Layout -Value "auto" -MediaUrl $MediaUrl
    $default = switch ($defaultLayout) {
        "wide" { "H" }
        "vertical" { "V" }
        default { "N" }
    }

    Write-Section "Formato do card"
    Write-MenuItem -Key "N" -Title "Normal" -Description "Card quadrado padrao" -Color "White"
    Write-MenuItem -Key "H" -Title "Wide" -Description "Ocupa duas colunas; bom para YouTube" -Color "Cyan"
    Write-MenuItem -Key "V" -Title "Vertical" -Description "Ocupa duas linhas; bom para TikTok/9:16" -Color "Magenta"

    $choice = Read-Choice -Prompt "Formato" -Options @("N", "H", "V") -Default $default
    return Normalize-Layout -Value $choice -MediaUrl $MediaUrl
}

function Invoke-AddFlow {
    param([hashtable]$CategoryInfo)

    Write-Header "Adicionar midia"
    if ($null -eq $CategoryInfo) {
        $CategoryInfo = Select-Category
        if ($null -eq $CategoryInfo) { return }
    }

    Write-Host ""
    Write-Host "  URL da midia (opcional): " -NoNewline -ForegroundColor White
    $mediaUrl = (Read-Host).Trim()

    if ($CategoryInfo.Key -eq "social") {
        $platform = "other"
        if ($mediaUrl -match "x\.com|twitter\.com") { $platform = "twitter" }
        elseif ($mediaUrl -match "instagram\.com") { $platform = "instagram" }
        elseif ($mediaUrl -match "tiktok\.com") { $platform = "tiktok" }
        elseif ($mediaUrl -match "youtube\.com|youtu\.be") { $platform = "youtube" }
        
        Write-Section "Plataforma"
        Write-MenuItem -Key "1" -Title "Twitter / X" -Description "" -Color "Cyan"
        Write-MenuItem -Key "2" -Title "Instagram" -Description "" -Color "Magenta"
        Write-MenuItem -Key "3" -Title "TikTok" -Description "" -Color "White"
        Write-MenuItem -Key "4" -Title "YouTube" -Description "" -Color "Red"
        Write-MenuItem -Key "5" -Title "Outro" -Description "" -Color "Yellow"
        
        $defChoice = switch ($platform) { "twitter" { "1" }; "instagram" { "2" }; "tiktok" { "3" }; "youtube" { "4" }; default { "5" } }
        $choice = Read-Choice -Prompt "Plataforma" -Options @("1", "2", "3", "4", "5") -Default $defChoice
        $platform = switch ($choice) { "1" { "twitter" }; "2" { "instagram" }; "3" { "tiktok" }; "4" { "youtube" }; default { "other" } }
        
        $nsfw = Confirm-Action -Message "Conteudo NSFW (18+)?"
        Add-PortfolioItem -CategoryInfo $CategoryInfo -ItemType "image" -MediaUrl $mediaUrl -LayoutName "normal" -Platform $platform -Nsfw $nsfw
    } else {
        $itemType = Read-InteractiveType -CategoryInfo $CategoryInfo -MediaUrl $mediaUrl
        $layoutName = Read-InteractiveLayout -MediaUrl $mediaUrl
        Add-PortfolioItem -CategoryInfo $CategoryInfo -ItemType $itemType -MediaUrl $mediaUrl -LayoutName $layoutName
    }

    $script:LastAction = "Adicionou item em $($CategoryInfo.Label)"
}

function Invoke-UpdateFlow {
    param([hashtable]$CategoryInfo)

    Write-Header "Atualizar URL"
    if ($null -eq $CategoryInfo) {
        $CategoryInfo = Select-Category
        if ($null -eq $CategoryInfo) { return }
    }

    Show-Items -CategoryInfo $CategoryInfo
    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    if ($items.Count -eq 0) {
        Write-Warn "Galeria vazia."
        return
    }

    $itemIndex = Read-Number -Prompt "Numero do item (0 cancela)" -Min 0 -Max $items.Count
    if ($itemIndex -eq 0) { return }

    Write-Host ""
    Write-Host "  URL atual: " -NoNewline -ForegroundColor DarkGray
    Write-Host "$(Get-ShortUrl $items[$itemIndex - 1].MediaUrl 90)" -ForegroundColor Green
    Write-Info "Deixe em branco para remover a midia mantendo o card."
    Write-Host "  Nova URL: " -NoNewline -ForegroundColor White
    $newUrl = Read-Host

    Update-PortfolioItemUrl -CategoryInfo $CategoryInfo -OneBasedIndex $itemIndex -NewUrl $newUrl
    $script:LastAction = "Atualizou URL em $($CategoryInfo.Label) #$itemIndex"
}

function Invoke-RemoveFlow {
    param([hashtable]$CategoryInfo)

    Write-Header "Remover slot"
    if ($null -eq $CategoryInfo) {
        $CategoryInfo = Select-Category
        if ($null -eq $CategoryInfo) { return }
    }

    Show-Items -CategoryInfo $CategoryInfo
    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    if ($items.Count -eq 0) {
        Write-Warn "Galeria vazia."
        return
    }

    $itemIndex = Read-Number -Prompt "Numero do slot para remover (0 cancela)" -Min 0 -Max $items.Count
    if ($itemIndex -eq 0) { return }

    if (Confirm-Action "Remover definitivamente o slot #$itemIndex?") {
        Remove-PortfolioItem -CategoryInfo $CategoryInfo -OneBasedIndex $itemIndex
        $script:LastAction = "Removeu slot em $($CategoryInfo.Label) #$itemIndex"
    }
}

function Invoke-MoveFlow {
    param([hashtable]$CategoryInfo)

    Write-Header "Reordenar midia"
    if ($null -eq $CategoryInfo) {
        $CategoryInfo = Select-Category
        if ($null -eq $CategoryInfo) { return }
    }

    Show-Items -CategoryInfo $CategoryInfo
    $items = @(Get-PortfolioItems -ArrayName $CategoryInfo.ArrayName)
    if ($items.Count -lt 2) {
        Write-Warn "Esta galeria precisa de pelo menos 2 itens."
        return
    }

    $from = Read-Number -Prompt "Mover item numero (0 cancela)" -Min 0 -Max $items.Count
    if ($from -eq 0) { return }

    $target = Read-Number -Prompt "Nova posicao" -Min 1 -Max $items.Count
    Move-PortfolioItem -CategoryInfo $CategoryInfo -FromIndex $from -ToIndex $target
    $script:LastAction = "Moveu item em $($CategoryInfo.Label)"
}

function Invoke-RateFlow {
    Write-Header "Taxa de cambio"
    $content = Get-DataContent
    $match = [regex]::Match($content, "export\s+const\s+exchangeRate\s*=\s*([\d\.]+);")
    if ($match.Success) {
        Write-Host "  Taxa atual: R$ $($match.Groups[1].Value)" -ForegroundColor Green
    }

    Write-Section "Como atualizar?"
    Write-MenuItem -Key "1" -Title "Automatico" -Description "Busca USD/BRL e aplica taxa/desconto configurado" -Color "Cyan"
    Write-MenuItem -Key "2" -Title "Manual" -Description "Digitar valor em reais" -Color "Yellow"
    Write-MenuItem -Key "0" -Title "Voltar" -Description "Cancelar" -Color "DarkGray"

    $choice = Read-Choice -Prompt "Opcao" -Options @("1", "2", "0")
    if ($choice -eq "0") { return }

    if ($choice -eq "1") {
        Update-ExchangeRateFromApi
        $script:LastAction = "Atualizou taxa por API"
        return
    }

    Write-Host "  Nova taxa (ex: 5.75): " -NoNewline -ForegroundColor White
    $raw = (Read-Host).Trim().Replace(",", ".")
    $newRate = 0.0
    if (-not [double]::TryParse($raw, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$newRate)) {
        throw "Valor invalido."
    }

    Set-ExchangeRate -NewRate $newRate
    $script:LastAction = "Atualizou taxa manualmente"
}

function Invoke-WipeFlow {
    Write-Header "Limpeza em lote"
    Write-Section "Tipo de midia"
    Write-MenuItem -Key "1" -Title "Imagens" -Description "Afeta apenas itens type: image" -Color "Yellow"
    Write-MenuItem -Key "2" -Title "Videos" -Description "Afeta apenas itens type: video" -Color "Cyan"
    Write-MenuItem -Key "0" -Title "Voltar" -Description "Cancelar" -Color "DarkGray"

    $targetChoice = Read-Choice -Prompt "Tipo" -Options @("1", "2", "0")
    if ($targetChoice -eq "0") { return }

    Write-Section "Acao"
    Write-MenuItem -Key "1" -Title "Zerar URLs" -Description "Mantem os cards e remove apenas os links" -Color "Yellow"
    Write-MenuItem -Key "2" -Title "Deletar slots" -Description "Remove os cards da galeria" -Color "Red"
    Write-MenuItem -Key "0" -Title "Voltar" -Description "Cancelar" -Color "DarkGray"

    $modeChoice = Read-Choice -Prompt "Acao" -Options @("1", "2", "0")
    if ($modeChoice -eq "0") { return }

    $targetType = if ($targetChoice -eq "2") { "video" } else { "image" }
    $mode = if ($modeChoice -eq "2") { "slots" } else { "url" }
    Invoke-Wipe -TargetType $targetType -Mode $mode
    $script:LastAction = "Executou wipe de $targetType"
}

function Invoke-Menu {
    while ($true) {
        Write-Header
        Show-Stats

        Write-Section "Conteudo"
        Write-MenuItem -Key "1" -Title "Listar galerias" -Description "Ver todos os itens e URLs" -Color "White"
        Write-MenuItem -Key "2" -Title "Trocar URL" -Description "Atualizar ou limpar midia de um card" -Color "Yellow"
        Write-MenuItem -Key "3" -Title "Adicionar midia" -Description "Criar novo card com deteccao de tipo/layout" -Color "Green"
        Write-MenuItem -Key "4" -Title "Remover slot" -Description "Apagar um card da galeria" -Color "Red"
        Write-MenuItem -Key "5" -Title "Reordenar" -Description "Mover item para outra posicao" -Color "Cyan"

        Write-Section "Site"
        Write-MenuItem -Key "V" -Title "Validar dados" -Description "Checar URLs, tipos e estrutura" -Color "Green"
        Write-MenuItem -Key "B" -Title "Build" -Description "Rodar npm run build" -Color "Cyan"
        Write-MenuItem -Key "P" -Title "Preview local" -Description "Abrir Vite em localhost:5173" -Color "Magenta"
        Write-MenuItem -Key "D" -Title "Deploy" -Description "Build, commit e push com confirmacao" -Color "Green"
        Write-MenuItem -Key "F" -Title "Force Deploy" -Description "Forcar total (ignora validacao, cria commit vazio, usa --force)" -Color "Red"

        Write-Section "Manutencao"
        Write-MenuItem -Key "C" -Title "Cambio" -Description "Atualizar exchangeRate" -Color "Blue"
        Write-MenuItem -Key "W" -Title "Wipe em lote" -Description "Limpar URLs ou slots por tipo" -Color "DarkYellow"
        Write-MenuItem -Key "U" -Title "Desfazer" -Description "Restaurar ultimo backup" -Color "DarkRed"
        Write-MenuItem -Key "H" -Title "Ajuda" -Description "Ver comandos por parametro" -Color "DarkGray"
        Write-MenuItem -Key "0" -Title "Sair" -Description "Fechar o manager" -Color "DarkGray"
        Write-Host ""

        $option = Read-Choice -Prompt "Opcao" -Options @("1", "2", "3", "4", "5", "V", "B", "P", "D", "F", "C", "W", "U", "H", "0")

        try {
            switch ($option) {
                "1" {
                    Write-Header "Todas as galerias"
                    foreach ($cat in $script:Categories.Values) { Show-Items -CategoryInfo $cat }
                    Pause-Screen
                }
                "2" { Invoke-UpdateFlow; Pause-Screen }
                "3" { Invoke-AddFlow; Pause-Screen }
                "4" { Invoke-RemoveFlow; Pause-Screen }
                "5" { Invoke-MoveFlow; Pause-Screen }
                "V" { Write-Header "Validar dados"; Test-PortfolioData | Out-Null; Pause-Screen }
                "B" { Write-Header "Build"; Invoke-NpmBuild; Pause-Screen }
                "P" { Write-Header "Preview local"; Start-LocalPreview; Pause-Screen }
                "D" { Write-Header "Deploy"; Invoke-Deploy; Pause-Screen }
                "F" { Write-Header "Force Deploy"; Invoke-Deploy -Force; Pause-Screen }
                "C" { Invoke-RateFlow; Pause-Screen }
                "W" { Invoke-WipeFlow; Pause-Screen }
                "U" {
                    Write-Header "Desfazer"
                    if (Confirm-Action "Restaurar o backup mais recente?") {
                        Restore-LatestBackup | Out-Null
                        $script:LastAction = "Restaurou backup"
                    }
                    Pause-Screen
                }
                "H" { Show-Help; Pause-Screen }
                "0" {
                    Write-Host ""
                    Write-Host "  Fechado. Ate a proxima!" -ForegroundColor Magenta
                    return
                }
            }
        } catch {
            Write-Err $_.Exception.Message
            Pause-Screen
        }
    }
}

function Invoke-CommandAction {
    $resolvedAction = Resolve-Action $Action

    switch ($resolvedAction) {
        "Menu" {
            Invoke-Menu
        }
        "Help" {
            Show-Help
        }
        "Stats" {
            Show-Stats
        }
        "List" {
            $cat = Resolve-Category $Category
            if ($null -eq $cat) {
                foreach ($entry in $script:Categories.Values) { Show-Items -CategoryInfo $entry }
            } else {
                Show-Items -CategoryInfo $cat
            }
        }
        "Validate" {
            $valid = Test-PortfolioData
            if (-not $valid) { exit 1 }
        }
        "Build" {
            $valid = Test-PortfolioData
            if (-not $valid) { exit 1 }
            Invoke-NpmBuild
        }
        "Preview" {
            Start-LocalPreview
        }
        "Deploy" {
            Invoke-Deploy
        }
        "ForceDeploy" {
            Invoke-Deploy -Force
        }
        "Undo" {
            if (-not (Confirm-Action "Restaurar o backup mais recente?")) {
                Write-Warn "Operacao cancelada."
                return
            }
            Restore-LatestBackup | Out-Null
        }
        "Add" {
            $cat = Resolve-Category $Category
            if ($null -eq $cat) { throw "Use -Category art, video ou nsfw." }
            $itemType = Normalize-ItemType -Value $Type -CategoryInfo $cat -MediaUrl $Url
            $layoutName = Normalize-Layout -Value $Layout -MediaUrl $Url
            Add-PortfolioItem -CategoryInfo $cat -ItemType $itemType -MediaUrl $Url -LayoutName $layoutName
        }
        "Update" {
            $cat = Resolve-Category $Category
            if ($null -eq $cat) { throw "Use -Category art, video ou nsfw." }
            if ($Index -le 0) { throw "Use -Index com o numero do item." }
            $newUrl = if ($ClearUrl) { "" } else { $Url }
            Update-PortfolioItemUrl -CategoryInfo $cat -OneBasedIndex $Index -NewUrl $newUrl
        }
        "Remove" {
            $cat = Resolve-Category $Category
            if ($null -eq $cat) { throw "Use -Category art, video ou nsfw." }
            if ($Index -le 0) { throw "Use -Index com o numero do item." }
            if (-not (Confirm-Action "Remover item #$Index de $($cat.Label)?")) {
                Write-Warn "Operacao cancelada."
                return
            }
            Remove-PortfolioItem -CategoryInfo $cat -OneBasedIndex $Index
        }
        "Move" {
            $cat = Resolve-Category $Category
            if ($null -eq $cat) { throw "Use -Category art, video ou nsfw." }
            if ($Index -le 0 -or $To -le 0) { throw "Use -Index e -To." }
            Move-PortfolioItem -CategoryInfo $cat -FromIndex $Index -ToIndex $To
        }
        "Wipe" {
            if ([string]::IsNullOrWhiteSpace($Type)) { throw "Use -Type image ou video." }
            Invoke-Wipe -TargetType $Type -Mode $WipeMode
        }
        "Rate" {
            if ($Rate -gt 0) {
                Set-ExchangeRate -NewRate $Rate
            } else {
                Update-ExchangeRateFromApi
            }
        }
    }
}

try {
    Invoke-CommandAction
} catch {
    Write-Err $_.Exception.Message
    exit 1
}
