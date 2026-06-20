# =============================================================================
#  MAKA Portfolio Manager v5.0
#  Gerenciador de Mídias do Portfólio — github.com/DiogoAlbq/PortfolioMaka
#  Uso: .\manage-portfolio.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$dataFile = Join-Path $PSScriptRoot "src\data.tsx"
$siteUrl  = "https://DiogoAlbq.github.io/PortfolioMaka/"
$global:lastAction = ""

# UTF-8 with BOM Encoding nativo (resolve problemas de corrupção do Set-Content)
$global:utf8Bom = New-Object System.Text.UTF8Encoding $true

# =============================================================================
#  DICIONÁRIO GLOBAL DE CATEGORIAS
# =============================================================================
$global:arrays = @{
    "1" = @{ Name = "artItems";   Label = "Artes (Ilustrações)"; Type = "image"; Color = "Yellow"  }
    "2" = @{ Name = "videoItems"; Label = "Vídeos";              Type = "video"; Color = "Cyan"    }
    "3" = @{ Name = "nsfwItems";  Label = "NSFW (18+)";          Type = "image"; Color = "Red"     }
}

# =============================================================================
#  UI & CONSOLE HELPERS
# =============================================================================

function Write-BoxHeader {
    param([string]$Title, [string]$Color = "Cyan", [int]$Width = 52)
    $innerPad = $Width - 2
    if ($Title) {
        $prefix = "─── $Title "
        $pad = $innerPad - $prefix.Length
        if ($pad -lt 0) { $pad = 0 }
        Write-Host "  ┌$prefix$(""─"" * $pad)┐" -ForegroundColor $Color
    } else {
        Write-Host "  ┌$(""─"" * $innerPad)┐" -ForegroundColor $Color
    }
}

function Write-BoxLine {
    param([string]$Content, [string]$Color = "White", [string]$BorderColor = "Cyan", [int]$Width = 52)
    $innerPad = $Width - 2
    $pad = $innerPad - $Content.Length - 2 
    if ($pad -lt 0) { $pad = 0 }
    Write-Host "  │ " -NoNewline -ForegroundColor $BorderColor
    Write-Host $Content -NoNewline -ForegroundColor $Color
    Write-Host (" " * $pad) -NoNewline
    Write-Host " │" -ForegroundColor $BorderColor
}

function Write-BoxFooter {
    param([string]$Color = "Cyan", [int]$Width = 52)
    $innerPad = $Width - 2
    Write-Host "  └$(""─"" * $innerPad)┘" -ForegroundColor $Color
}

function Write-Header {
    param([string]$Subtitle = "")
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║                                                  ║" -ForegroundColor Cyan
    Write-Host "  ║   " -NoNewline -ForegroundColor Cyan
    Write-Host "███╗   ███╗ █████╗ ██╗  ██╗ █████╗ " -NoNewline -ForegroundColor Yellow
    Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "  ║   " -NoNewline -ForegroundColor Cyan
    Write-Host "████╗ ████║██╔══██╗██║ ██╔╝██╔══██╗" -NoNewline -ForegroundColor Yellow
    Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "  ║   " -NoNewline -ForegroundColor Cyan
    Write-Host "██╔████╔██║███████║█████╔╝ ███████║" -NoNewline -ForegroundColor White
    Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "  ║   " -NoNewline -ForegroundColor Cyan
    Write-Host "██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══██║" -NoNewline -ForegroundColor DarkGray
    Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "  ║   " -NoNewline -ForegroundColor Cyan
    Write-Host "██║ ╚═╝ ██║██║  ██║██║  ██╗██║  ██║" -NoNewline -ForegroundColor Magenta
    Write-Host "  ║" -ForegroundColor Cyan
    Write-Host "  ║                                                  ║" -ForegroundColor Cyan
    Write-Host "  ║        " -NoNewline -ForegroundColor Cyan
    Write-Host "Portfolio Manager  v5.0" -NoNewline -ForegroundColor White
    Write-Host "                 ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

    if ($Subtitle) {
        Write-Host ""
        Write-BoxHeader -Title "" -Color "DarkGray" -Width 52
        Write-BoxLine -Content $Subtitle.PadRight(46) -Color "White" -BorderColor "DarkGray" -Width 52
        Write-BoxFooter -Color "DarkGray" -Width 52
    }

    if ($global:lastAction) {
        Write-Host "  ✓ Última ação: $global:lastAction" -ForegroundColor DarkGreen
    }
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  ✗ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  · $msg" -ForegroundColor DarkGray }

function Pause-Screen {
    Write-Host "`n  [ Pressione qualquer tecla para continuar ]" -ForegroundColor DarkGray
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        $null = Read-Host
    }
}

function Prompt-ChoiceKey {
    param([string]$Message, [string[]]$ValidOptions)
    Write-Host "  $Message " -NoNewline -ForegroundColor White
    try {
        while ($true) {
            $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $choice = $keyInfo.Character.ToString().ToUpper()
            
            if ($keyInfo.VirtualKeyCode -eq 13 -and $ValidOptions -contains "ENTER") {
                Write-Host ""
                return "ENTER"
            }
            if ($ValidOptions -contains $choice) {
                Write-Host $choice -ForegroundColor Cyan
                return $choice
            }
        }
    } catch {
        while ($true) {
            $choice = (Read-Host).ToUpper()
            if ([string]::IsNullOrWhiteSpace($choice) -and $ValidOptions -contains "ENTER") { return "ENTER" }
            if ($ValidOptions -contains $choice) { return $choice }
            Write-Warn "Opção inválida."
            Write-Host "  $Message " -NoNewline -ForegroundColor White
        }
    }
}

function Prompt-Number {
    param([string]$Message, [int]$Min, [int]$Max)
    while ($true) {
        Write-Host "  " -NoNewline
        $input = Read-Host $Message
        $n = 0
        if ([int]::TryParse($input, [ref]$n)) {
            if ($n -ge $Min -and $n -le $Max) { return $n }
        }
        Write-Warn "Digite um número válido entre $Min e $Max."
    }
}

# =============================================================================
#  CAMADA DE DADOS & ARQUIVO
# =============================================================================

function Get-DataContent {
    if (-not (Test-Path $dataFile)) {
        Write-Err "Arquivo não encontrado: $dataFile"
        exit 1
    }
    return [System.IO.File]::ReadAllText($dataFile, $global:utf8Bom)
}

function Set-DataContent {
    param([string]$Content)
    [System.IO.File]::WriteAllText($dataFile, $Content, $global:utf8Bom)
}

function Parse-PortfolioItems {
    param([string]$ArrayName)
    $content = Get-DataContent
    $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { return @() }

    $block = $match.Groups[1].Value
    $items = @()
    $index = 0

    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    foreach ($m in $itemMatches) {
        $itemText = $m.Groups[1].Value
        $type = ""; $color = ""; $mediaUrl = ""
        if ($itemText -match "type:\s*'([^']+)'")     { $type     = $Matches[1] }
        if ($itemText -match "color:\s*'([^']+)'")    { $color    = $Matches[1] }
        if ($itemText -match "mediaUrl:\s*'([^']+)'") { $mediaUrl = $Matches[1] }
        $hasDouble    = $itemText -match "double:\s*true"
        $hasVertical  = $itemText -match "vertical:\s*true"

        $items += [PSCustomObject]@{
            Index     = $index
            Type      = $type
            Color     = $color
            MediaUrl  = $mediaUrl
            Double    = $hasDouble
            Vertical  = $hasVertical
            Raw       = $m.Value
            ArrayName = $ArrayName
        }
        $index++
    }
    return $items
}

function Get-PortfolioStats {
    $stats = @{ TotalItems = 0; WithUrl = 0; Empty = 0; Images = 0; Videos = 0; Squares = 0; Horizontals = 0; Verticals = 0 }
    foreach ($cat in $global:arrays.Values) {
        $items = Parse-PortfolioItems $cat.Name
        foreach ($item in $items) {
            $stats.TotalItems++
            if ($item.Type -eq "image") { $stats.Images++ } else { $stats.Videos++ }
            if ($item.Vertical)       { $stats.Verticals++ }
            elseif ($item.Double)     { $stats.Horizontals++ }
            else                      { $stats.Squares++ }
            if ($item.MediaUrl) { $stats.WithUrl++ } else { $stats.Empty++ }
        }
    }
    return $stats
}

# =============================================================================
#  MODIFICADORES SEGUROS (INDEX BASED)
# =============================================================================

function Set-ItemUrl {
    param([string]$ArrayName, [int]$ItemIndex, [string]$NewUrl)
    try {
        $content = Get-DataContent
        $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
        $match = [regex]::Match($content, $pattern)
        if (-not $match.Success) { return $false }

        $block = $match.Groups[1].Value
        $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
        if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { return $false }

        $oldItemMatch = $itemMatches[$ItemIndex]
        $oldItem = $oldItemMatch.Value
        
        $prefix = $block.Substring(0, $oldItemMatch.Index)
        $suffix = $block.Substring($oldItemMatch.Index + $oldItemMatch.Length)

        if ([string]::IsNullOrWhiteSpace($NewUrl)) {
            $newItem = $oldItem -replace ",?\s*mediaUrl:\s*'[^']*'", ""
        } elseif ($oldItem -match "mediaUrl:\s*'[^']*'") {
            $safeUrl = $NewUrl.Replace('$', '$$')
            $newItem = $oldItem -replace "mediaUrl:\s*'[^']*'", "mediaUrl: '$safeUrl'"
        } else {
            $safeUrl = $NewUrl.Replace('$', '$$')
            $newItem = $oldItem -replace '\}$', ", mediaUrl: '$safeUrl' }"
        }

        $newBlock = $prefix + $newItem + $suffix
        $newContent = $content.Replace($block, $newBlock)
        Set-DataContent $newContent
        return $true
    } catch {
        Write-Err "Erro ao alterar URL: $_"
        return $false
    }
}

function Add-Item {
    param([string]$ArrayName, [string]$Type, [string]$MediaUrl, [bool]$Double = $false, [bool]$Vertical = $false)
    try {
        $content = Get-DataContent
        switch ($ArrayName) {
            "artItems"   { $color = "from-amber-200 to-yellow-200"; $iconColor = "text-amber-600";  $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
            "videoItems" { $color = "from-orange-200 to-yellow-200"; $iconColor = "text-orange-600"; $iconJsx = "<Video className=`"w-10 h-10`" />" }
            "nsfwItems"  { $color = "from-red-200 to-rose-200";    $iconColor = "text-red-600";    $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
        }
        $doubleStr   = if ($Double)   { ", double: true" }   else { "" }
        $verticalStr = if ($Vertical) { ", vertical: true" } else { "" }
        $mediaStr    = if ($MediaUrl) { ", mediaUrl: '$MediaUrl'" } else { "" }
        
        $newEntry  = "  { type: '$Type', color: '$color', iconColor: '$iconColor', icon: $iconJsx$doubleStr$verticalStr$mediaStr },"
        $newEntryEscaped = $newEntry.Replace('$', '$$')
        $newContent = $content -replace "(export const ${ArrayName}: PortfolioItem\[\] = \[[\s\S]*?)(];)", "`$1`n$newEntryEscaped`n`$2"
        Set-DataContent $newContent
        return $true
    } catch {
        Write-Err "Erro ao adicionar item: $_"
        return $false
    }
}


function Remove-PortfolioSlot {
    param([string]$ArrayName, [int]$ItemIndex)
    try {
        $content = Get-DataContent
        $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
        $match = [regex]::Match($content, $pattern)
        if (-not $match.Success) { return $false }

        $block = $match.Groups[1].Value
        $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
        if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { return $false }

        $oldItemMatch = $itemMatches[$ItemIndex]
        $prefix = $block.Substring(0, $oldItemMatch.Index)
        $suffix = $block.Substring($oldItemMatch.Index + $oldItemMatch.Length)

        $suffix = $suffix -replace "^,?\s*", ""

        $newBlock = $prefix + $suffix
        $newContent = $content.Replace($block, $newBlock)
        Set-DataContent $newContent
        return $true
    } catch {
        Write-Err "Erro ao remover item: $_"
        return $false
    }
}

# =============================================================================
#  DEPLOY E INTEGRAÇÃO GIT
# =============================================================================

function Deploy-Changes {
    param([string]$CommitMessage = "")
    Write-Host ""
    Write-BoxHeader -Title "Sincronizando com GitHub..." -Color "DarkCyan"
    Write-BoxFooter -Color "DarkCyan"
    Write-Host ""

    Push-Location $PSScriptRoot
    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        if (-not (Get-Command "npm" -ErrorAction SilentlyContinue)) {
            Write-Err "NPM não encontrado no PATH. Impossível compilar."
            return $false
        }
        if (-not (Get-Command "git" -ErrorAction SilentlyContinue)) {
            Write-Err "GIT não encontrado no PATH. Impossível enviar."
            return $false
        }

        Write-Host "  [1/3] " -NoNewline -ForegroundColor DarkGray
        Write-Host "Compilando o site... " -NoNewline -ForegroundColor White
        $buildResult = cmd /c npm run build 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host " FALHOU" -ForegroundColor Red
            Write-Err "Erro rodando 'npm run build'."
            return $false
        }
        Write-Host " OK" -ForegroundColor Green

        Write-Host "  [2/3] " -NoNewline -ForegroundColor DarkGray
        Write-Host "Registrando alterações... " -NoNewline -ForegroundColor White
        
        & git add -A 2>&1 | Out-Null
        $gitStatus = & git status --porcelain 2>&1
        if ([string]::IsNullOrWhiteSpace($gitStatus)) {
            Write-Host " IGNORADO" -ForegroundColor Yellow
            Write-Info "Nenhuma alteração detectada para commit."
        } else {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
            $msg = if ($CommitMessage) { $CommitMessage } else { "Update via Manager v5.0 — $timestamp" }
            $commitResult = & git commit -m "$msg" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host " FALHOU" -ForegroundColor Red
                Write-Err "Falha no git commit."
                return $false
            }
            Write-Host " OK" -ForegroundColor Green
        }

        Write-Host "  [3/3] " -NoNewline -ForegroundColor DarkGray
        Write-Host "Enviando para o GitHub... " -NoNewline -ForegroundColor White
        $pushResult = & git push origin main 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host " FALHOU" -ForegroundColor Red
            Write-Err "Falha ('git push origin main')."
            return $false
        }
        Write-Host " OK" -ForegroundColor Green

        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "  ║  ✓  Deploy concluído com sucesso!                ║" -ForegroundColor Green
        Write-Host "  ║                                                  ║" -ForegroundColor Green
        Write-Host "  ║  O site atualiza em ~1-3 min:                    ║" -ForegroundColor White
        Write-Host "  ║  $($siteUrl.PadRight(46))║" -ForegroundColor Yellow
        Write-Host "  ║                                                  ║" -ForegroundColor Green
        Write-Host "  ║  Dica: Ctrl+F5 no navegador para limpar cache    ║" -ForegroundColor DarkGray
        Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green

        return $true
    } finally {
        $ErrorActionPreference = $oldPref
        Pop-Location
    }
}

# =============================================================================
#  VIEWS (UI)
# =============================================================================

function View-Stats {
    $s = Get-PortfolioStats
    $filled = if ($s.TotalItems -gt 0) { [math]::Round(($s.WithUrl / [double]$s.TotalItems) * 100) } else { 0 }
    
    $tStr = $s.TotalItems.ToString().PadRight(4)
    $iStr = $s.Images.ToString().PadRight(4)
    $vStr = $s.Videos.ToString().PadRight(4)
    $qStr = $s.Squares.ToString().PadRight(4)
    $hStr = $s.Horizontals.ToString().PadRight(4)
    $vtStr = $s.Verticals.ToString().PadRight(4)
    
    Write-BoxHeader -Title "Status do Portfólio" -Color "DarkCyan"
    
    Write-Host "  │  Total: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $tStr -NoNewline -ForegroundColor White
    Write-Host " Imagens: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $iStr -NoNewline -ForegroundColor Yellow
    Write-Host " Vídeos: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $vStr -NoNewline -ForegroundColor Cyan
    Write-Host (" " * 10 + "│") -ForegroundColor DarkCyan

    Write-Host "  │  Quad: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $qStr -NoNewline -ForegroundColor Gray
    Write-Host " Horiz: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $hStr -NoNewline -ForegroundColor Cyan
    Write-Host " Vert: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $vtStr -NoNewline -ForegroundColor Magenta
    Write-Host (" " * 14 + "│") -ForegroundColor DarkCyan

    $wStr = $s.WithUrl.ToString().PadRight(4)
    $eStr = $s.Empty.ToString().PadRight(4)
    $fStr = "$filled%".PadRight(4)
    
    Write-Host "  │  Com URL: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $wStr -NoNewline -ForegroundColor Green
    Write-Host " Vazios:  " -NoNewline -ForegroundColor DarkCyan
    Write-Host $eStr -NoNewline -ForegroundColor DarkGray
    Write-Host " Preench: " -NoNewline -ForegroundColor DarkCyan
    $colorFilled = if ($filled -ge 70) { "Green" } elseif ($filled -ge 40) { "Yellow" } else { "Red" }
    Write-Host $fStr -NoNewline -ForegroundColor $colorFilled
    Write-Host (" " * 7 + "│") -ForegroundColor DarkCyan
    
    Write-BoxFooter -Color "DarkCyan"
    Write-Host ""
}

function View-Items {
    param([string]$ArrayName, [string]$Label, [string]$LabelColor = "Magenta")
    $items = Parse-PortfolioItems $ArrayName
    
    Write-BoxHeader -Title $Label -Color $LabelColor

    if ($items.Count -eq 0) {
        Write-BoxLine -Content "(galeria vazia)".PadRight(46) -Color "DarkGray" -BorderColor $LabelColor
    } else {
        foreach ($item in $items) {
            $num = "[$($item.Index + 1)]".PadRight(4)
            if ($item.Vertical) {
                $formatTag = "[VERTICAL]  "
                $tagColor = "Magenta"
            } elseif ($item.Double) {
                $formatTag = "[HORIZONTAL]"
                $tagColor = "Cyan"
            } else {
                $formatTag = "[QUADRADO]  "
                $tagColor = "DarkGray"
            }
            
            Write-Host "  │ " -NoNewline -ForegroundColor $LabelColor
            Write-Host "$num" -NoNewline -ForegroundColor Cyan
            Write-Host " $formatTag " -NoNewline -ForegroundColor $tagColor
            
            $urlSpace = 30
            if ($item.MediaUrl) {
                $url = $item.MediaUrl
                if ($url.Length -gt $urlSpace) { $url = $url.Substring(0, $urlSpace-3) + "..." }
                Write-Host $url -NoNewline -ForegroundColor Green
                Write-Host (" " * ($urlSpace - $url.Length) + " │") -ForegroundColor $LabelColor
            } else {
                Write-Host "(vazio)$(' ' * ($urlSpace - 7))│" -ForegroundColor DarkGray
            }
        }
    }
    Write-BoxFooter -Color $LabelColor
    Write-Host ""
}

function Show-WipePreview {
    param([string]$TargetType, [string]$WipeMode)
    $total = 0
    Write-Host "  Itens que serão afetados:" -ForegroundColor Yellow
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
    foreach ($cat in $global:arrays.Values | Sort-Object Name) {
        $items = Parse-PortfolioItems $cat.Name
        $affected = $items | Where-Object { $_.Type -eq $TargetType }
        if ($WipeMode -eq "url") { $affected = $affected | Where-Object { $_.MediaUrl } }
        foreach ($item in $affected) {
            $num = "[$($item.Index + 1)]"
            $url = if ($item.MediaUrl) { $item.MediaUrl.Substring(0, [math]::Min($item.MediaUrl.Length, 50)) } else { "(vazio)" }
            Write-Host "  $($cat.Label) $num" -NoNewline -ForegroundColor Red
            Write-Host " → $url" -ForegroundColor DarkGray
            $total++
        }
    }
    Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
    return $total
}

function Exec-Wipe {
    param([string]$TargetType, [string]$TypeLabel)
    Write-Header "⚠  WIPE DE $($TypeLabel.ToUpper())"

    Write-Host "  Escolha a ação de limpeza:" -ForegroundColor White
    Write-Host "`n  [1] " -NoNewline -ForegroundColor Yellow; Write-Host "Zerar URLs" -NoNewline -ForegroundColor White; Write-Host "  — Remove mídias, mantém os cards" -ForegroundColor DarkGray
    Write-Host "  [2] " -NoNewline -ForegroundColor Red;    Write-Host "Deletar Slots" -NoNewline -ForegroundColor White; Write-Host " — Apaga completamente da grade" -ForegroundColor DarkGray
    Write-Host "  [0] " -NoNewline -ForegroundColor DarkGray; Write-Host "Cancelar" -ForegroundColor DarkGray

    $wipeMode = Prompt-ChoiceKey "`n  Ação [1/2/0]:" @("1","2","0")
    if ($wipeMode -eq "0") { return }

    $mode = if ($wipeMode -eq "1") { "url" } else { "slot" }
    $modeLabel = if ($mode -eq "url") { "Zerar URLs" } else { "Deletar Slots" }

    Write-Host "`n`n  ╔══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║  ⚠  ATENÇÃO: Ação irreversível!                  ║" -ForegroundColor Red
    Write-Host "  ╚══════════════════════════════════════════════════╝`n" -ForegroundColor Red
    
    $total = Show-WipePreview -TargetType $TargetType -WipeMode $mode

    if ($total -eq 0) {
        Write-Warn "Nenhum item encontrado para esse tipo de limpeza."
        Pause-Screen
        return
    }

    Write-Host "`n  Ação  : " -NoNewline -ForegroundColor White; Write-Host $modeLabel -ForegroundColor Red
    Write-Host "  Alvo  : " -NoNewline -ForegroundColor White; Write-Host "Todos os $total item(s) do tipo '$TypeLabel'" -ForegroundColor Red
    Write-Host "`n  Para confirmar, aperte " -NoNewline -ForegroundColor White
    Write-Host "S" -NoNewline -ForegroundColor Red
    Write-Host " ou ENTER para cancelar." -ForegroundColor White
    
    $confirm = Prompt-ChoiceKey "" @("S", "ENTER")

    if ($confirm -ne "S") {
        Write-Warn "`nOperação cancelada."
        Start-Sleep -Seconds 1
        return
    }

    Write-Host "`n`n  Executando limpeza..." -ForegroundColor DarkGray
    $count = 0
    foreach ($cat in $global:arrays.Values) {
        $items = Parse-PortfolioItems $cat.Name
        if ($mode -eq "url") {
            foreach ($item in $items) {
                if ($item.Type -eq $TargetType -and $item.MediaUrl) {
                    if (Set-ItemUrl -ArrayName $cat.Name -ItemIndex $item.Index -NewUrl "") { $count++ }
                }
            }
        } else {
            for ($i = $items.Count - 1; $i -ge 0; $i--) {
                if ($items[$i].Type -eq $TargetType) {
                    if (Remove-PortfolioSlot -ArrayName $cat.Name -ItemIndex $i) { $count++ }
                }
            }
        }
    }

    Write-OK "$count item(s) limpos com sucesso."
    $result = Deploy-Changes -CommitMessage "Wipe $TypeLabel ($modeLabel) via Manager v5.0"
    if ($result) { $global:lastAction = "Wipe de $TypeLabel ($modeLabel) — $count itens" }
    Pause-Screen
}

function Select-Category {
    Write-Host "`n  Selecione a galeria:" -ForegroundColor White
    $keys = ($global:arrays.Keys | Sort-Object)
    foreach ($key in $keys) {
        $cat = $global:arrays[$key]
        Write-Host "  [$key] $($cat.Label)" -ForegroundColor $cat.Color
    }
    Write-Host "  [0] Voltar" -ForegroundColor DarkGray
    $validKeys = $keys + "0"
    $choice = Prompt-ChoiceKey "`n  Galeria:" $validKeys
    if ($choice -eq "0") { return $null }
    return $global:arrays[$choice]
}

# =============================================================================
#  LOOP PRINCIPAL (MAIN)
# =============================================================================

while ($true) {
    Write-Header
    View-Stats

    Write-BoxHeader -Title "Menu Principal" -Color "DarkGray"
    Write-Host "  │                                                  │" -ForegroundColor DarkGray
    Write-Host "  │  [1] " -NoNewline -ForegroundColor DarkGray; Write-Host "Visão Geral        " -NoNewline -ForegroundColor White; Write-Host "Ver todas as mídias        │" -ForegroundColor DarkGray
    Write-Host "  │  [2] " -NoNewline -ForegroundColor DarkGray; Write-Host "Trocar URL         " -NoNewline -ForegroundColor Yellow; Write-Host "Atualizar link de mídia    │" -ForegroundColor DarkGray
    Write-Host "  │  [3] " -NoNewline -ForegroundColor DarkGray; Write-Host "Adicionar Mídia    " -NoNewline -ForegroundColor Green; Write-Host "Novo slot no site          │" -ForegroundColor DarkGray
    Write-Host "  │  [4] " -NoNewline -ForegroundColor DarkGray; Write-Host "Remover Slot       " -NoNewline -ForegroundColor Red; Write-Host "Apagar um card             │" -ForegroundColor DarkGray
    Write-Host "  │  [5] " -NoNewline -ForegroundColor DarkGray; Write-Host "Deploy             " -NoNewline -ForegroundColor Cyan; Write-Host "Sincronizar com GitHub     │" -ForegroundColor DarkGray
    Write-Host "  │                                                  │" -ForegroundColor DarkGray
    Write-Host "  │  [6] " -NoNewline -ForegroundColor DarkGray; Write-Host "WIPE Imagens       " -NoNewline -ForegroundColor DarkYellow; Write-Host "Limpar mídias IMG          │" -ForegroundColor DarkGray
    Write-Host "  │  [7] " -NoNewline -ForegroundColor DarkGray; Write-Host "WIPE Vídeos        " -NoNewline -ForegroundColor DarkCyan; Write-Host "Limpar mídias VID          │" -ForegroundColor DarkGray
    Write-Host "  │                                                  │" -ForegroundColor DarkGray
    Write-Host "  │  [8] " -NoNewline -ForegroundColor DarkGray; Write-Host "Configurações      " -NoNewline -ForegroundColor Blue; Write-Host "Taxa de câmbio USD/BRL     │" -ForegroundColor DarkGray
    Write-Host "  │  [0] " -NoNewline -ForegroundColor DarkGray; Write-Host "Sair               " -NoNewline -ForegroundColor DarkGray; Write-Host "                           │" -ForegroundColor DarkGray
    Write-Host "  │                                                  │" -ForegroundColor DarkGray
    Write-BoxFooter -Color "DarkGray"

    $option = Prompt-ChoiceKey "`n  Opção:" @("1","2","3","4","5","6","7","8","0")

    switch ($option) {
        "1" {
            Write-Header "Visão Geral — Todas as Mídias"
            foreach ($key in ($global:arrays.Keys | Sort-Object)) {
                $a = $global:arrays[$key]
                View-Items -ArrayName $a.Name -Label $a.Label -LabelColor $a.Color
            }
            Pause-Screen
        }

        "2" {
            Write-Header "Trocar URL de Mídia"
            $cat = Select-Category
            if ($null -eq $cat) { continue }

            Write-Header "Trocar URL — $($cat.Label)"
            View-Items -ArrayName $cat.Name -Label $cat.Label -LabelColor $cat.Color

            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Write-Warn "Galeria vazia."; Pause-Screen; continue }

            $idx = (Prompt-Number "Número do item (0 = cancelar)" 0 $items.Count) - 1
            if ($idx -lt 0) { continue }

            $currentUrl = $items[$idx].MediaUrl
            Write-Host "`n  URL atual: " -NoNewline -ForegroundColor DarkGray
            if ($currentUrl) { Write-Host $currentUrl -ForegroundColor Green }
            else { Write-Host "(nenhuma mídia)" -ForegroundColor DarkGray }
            Write-Info "Deixe vazio + ENTER para remover a mídia (mantém o card)"
            
            Write-Host "  " -NoNewline
            $newUrl = Read-Host "Nova URL"

            if (Set-ItemUrl -ArrayName $cat.Name -ItemIndex $idx -NewUrl $newUrl) {
                Write-OK "Mídia atualizada localmente."
                $result = Deploy-Changes
                if ($result) {
                    $labelStr = if ($newUrl) { "definida" } else { "removida" }
                    $global:lastAction = "URL do item $($idx+1) ($($cat.Label)) $labelStr"
                }
            }
            Pause-Screen
        }

        "3" {
            Write-Header "Adicionar Nova Mídia"
            $cat = Select-Category
            if ($null -eq $cat) { continue }

            Write-Host "`n  Tipo de conteúdo:" -ForegroundColor White
            Write-Host "  [1] Imagem (PNG, JPG, Cloudinary...)" -ForegroundColor Yellow
            Write-Host "  [2] Vídeo  (YouTube, TikTok, MP4...)" -ForegroundColor Cyan
            $typeChoice = Prompt-ChoiceKey "`n  Tipo [1/2]:" @("1","2")
            $type = if ($typeChoice -eq "2") { "video" } else { "image" }

            Write-Host "`n  " -NoNewline
            $url = Read-Host "URL da mídia (vazio = card em branco)"

            # Auto-detect TikTok → forçar modo vertical
            $isDouble   = $false
            $isVertical = $false
            if ($url -match "tiktok\.com") {
                Write-Host "`n  " -NoNewline
                Write-Host "TikTok detectado! " -NoNewline -ForegroundColor Magenta
                Write-Host "Aplicando layout vertical automaticamente." -ForegroundColor DarkGray
                $isVertical = $true
            } else {
                Write-Host "`n  [H] Slot duplo (Card Horizontal/Panorâmico)" -ForegroundColor DarkGray
                Write-Host "  [V] Slot vertical (Card 9:16 — TikTok)" -ForegroundColor Magenta
                Write-Host "  [N] Slot normal (Card Quadrado 4x4)" -ForegroundColor DarkGray
                $fmtChoice = Prompt-ChoiceKey "`n  Formato [H/V/N]:" @("H","V","N")
                $isDouble   = ($fmtChoice -eq "H")
                $isVertical = ($fmtChoice -eq "V")
            }

            if (Add-Item -ArrayName $cat.Name -Type $type -MediaUrl $url -Double $isDouble -Vertical $isVertical) {
                Write-OK "`nMídia adicionada localmente."
                $result = Deploy-Changes
                if ($result) { $global:lastAction = "Nova mídia adicionada à galeria $($cat.Label)" }
            }
            Pause-Screen
        }

        "4" {
            Write-Header "Remover Slot de Mídia"
            $cat = Select-Category
            if ($null -eq $cat) { continue }

            Write-Header "Remover — $($cat.Label)"
            View-Items -ArrayName $cat.Name -Label $cat.Label -LabelColor $cat.Color

            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Write-Warn "Galeria vazia."; Pause-Screen; continue }

            $idx = (Prompt-Number "Número do slot para DELETAR (0 = cancelar)" 0 $items.Count) - 1
            if ($idx -lt 0) { continue }

            $confirm = Prompt-ChoiceKey "`n  Tem certeza? [S/N]:" @("S","N")
            if ($confirm -eq "S") {
                if (Remove-PortfolioSlot -ArrayName $cat.Name -ItemIndex $idx) {
                    Write-OK "`nSlot removido localmente."
                    $result = Deploy-Changes
                    if ($result) { $global:lastAction = "Slot $($idx+1) removido da galeria $($cat.Label)" }
                }
            } else {
                Write-Warn "`nCancelado."
            }
            Pause-Screen
        }

        "5" {
            Write-Header "Deploy Manual"
            $result = Deploy-Changes
            if ($result) { $global:lastAction = "Deploy manual" }
            Pause-Screen
        }

        "6" { Exec-Wipe -TargetType "image" -TypeLabel "Imagens" }
        "7" { Exec-Wipe -TargetType "video" -TypeLabel "Vídeos" }

        "8" {
            Write-Header "Configurações do Site"
            try {
                $content = Get-DataContent
                $rateMatch = [regex]::Match($content, "export const exchangeRate = ([\d\.]+);")

                if ($rateMatch.Success) {
                    $currentRate = $rateMatch.Groups[1].Value
                    Write-Host "  Taxa de câmbio atual (USD → BRL): " -NoNewline -ForegroundColor White
                    Write-Host "R$ $currentRate" -ForegroundColor Green
                    Write-Host "`n  " -NoNewline
                    $newRate = Read-Host "Nova taxa (ex: 5.80) ou ENTER para cancelar"

                    if (-not [string]::IsNullOrWhiteSpace($newRate)) {
                        $newRate = $newRate.Replace(",", ".")
                        if ($newRate -match "^[\d\.]+$") {
                            $newContent = $content -replace "export const exchangeRate = [\d\.]+;", "export const exchangeRate = $newRate;"
                            Set-DataContent $newContent
                            Write-OK "Taxa atualizada localmente para R$ $newRate."
                            $result = Deploy-Changes -CommitMessage "Update exchangeRate to $newRate via Manager v5.0"
                            if ($result) { $global:lastAction = "Taxa de câmbio atualizada → R$ $newRate" }
                        } else {
                            Write-Err "Valor inválido. Use apenas números e ponto (ex: 5.50)."
                        }
                    }
                } else {
                    Write-Err "Variável 'exchangeRate' não encontrada em data.tsx."
                }
            } catch {
                Write-Err "Erro ao alterar configurações: $_"
            }
            Pause-Screen
        }

        "0" {
            Write-Host "`n  Até a próxima, Maka! ✨`n" -ForegroundColor Magenta
            break
        }
    }
}




