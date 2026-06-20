# =============================================================================
#  MAKA Portfolio Manager v4.0
#  Gerenciador de Mídias do Portfólio — github.com/DiogoAlbq/PortfolioMaka
#  Uso: .\manage-portfolio.ps1
# =============================================================================

$ErrorActionPreference = "SilentlyContinue"
$dataFile = Join-Path $PSScriptRoot "src\data.tsx"
$siteUrl  = "https://DiogoAlbq.github.io/PortfolioMaka/"
$lastAction = ""

# =============================================================================
#  DICIONÁRIO GLOBAL DE CATEGORIAS (deve vir antes das funções)
# =============================================================================
$global:arrays = @{
    "1" = @{ Name = "artItems";   Label = "Artes (Ilustrações)"; Type = "image"; Color = "Yellow"  }
    "2" = @{ Name = "videoItems"; Label = "Vídeos";              Type = "video"; Color = "Cyan"    }
    "3" = @{ Name = "nsfwItems";  Label = "NSFW (18+)";          Type = "image"; Color = "Red"     }
}

# =============================================================================
#  FUNÇÕES DE INTERFACE (UI)
# =============================================================================
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
    Write-Host "Portfolio Manager  v4.0" -NoNewline -ForegroundColor White
    Write-Host "                 ║" -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

    if ($Subtitle) {
        Write-Host ""
        Write-Host "  ┌──────────────────────────────────────────────────┐" -ForegroundColor DarkGray
        Write-Host "  │  $($Subtitle.PadRight(48))│" -ForegroundColor White
        Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor DarkGray
    }

    if ($script:lastAction) {
        Write-Host "  ✓ Última ação: $script:lastAction" -ForegroundColor DarkGreen
    }
    Write-Host ""
}

function Write-Section($title) {
    Write-Host "  ┌─── $title " -NoNewline -ForegroundColor Cyan
    $pad = 45 - $title.Length
    if ($pad -lt 0) { $pad = 0 }
    Write-Host (("─" * $pad) + "┐") -ForegroundColor Cyan
}

function Write-SectionEnd {
    Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor Cyan
}

function Write-OK($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ⚠ $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  ✗ $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  · $msg" -ForegroundColor DarkGray }
function Write-Sep        { Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray }

function Pause-Screen {
    Write-Host ""
    Write-Host "  " -NoNewline
    Read-Host "[ ENTER para continuar ]" | Out-Null
}

function Prompt-Choice {
    param([string]$Message, [string[]]$ValidOptions)
    while ($true) {
        Write-Host "  " -NoNewline
        $choice = Read-Host $Message
        if ($ValidOptions -contains $choice) { return $choice }
        Write-Warn "Opção inválida '$choice'. Escolha: $($ValidOptions -join ', ')"
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
        Write-Warn "Digite um número entre $Min e $Max."
    }
}

# =============================================================================
#  FUNÇÕES DE DADOS
# =============================================================================
function Get-DataContent {
    if (-not (Test-Path $dataFile)) {
        Write-Err "Arquivo não encontrado: $dataFile"
        exit 1
    }
    return Get-Content $dataFile -Raw -Encoding UTF8
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
        $hasDouble = $itemText -match "double:\s*true"

        $items += [PSCustomObject]@{
            Index    = $index
            Type     = $type
            Color    = $color
            MediaUrl = $mediaUrl
            Double   = $hasDouble
            Raw      = $m.Value
            ArrayName = $ArrayName
        }
        $index++
    }
    return $items
}

function Get-PortfolioStats {
    $stats = @{ TotalItems = 0; WithUrl = 0; Empty = 0; Images = 0; Videos = 0 }
    foreach ($cat in $global:arrays.Values) {
        $items = Parse-PortfolioItems $cat.Name
        foreach ($item in $items) {
            $stats.TotalItems++
            if ($item.Type -eq "image") { $stats.Images++ } else { $stats.Videos++ }
            if ($item.MediaUrl) { $stats.WithUrl++ } else { $stats.Empty++ }
        }
    }
    return $stats
}

function Show-Stats {
    $s = Get-PortfolioStats
    $filled = if ($s.TotalItems -gt 0) { [math]::Round(($s.WithUrl / [double]$s.TotalItems) * 100) } else { 0 }
    
    $tStr = $s.TotalItems.ToString().PadRight(4)
    $iStr = $s.Images.ToString().PadRight(4)
    $vStr = $s.Videos.ToString().PadRight(4)
    
    Write-Host "  ┌─── Status do Portfólio ──────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  Total: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $tStr -NoNewline -ForegroundColor White
    Write-Host " Imagens: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $iStr -NoNewline -ForegroundColor Yellow
    Write-Host " Vídeos: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $vStr -NoNewline -ForegroundColor Cyan
    Write-Host (" " * 10 + "│") -ForegroundColor DarkCyan

    $wStr = $s.WithUrl.ToString().PadRight(4)
    $eStr = $s.Empty.ToString().PadRight(4)
    $fStr = "$filled%".PadRight(4)
    Write-Host "  │  Com URL: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $wStr -NoNewline -ForegroundColor Green
    Write-Host " Vazios:  " -NoNewline -ForegroundColor DarkCyan
    Write-Host $eStr -NoNewline -ForegroundColor DarkGray
    Write-Host " Preench: " -NoNewline -ForegroundColor DarkCyan
    Write-Host $fStr -NoNewline -ForegroundColor $(if ($filled -ge 70) { "Green" } elseif ($filled -ge 40) { "Yellow" } else { "Red" })
    Write-Host (" " * 7 + "│") -ForegroundColor DarkCyan
    Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Show-Items {
    param([string]$ArrayName, [string]$Label, [string]$LabelColor = "Magenta")
    $items = Parse-PortfolioItems $ArrayName
    Write-Host "  ┌─── $Label " -NoNewline -ForegroundColor $LabelColor
    $pad = 45 - $Label.Length
    if ($pad -lt 0) { $pad = 0 }
    Write-Host (("─" * $pad) + "┐") -ForegroundColor $LabelColor

    if ($items.Count -eq 0) {
        Write-Host "  │  (galeria vazia)$(' ' * 31)│" -ForegroundColor DarkGray
    } else {
        foreach ($item in $items) {
            $num = "[$($item.Index + 1)]".PadRight(4)
            $typeTag = if ($item.Type -eq 'image') { "IMG" } else { "VID" }
            $doubleTag = if ($item.Double) { "★" } else { " " }
            Write-Host "  │ " -NoNewline -ForegroundColor $LabelColor
            Write-Host "$num" -NoNewline -ForegroundColor Cyan
            Write-Host " $typeTag$doubleTag " -NoNewline -ForegroundColor $(if ($item.Type -eq 'video') { "Cyan" } else { "Yellow" })
            if ($item.MediaUrl) {
                $url = $item.MediaUrl
                if ($url.Length -gt 36) { $url = $url.Substring(0,33) + "..." }
                Write-Host $url -NoNewline -ForegroundColor Green
                Write-Host (" " * (36 - $url.Length) + " │") -ForegroundColor $LabelColor
            } else {
                Write-Host "(vazio - sem mídia)$(' ' * 18)│" -ForegroundColor DarkGray
            }
        }
    }
    Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor $LabelColor
    Write-Host ""
}

# =============================================================================
#  MODIFICADORES DO data.tsx
# =============================================================================
function Set-ItemUrl {
    param([string]$ArrayName, [int]$ItemIndex, [string]$NewUrl)
    # Re-lê o arquivo a cada chamada para garantir consistência
    $content = Get-DataContent
    $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { return $false }

    $block = $match.Groups[1].Value
    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { return $false }

    $oldItemMatch = $itemMatches[$ItemIndex]
    $oldItem = $oldItemMatch.Value
    $oldItemIndex = $oldItemMatch.Index
    $oldItemLength = $oldItemMatch.Length

    $prefix = $block.Substring(0, $oldItemIndex)
    $suffix = $block.Substring($oldItemIndex + $oldItemLength)

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
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

function Add-Item {
    param([string]$ArrayName, [string]$Type, [string]$MediaUrl, [bool]$Double = $false)
    $content = Get-DataContent
    switch ($ArrayName) {
        "artItems"   { $color = "from-amber-200 to-yellow-200"; $iconColor = "text-amber-600";  $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
        "videoItems" { $color = "from-orange-200 to-yellow-200"; $iconColor = "text-orange-600"; $iconJsx = "<Video className=`"w-10 h-10`" />" }
        "nsfwItems"  { $color = "from-red-200 to-rose-200";    $iconColor = "text-red-600";    $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
    }
    $doubleStr = if ($Double) { ", double: true" } else { "" }
    $mediaStr  = if ($MediaUrl) { ", mediaUrl: '$MediaUrl'" } else { "" }
    $newEntry  = "  { type: '$Type', color: '$color', iconColor: '$iconColor', icon: $iconJsx$doubleStr$mediaStr },"
    $newEntryEscaped = $newEntry.Replace('$', '$$')
    $newContent = $content -replace "(export const ${ArrayName}: PortfolioItem\[\] = \[[\s\S]*?)(];)", "`$1`n$newEntryEscaped`n`$2"
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

function Remove-PortfolioSlot {
    param([string]$ArrayName, [int]$ItemIndex)
    $content = Get-DataContent
    $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { return $false }

    $block = $match.Groups[1].Value
    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { return $false }

    $oldItemMatch = $itemMatches[$ItemIndex]
    $oldItemIndex = $oldItemMatch.Index
    $oldItemLength = $oldItemMatch.Length

    $prefix = $block.Substring(0, $oldItemIndex)
    $suffix = $block.Substring($oldItemIndex + $oldItemLength)

    $suffix = $suffix -replace "^,?\s*", ""

    $newBlock = $prefix + $suffix
    $newContent = $content.Replace($block, $newBlock)
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

# --- Wipe de URLs (mantém slots vazios) ---
function Invoke-WipeUrls {
    param([string]$TargetType)
    $count = 0
    foreach ($cat in $global:arrays.Values) {
        # Re-lê a cada iteração de galeria para evitar índices desatualizados
        $items = Parse-PortfolioItems $cat.Name
        foreach ($item in $items) {
            if ($item.Type -eq $TargetType -and $item.MediaUrl) {
                Set-ItemUrl -ArrayName $cat.Name -ItemIndex $item.Index -NewUrl "" | Out-Null
                $count++
            }
        }
    }
    return $count
}

# --- Wipe de Slots completos ---
function Invoke-WipeSlots {
    param([string]$TargetType)
    $count = 0
    foreach ($cat in $global:arrays.Values) {
        # Loop reverso para não quebrar índices ao deletar
        $items = Parse-PortfolioItems $cat.Name
        for ($i = $items.Count - 1; $i -ge 0; $i--) {
            if ($items[$i].Type -eq $TargetType) {
                Remove-PortfolioSlot -ArrayName $cat.Name -ItemIndex $i | Out-Null
                $count++
            }
        }
    }
    return $count
}

# --- Preview do Wipe ---
function Show-WipePreview {
    param([string]$TargetType, [string]$WipeMode)
    $total = 0
    Write-Host "  Itens que serão afetados:" -ForegroundColor Yellow
    Write-Sep
    foreach ($cat in $global:arrays.Values) {
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
    Write-Sep
    return $total
}

# =============================================================================
#  DEPLOY
# =============================================================================
function Deploy-Changes {
    param([string]$CommitMessage = "")
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
    Write-Host "  ║           Sincronizando com GitHub...            ║" -ForegroundColor DarkCyan
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
    Write-Host ""

    Push-Location $PSScriptRoot

    # Build
    Write-Host "  [1/3] " -NoNewline -ForegroundColor DarkGray
    Write-Host "Compilando o site..." -NoNewline -ForegroundColor White
    $buildResult = & npm run build 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host " FALHOU" -ForegroundColor Red
        Write-Err "Verifique erros executando 'npm run build' manualmente."
        Pop-Location; return $false
    }
    Write-Host " OK" -ForegroundColor Green

    # Git add + commit
    Write-Host "  [2/3] " -NoNewline -ForegroundColor DarkGray
    Write-Host "Registrando alterações..." -NoNewline -ForegroundColor White
    & git add -A 2>&1 | Out-Null
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $msg = if ($CommitMessage) { $CommitMessage } else { "Update via Manager v4 — $timestamp" }
    $commitResult = & git commit -m $msg 2>&1
    Write-Host " OK" -ForegroundColor Green

    # Push
    Write-Host "  [3/3] " -NoNewline -ForegroundColor DarkGray
    Write-Host "Enviando para o GitHub..." -NoNewline -ForegroundColor White
    $pushResult = & git push origin main 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host " FALHOU" -ForegroundColor Red
        Write-Err "Erro de rede ou permissão. Tente 'git push origin main' manualmente."
        Pop-Location; return $false
    }
    Write-Host " OK" -ForegroundColor Green

    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║  ✓  Deploy disparado com sucesso!                ║" -ForegroundColor Green
    Write-Host "  ║                                                  ║" -ForegroundColor Green
    Write-Host "  ║  O site atualiza em ~1-3 min:                    ║" -ForegroundColor White
    Write-Host "  ║  $($siteUrl.PadRight(48))║" -ForegroundColor Yellow
    Write-Host "  ║                                                  ║" -ForegroundColor Green
    Write-Host "  ║  Dica: Ctrl+F5 no navegador para limpar cache    ║" -ForegroundColor DarkGray
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green

    Pop-Location
    return $true
}

# =============================================================================
#  FUNÇÕES AUXILIARES DE MENU
# =============================================================================
function Select-Category {
    Write-Host ""
    Write-Host "  Selecione a galeria:" -ForegroundColor White
    foreach ($key in ($global:arrays.Keys | Sort-Object)) {
        $cat = $global:arrays[$key]
        Write-Host "  [$key] $($cat.Label)" -ForegroundColor $cat.Color
    }
    Write-Host "  [0] Voltar" -ForegroundColor DarkGray
    $choice = Prompt-Choice "Galeria" @("1","2","3","0")
    if ($choice -eq "0") { return $null }
    return $global:arrays[$choice]
}

function Do-Wipe {
    param([string]$TargetType, [string]$TypeLabel)
    Write-Header "⚠  WIPE DE $($TypeLabel.ToUpper())"

    Write-Host "  Escolha a ação de limpeza:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] " -NoNewline -ForegroundColor Yellow
    Write-Host "Zerar URLs" -NoNewline -ForegroundColor White
    Write-Host "  — Remove mídias, mas mantém os cards na grade" -ForegroundColor DarkGray
    Write-Host "  [2] " -NoNewline -ForegroundColor Red
    Write-Host "Deletar Slots" -NoNewline -ForegroundColor White
    Write-Host " — Apaga completamente da grade do site" -ForegroundColor DarkGray
    Write-Host "  [0] " -NoNewline -ForegroundColor DarkGray
    Write-Host "Cancelar" -ForegroundColor DarkGray
    Write-Host ""

    $wipeMode = Prompt-Choice "Ação" @("1","2","0")
    if ($wipeMode -eq "0") { return }

    $mode = if ($wipeMode -eq "1") { "url" } else { "slot" }
    $modeLabel = if ($mode -eq "url") { "Zerar URLs" } else { "Deletar Slots" }

    # Preview
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "  ║  ⚠  ATENÇÃO: Ação irreversível!                  ║" -ForegroundColor Red
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    $total = Show-WipePreview -TargetType $TargetType -WipeMode $mode

    if ($total -eq 0) {
        Write-Warn "Nenhum item encontrado para esse tipo de limpeza."
        Pause-Screen
        return
    }

    Write-Host ""
    Write-Host "  Ação  : " -NoNewline -ForegroundColor White; Write-Host $modeLabel -ForegroundColor Red
    Write-Host "  Alvo  : " -NoNewline -ForegroundColor White; Write-Host "Todos os $total item(s) do tipo '$TypeLabel'" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Para confirmar, " -NoNewline -ForegroundColor White
    Write-Host "digite CONFIRMAR" -NoNewline -ForegroundColor Yellow
    Write-Host " (maiúsculo) ou ENTER para cancelar:" -ForegroundColor White
    Write-Host "  " -NoNewline
    $confirm = Read-Host ""

    if ($confirm -ne "CONFIRMAR") {
        Write-Warn "Operação cancelada."
        Start-Sleep -Seconds 1
        return
    }

    Write-Host ""
    Write-Host "  Executando limpeza..." -ForegroundColor DarkGray
    $count = 0
    if ($mode -eq "url") {
        $count = Invoke-WipeUrls -TargetType $TargetType
    } else {
        $count = Invoke-WipeSlots -TargetType $TargetType
    }

    Write-OK "$count item(s) limpos com sucesso."
    $result = Deploy-Changes -CommitMessage "Wipe $TypeLabel ($modeLabel) via Manager v4"
    if ($result) { $script:lastAction = "Wipe de $TypeLabel ($modeLabel) — $count itens afetados" }
    Pause-Screen
}

# =============================================================================
#  LOOP PRINCIPAL
# =============================================================================
while ($true) {
    Write-Header
    Show-Stats

    Write-Host "  ┌─── Menu ─────────────────────────────────────────┐" -ForegroundColor DarkGray
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
    Write-Host "  └──────────────────────────────────────────────────┘" -ForegroundColor DarkGray

    $option = Prompt-Choice "Opção" @("1","2","3","4","5","6","7","8","0")

    switch ($option) {
        "1" {
            Write-Header "Visão Geral — Todas as Mídias"
            foreach ($key in ($global:arrays.Keys | Sort-Object)) {
                $a = $global:arrays[$key]
                Show-Items -ArrayName $a.Name -Label $a.Label -LabelColor $a.Color
            }
            Pause-Screen
        }

        "2" {
            Write-Header "Trocar URL de Mídia"
            $cat = Select-Category
            if ($null -eq $cat) { continue }

            Write-Header "Trocar URL — $($cat.Label)"
            Show-Items -ArrayName $cat.Name -Label $cat.Label -LabelColor $cat.Color

            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Write-Warn "Galeria vazia."; Pause-Screen; continue }

            $idx = (Prompt-Number "Número do item (0 = cancelar)" 0 $items.Count) - 1
            if ($idx -lt 0) { continue }

            $currentUrl = $items[$idx].MediaUrl
            Write-Host ""
            Write-Host "  URL atual: " -NoNewline -ForegroundColor DarkGray
            if ($currentUrl) { Write-Host $currentUrl -ForegroundColor Green }
            else { Write-Host "(nenhuma mídia)" -ForegroundColor DarkGray }
            Write-Info "Deixe vazio + ENTER para remover a mídia (mantém o card)"
            Write-Host "  " -NoNewline
            $newUrl = Read-Host "Nova URL"

            if (Set-ItemUrl -ArrayName $cat.Name -ItemIndex $idx -NewUrl $newUrl) {
                Write-OK "Mídia atualizada localmente."
                $result = Deploy-Changes
                if ($result) {
                    $label = if ($newUrl) { "definida" } else { "removida" }
                    $script:lastAction = "URL do item $($idx+1) ($($cat.Label)) $label"
                }
            }
            Pause-Screen
        }

        "3" {
            Write-Header "Adicionar Nova Mídia"
            $cat = Select-Category
            if ($null -eq $cat) { continue }

            Write-Host ""
            Write-Host "  Tipo de conteúdo:" -ForegroundColor White
            Write-Host "  [1] Imagem (PNG, JPG, Cloudinary...)" -ForegroundColor Yellow
            Write-Host "  [2] Vídeo  (YouTube, TikTok, MP4...)" -ForegroundColor Cyan
            $typeChoice = Prompt-Choice "Tipo" @("1","2")
            $type = if ($typeChoice -eq "2") { "video" } else { "image" }

            Write-Host "  " -NoNewline
            $url = Read-Host "URL da mídia (vazio = card em branco)"

            Write-Host ""
            Write-Host "  [S] Slot duplo (ocupa 2 colunas — ideal para vídeos horizontais)" -ForegroundColor DarkGray
            Write-Host "  [N] Slot normal" -ForegroundColor DarkGray
            $doubleChoice = Prompt-Choice "Tamanho (S/N)" @("s","S","n","N")
            $isDouble = $doubleChoice -match "^[sS]$"

            if (Add-Item -ArrayName $cat.Name -Type $type -MediaUrl $url -Double $isDouble) {
                Write-OK "Mídia adicionada localmente."
                $result = Deploy-Changes
                if ($result) { $script:lastAction = "Nova mídia adicionada à galeria $($cat.Label)" }
            }
            Pause-Screen
        }

        "4" {
            Write-Header "Remover Slot de Mídia"
            $cat = Select-Category
            if ($null -eq $cat) { continue }

            Write-Header "Remover — $($cat.Label)"
            Show-Items -ArrayName $cat.Name -Label $cat.Label -LabelColor $cat.Color

            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Write-Warn "Galeria vazia."; Pause-Screen; continue }

            $idx = (Prompt-Number "Número do slot para DELETAR (0 = cancelar)" 0 $items.Count) - 1
            if ($idx -lt 0) { continue }

            $confirm = Prompt-Choice "Tem certeza? (S/N)" @("s","S","n","N")
            if ($confirm -match "^[sS]$") {
                if (Remove-PortfolioSlot -ArrayName $cat.Name -ItemIndex $idx) {
                    Write-OK "Slot removido localmente."
                    $result = Deploy-Changes
                    if ($result) { $script:lastAction = "Slot $($idx+1) removido da galeria $($cat.Label)" }
                }
            } else {
                Write-Warn "Cancelado."
            }
            Pause-Screen
        }

        "5" {
            Write-Header "Deploy Manual"
            $result = Deploy-Changes
            if ($result) { $script:lastAction = "Deploy manual" }
            Pause-Screen
        }

        "6" {
            Do-Wipe -TargetType "image" -TypeLabel "Imagens"
        }

        "7" {
            Do-Wipe -TargetType "video" -TypeLabel "Vídeos"
        }

        "8" {
            Write-Header "Configurações do Site"
            $content = Get-DataContent
            $rateMatch = [regex]::Match($content, "export const exchangeRate = ([\d\.]+);")

            if ($rateMatch.Success) {
                $currentRate = $rateMatch.Groups[1].Value
                Write-Host "  Taxa de câmbio atual (USD → BRL): " -NoNewline -ForegroundColor White
                Write-Host "R$ $currentRate" -ForegroundColor Green
                Write-Host ""
                Write-Host "  " -NoNewline
                $newRate = Read-Host "Nova taxa (ex: 5.80) ou ENTER para cancelar"

                if (-not [string]::IsNullOrWhiteSpace($newRate)) {
                    if ($newRate -match "^[\d\.]+$") {
                        $newContent = $content -replace "export const exchangeRate = [\d\.]+;", "export const exchangeRate = $newRate;"
                        Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
                        Write-OK "Taxa atualizada localmente para R$ $newRate."
                        $result = Deploy-Changes -CommitMessage "Update exchangeRate to $newRate via Manager v4"
                        if ($result) { $script:lastAction = "Taxa de câmbio atualizada → R$ $newRate" }
                    } else {
                        Write-Err "Valor inválido. Use apenas números e ponto (ex: 5.50)."
                    }
                }
            } else {
                Write-Err "Variável 'exchangeRate' não encontrada em data.tsx."
            }
            Pause-Screen
        }

        "0" {
            Write-Host ""
            Write-Host "  Até a próxima, Maka! ✨" -ForegroundColor Magenta
            Write-Host ""
            break
        }
    }
}
