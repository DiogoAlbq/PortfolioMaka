# =============================================================================
#  MAKA Portfolio Manager - Gerenciador de Midias do Portfolio
#  Uso: .\manage-portfolio.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$dataFile = Join-Path $PSScriptRoot "src\data.tsx"

# --- Interface Visual (UI) ---
function Write-Header { 
    Clear-Host
    Write-Host ""
    Write-Host "  ███╗   ███╗ █████╗ ██╗  ██╗███████╗" -ForegroundColor Cyan
    Write-Host "  ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝" -ForegroundColor Cyan
    Write-Host "  ██╔████╔██║███████║█████╔╝ ███████╗" -ForegroundColor Yellow
    Write-Host "  ██║╚██╔╝██║██╔══██║██╔═██╗ ╚════██║" -ForegroundColor Yellow
    Write-Host "  ██║ ╚═╝ ██║██║  ██║██║  ██╗███████║" -ForegroundColor Magenta
    Write-Host "  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "       PORTFOLIO MANAGER v2.0       " -ForegroundColor White -BackgroundColor DarkMagenta
    Write-Host "========================================" -ForegroundColor DarkGray
}

function Write-Success($msg) { Write-Host "  [ v ] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [ ! ] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "  [ x ] $msg" -ForegroundColor Red }
function Write-Sep { Write-Host "  ----------------------------------------" -ForegroundColor DarkGray }

function Pause-Screen {
    Write-Host ""
    Read-Host "  Pressione [ENTER] para continuar..." | Out-Null
}

# --- Leitura do data.tsx ---
function Get-DataContent {
    if (-not (Test-Path $dataFile)) { Write-Err "Arquivo nao encontrado: $dataFile"; exit 1 }
    return Get-Content $dataFile -Raw -Encoding UTF8
}

# --- Parsing dos itens de portfolio ---
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
        if ($itemText -match "type:\s*'([^']+)'") { $type = $Matches[1] }
        if ($itemText -match "color:\s*'([^']+)'") { $color = $Matches[1] }
        if ($itemText -match "mediaUrl:\s*'([^']+)'") { $mediaUrl = $Matches[1] }
        $hasDouble = $itemText -match "double:\s*true"
        
        $items += [PSCustomObject]@{
            Index = $index
            Type = $type
            Color = $color
            MediaUrl = $mediaUrl
            Double = $hasDouble
            Raw = $m.Value
        }
        $index++
    }
    return $items
}

# --- Exibe lista formatada ---
function Show-Items {
    param([string]$ArrayName, [string]$Label)
    $items = Parse-PortfolioItems $ArrayName
    if ($items.Count -eq 0) { Write-Warn "Nenhum item encontrado em '$Label'."; return }
    
    Write-Host "`n  :: $Label ::" -ForegroundColor Magenta
    Write-Sep
    foreach ($item in $items) {
        $num = ($item.Index + 1).ToString().PadLeft(2, '0')
        $typeLabel = if ($item.Type -eq 'image') { "Imagem" } else { "Video " }
        $urlDisplay = if ($item.MediaUrl) { $item.MediaUrl } else { "(sem midia vinculada)" }
        $doubleTag = if ($item.Double) { " [DESTAQUE]" } else { "" }
        
        Write-Host "  [$num] " -NoNewline -ForegroundColor Yellow
        Write-Host "$typeLabel$doubleTag" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        if ($item.MediaUrl) {
            Write-Host "$urlDisplay" -ForegroundColor Green
        } else {
            Write-Host "$urlDisplay" -ForegroundColor DarkGray
        }
    }
    Write-Sep
}

# --- Modificadores do Arquivo ---
function Set-ItemUrl {
    param([string]$ArrayName, [int]$ItemIndex, [string]$NewUrl)
    $content = Get-DataContent
    $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { Write-Err "Array '$ArrayName' nao encontrado."; return $false }
    
    $block = $match.Groups[1].Value
    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { Write-Err "Indice invalido."; return $false }
    
    $oldItem = $itemMatches[$ItemIndex].Value
    
    if ([string]::IsNullOrWhiteSpace($NewUrl)) {
        $newItem = $oldItem -replace ",?\s*mediaUrl:\s*'[^']*'", ""
    } elseif ($oldItem -match "mediaUrl:\s*'[^']*'") {
        $newItem = $oldItem -replace "mediaUrl:\s*'[^']*'", "mediaUrl: '$NewUrl'"
    } else {
        $newItem = $oldItem -replace '\}$', ", mediaUrl: '$NewUrl' }"
    }
    
    $newContent = $content.Replace($oldItem, $newItem)
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

function Add-Item {
    param([string]$ArrayName, [string]$Type, [string]$MediaUrl, [bool]$Double = $false)
    $content = Get-DataContent
    
    switch ($ArrayName) {
        "artItems"  { $color = "from-amber-200 to-yellow-200"; $iconColor = "text-amber-600"; $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
        "videoItems" { $color = "from-orange-200 to-yellow-200"; $iconColor = "text-orange-600"; $iconJsx = "<Video className=`"w-10 h-10`" />" }
        "nsfwItems" { $color = "from-red-200 to-rose-200"; $iconColor = "text-red-600"; $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
    }
    
    $doubleStr = if ($Double) { ", double: true" } else { "" }
    $mediaStr = if ($MediaUrl) { ", mediaUrl: '$MediaUrl'" } else { "" }
    $newEntry = "  { type: '$Type', color: '$color', iconColor: '$iconColor', icon: $iconJsx$doubleStr$mediaStr },"
    
    $newContent = $content -replace "(export const ${ArrayName}: PortfolioItem\[\] = \[[\s\S]*?)(];)", "`$1`n$newEntry`n`$2"
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

function Remove-Item-FromArray {
    param([string]$ArrayName, [int]$ItemIndex)
    $content = Get-DataContent
    $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { Write-Err "Array '$ArrayName' nao encontrado."; return $false }
    
    $block = $match.Groups[1].Value
    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { Write-Err "Indice invalido."; return $false }
    
    $oldItem = $itemMatches[$ItemIndex].Value
    $newBlock = $block -replace [regex]::Escape($oldItem) + ",?\s*", ""
    $newContent = $content.Replace($block, $newBlock)
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

# --- Deploy Automatico (Oculto/Limpo) ---
function Deploy-Changes {
    Write-Host "`n  [ Iniciando Sincronizacao Automatica com o GitHub ]" -ForegroundColor Cyan
    
    try {
        Push-Location $PSScriptRoot
        
        Write-Host "  > Compilando o site (pode levar alguns segundos)... " -NoNewline -ForegroundColor DarkGray
        $buildOutput = npm run build 2>&1
        if ($LASTEXITCODE -ne 0) { 
            Write-Host "FALHOU!" -ForegroundColor Red
            Write-Err "Erro no Build. Execute 'npm run build' manualmente para ver o erro."
            Pop-Location; return 
        }
        Write-Host "OK!" -ForegroundColor Green
        
        Write-Host "  > Registrando alteracoes no Git... " -NoNewline -ForegroundColor DarkGray
        git add src/data.tsx index.html 2>&1 | Out-Null
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        git commit -m "Auto-update portfolio media: $timestamp" 2>&1 | Out-Null
        Write-Host "OK!" -ForegroundColor Green
        
        Write-Host "  > Enviando para o servidor do site... " -NoNewline -ForegroundColor DarkGray
        $pushOutput = git push origin main 2>&1
        if ($LASTEXITCODE -ne 0) { 
            Write-Host "FALHOU!" -ForegroundColor Red
            Write-Err "Erro de rede ou permissao ao enviar para o GitHub."
            Pop-Location; return 
        }
        Write-Host "OK!" -ForegroundColor Green
        
        Write-Host "`n  ========================================================" -ForegroundColor Cyan
        Write-Success "Deploy disparado com SUCESSO!"
        Write-Host "  O site atualizado estara no ar em ~1 minuto em:" -ForegroundColor White
        Write-Host "  https://DiogoAlbq.github.io/PortfolioMaka/" -ForegroundColor Yellow
        Write-Host "  ========================================================" -ForegroundColor Cyan
        
        Pop-Location
    } catch {
        Write-Err "Erro inesperado durante o deploy: $_"
        Pop-Location
    }
}

# --- Dicionario de Categorias ---
$arrays = @{
    "1" = @{ Name = "artItems"; Label = "Artes (Ilustracoes)" }
    "2" = @{ Name = "videoItems"; Label = "Videos" }
    "3" = @{ Name = "nsfwItems"; Label = "NSFW (18+)" }
}

function Select-Category {
    Write-Host "`n  Selecione a Galeria:" -ForegroundColor White
    Write-Host "  [1] Artes (Ilustracoes)" -ForegroundColor Yellow
    Write-Host "  [2] Videos" -ForegroundColor Yellow
    Write-Host "  [3] NSFW (18+)" -ForegroundColor Yellow
    Write-Host "  [0] Voltar" -ForegroundColor DarkGray
    
    $choice = Read-Host "`n  Sua opcao"
    if ($choice -eq "0") { return $null }
    if ($arrays.ContainsKey($choice)) { return $arrays[$choice] }
    Write-Warn "Opcao invalida."; return $null
}

# ========================
#  LOOP PRINCIPAL
# ========================
while ($true) {
    Write-Header
    Write-Host "  Menu de Acoes:" -ForegroundColor White
    Write-Host "  [1] " -NoNewline -ForegroundColor Cyan; Write-Host "Visao Geral (Listar todas as midias)" -ForegroundColor White
    Write-Host "  [2] " -NoNewline -ForegroundColor Yellow; Write-Host "Trocar URL de uma midia existente" -ForegroundColor White
    Write-Host "  [3] " -NoNewline -ForegroundColor Green; Write-Host "Adicionar NOVA midia ao site" -ForegroundColor White
    Write-Host "  [4] " -NoNewline -ForegroundColor Red; Write-Host "Remover uma midia do site" -ForegroundColor White
    Write-Host "  [5] " -NoNewline -ForegroundColor Magenta; Write-Host "Forcar Sincronizacao / Deploy" -ForegroundColor White
    Write-Host "  [0] " -NoNewline -ForegroundColor DarkGray; Write-Host "Sair do Gerenciador" -ForegroundColor White
    
    $option = Read-Host "`n  O que deseja fazer?"
    
    switch ($option) {
        "1" {
            Write-Header
            foreach ($key in ($arrays.Keys | Sort-Object)) {
                $a = $arrays[$key]
                Show-Items -ArrayName $a.Name -Label $a.Label
            }
            Pause-Screen
        }
        "2" {
            Write-Header
            Write-Host "  > TROCAR URL DE MIDIA <" -ForegroundColor Yellow
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Header
            Show-Items -ArrayName $cat.Name -Label $cat.Label
            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Pause-Screen; continue }
            
            $num = Read-Host "`n  Qual o NUMERO da midia que deseja alterar?"
            $idx = [int]$num - 1
            if ($idx -lt 0 -or $idx -ge $items.Count) { Write-Err "Numero invalido."; Pause-Screen; continue }
            
            Write-Host "`n  URL atual: " -NoNewline -ForegroundColor DarkGray
            $currentUrl = $items[$idx].MediaUrl
            if ($currentUrl) { Write-Host $currentUrl -ForegroundColor Green }
            else { Write-Host "(vazio)" -ForegroundColor DarkGray }
            
            Write-Host "  (Dica: Deixe vazio e aperte ENTER para apenas remover a imagem atual do slot)" -ForegroundColor DarkGray
            $newUrl = Read-Host "  Cole a NOVA URL"
            
            if (Set-ItemUrl -ArrayName $cat.Name -ItemIndex $idx -NewUrl $newUrl) {
                Write-Success "Galeria atualizada localmente!"
                Deploy-Changes
            }
            Pause-Screen
        }
        "3" {
            Write-Header
            Write-Host "  > ADICIONAR NOVA MIDIA <" -ForegroundColor Green
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Host "`n  E uma Imagem ou Video?" -ForegroundColor White
            Write-Host "  [1] Imagem" -ForegroundColor Yellow
            Write-Host "  [2] Video" -ForegroundColor Yellow
            $typeChoice = Read-Host "  Opcao"
            $type = if ($typeChoice -eq "2") { "video" } else { "image" }
            
            Write-Host "`n  Cole o link direto da imagem/video. (Pode deixar vazio para adicionar um card em branco provisorio)" -ForegroundColor DarkGray
            $url = Read-Host "  URL"
            
            Write-Host "`n  Deseja que esse item ocupe o espaco de 2 colunas no site? (ideal para imagens horizontais)" -ForegroundColor DarkGray
            $doubleChoice = Read-Host "  (S/N)"
            $isDouble = $doubleChoice -match "^[sS]"
            
            if (Add-Item -ArrayName $cat.Name -Type $type -MediaUrl $url -Double $isDouble) {
                Write-Success "Midia adicionada localmente!"
                Deploy-Changes
            }
            Pause-Screen
        }
        "4" {
            Write-Header
            Write-Host "  > REMOVER MIDIA <" -ForegroundColor Red
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Header
            Show-Items -ArrayName $cat.Name -Label $cat.Label
            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Pause-Screen; continue }
            
            $num = Read-Host "`n  Qual o NUMERO da midia que deseja REMOVER permanentemente?"
            $idx = [int]$num - 1
            if ($idx -lt 0 -or $idx -ge $items.Count) { Write-Err "Numero invalido."; Pause-Screen; continue }
            
            $confirm = Read-Host "`n  TEM CERTEZA que deseja apagar o slot $num? (S/N)"
            if ($confirm -match "^[sS]") {
                if (Remove-Item-FromArray -ArrayName $cat.Name -ItemIndex $idx) {
                    Write-Success "Slot removido localmente!"
                    Deploy-Changes
                }
            } else {
                Write-Warn "Acao cancelada."
            }
            Pause-Screen
        }
        "5" {
            Write-Header
            Deploy-Changes
            Pause-Screen
        }
        "0" {
            Write-Host "`n  Saindo do gerenciador... Ate a proxima, Maka! `n" -ForegroundColor Cyan
            break
        }
        default {
            Write-Warn "Opcao invalida. Tente novamente."
            Start-Sleep -Seconds 1
        }
    }
}
