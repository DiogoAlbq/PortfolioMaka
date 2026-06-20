# =============================================================================
#  MAKA Portfolio Manager - Gerenciador de Midias do Portfolio
#  Uso: .\manage-portfolio.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$dataFile = Join-Path $PSScriptRoot "src\data.tsx"

# --- Cores para o terminal ---
function Write-Header { Write-Host "`n========================================" -ForegroundColor Cyan; Write-Host "   MAKA Portfolio Manager" -ForegroundColor Yellow; Write-Host "========================================`n" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "  [ERRO] $msg" -ForegroundColor Red }
function Write-Sep { Write-Host "  ----------------------------------------" -ForegroundColor DarkGray }

# --- Leitura do data.tsx ---
function Get-DataContent {
    if (-not (Test-Path $dataFile)) { Write-Err "Arquivo nao encontrado: $dataFile"; exit 1 }
    return Get-Content $dataFile -Raw -Encoding UTF8
}

# --- Parsing dos itens de portfolio ---
function Parse-PortfolioItems {
    param([string]$ArrayName)
    $content = Get-DataContent
    
    # Captura o bloco do array
    $pattern = "export const ${ArrayName}: PortfolioItem\[\] = \[([\s\S]*?)\];"
    $match = [regex]::Match($content, $pattern)
    if (-not $match.Success) { return @() }
    
    $block = $match.Groups[1].Value
    $items = @()
    $index = 0
    
    # Encontra cada objeto { ... }
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
    
    Write-Host "`n  === $Label ===" -ForegroundColor Magenta
    Write-Sep
    foreach ($item in $items) {
        $num = $item.Index + 1
        $typeLabel = if ($item.Type -eq 'image') { "Imagem" } else { "Video" }
        $urlDisplay = if ($item.MediaUrl) { $item.MediaUrl } else { "(sem midia - placeholder)" }
        $doubleTag = if ($item.Double) { " [DUPLO]" } else { "" }
        
        Write-Host "  [$num] " -NoNewline -ForegroundColor Yellow
        Write-Host "$typeLabel$doubleTag" -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor DarkGray
        if ($item.MediaUrl) {
            Write-Host "$urlDisplay" -ForegroundColor Green
        } else {
            Write-Host "$urlDisplay" -ForegroundColor DarkYellow
        }
    }
    Write-Sep
}

# --- Altera a URL de um item ---
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
    
    if ($NewUrl -eq "") {
        # Remover mediaUrl se existe
        $newItem = $oldItem -replace ",?\s*mediaUrl:\s*'[^']*'", ""
    } elseif ($oldItem -match "mediaUrl:\s*'[^']*'") {
        # Substituir URL existente
        $newItem = $oldItem -replace "mediaUrl:\s*'[^']*'", "mediaUrl: '$NewUrl'"
    } else {
        # Adicionar mediaUrl antes do ultimo }
        $newItem = $oldItem -replace '\}$', ", mediaUrl: '$NewUrl' }"
    }
    
    $newContent = $content.Replace($oldItem, $newItem)
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

# --- Adiciona um novo item ao array ---
function Add-Item {
    param([string]$ArrayName, [string]$Type, [string]$MediaUrl, [bool]$Double = $false)
    $content = Get-DataContent
    
    # Configura cor e icone baseado no array e tipo
    switch ($ArrayName) {
        "artItems"  { $color = "from-amber-200 to-yellow-200"; $iconColor = "text-amber-600"; $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
        "videoItems" { $color = "from-orange-200 to-yellow-200"; $iconColor = "text-orange-600"; $iconJsx = "<Video className=`"w-10 h-10`" />" }
        "nsfwItems" { $color = "from-red-200 to-rose-200"; $iconColor = "text-red-600"; $iconJsx = "<ImageIcon className=`"w-10 h-10`" />" }
    }
    
    $doubleStr = if ($Double) { ", double: true" } else { "" }
    $mediaStr = if ($MediaUrl) { ", mediaUrl: '$MediaUrl'" } else { "" }
    $newEntry = "  { type: '$Type', color: '$color', iconColor: '$iconColor', icon: $iconJsx$doubleStr$mediaStr },"
    
    # Insere antes do ]; final do array
    $pattern = "(export const ${ArrayName}: PortfolioItem\[\] = \[[\s\S]*?)(^\];)"
    $content = Get-DataContent
    $newContent = $content -replace "(export const ${ArrayName}: PortfolioItem\[\] = \[[\s\S]*?)(];)", "`$1`n$newEntry`n`$2"
    
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

# --- Remove um item do array ---
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
    # Remove o item e virgula/espaços ao redor
    $newBlock = $block -replace [regex]::Escape($oldItem) + ",?\s*", ""
    
    $newContent = $content.Replace($block, $newBlock)
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

# --- Faz build, commit e push automatico ---
function Deploy-Changes {
    param([string]$CommitMsg = "Update portfolio media")
    Write-Host "`n  Fazendo deploy automatico..." -ForegroundColor Cyan
    
    try {
        Push-Location $PSScriptRoot
        
        Write-Host "  [1/4] Compilando projeto..." -ForegroundColor DarkGray
        npm run build 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Err "Build falhou!"; Pop-Location; return }
        Write-Success "Build concluido."
        
        Write-Host "  [2/4] Preparando arquivos..." -ForegroundColor DarkGray
        git add src/data.tsx index.html 2>&1 | Out-Null
        Write-Success "Arquivos preparados."
        
        Write-Host "  [3/4] Criando commit..." -ForegroundColor DarkGray
        git commit -m $CommitMsg 2>&1 | Out-Null
        Write-Success "Commit: $CommitMsg"
        
        Write-Host "  [4/4] Enviando para o GitHub..." -ForegroundColor DarkGray
        git push origin main 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Err "Push falhou! Verifique suas credenciais."; Pop-Location; return }
        Write-Success "Push concluido! O GitHub Actions vai publicar automaticamente."
        
        Write-Host "`n  Seu site sera atualizado em ~1 minuto em:" -ForegroundColor Green
        Write-Host "  https://DiogoAlbq.github.io/PortfolioMaka/`n" -ForegroundColor Yellow
        
        Pop-Location
    } catch {
        Write-Err "Erro durante o deploy: $_"
        Pop-Location
    }
}

# --- Mapeamento de arrays ---
$arrays = @{
    "1" = @{ Name = "artItems"; Label = "Artes (Ilustracoes)" }
    "2" = @{ Name = "videoItems"; Label = "Videos" }
    "3" = @{ Name = "nsfwItems"; Label = "NSFW (18+)" }
}

# ========================
#  MENU PRINCIPAL
# ========================
function Show-Menu {
    Write-Header
    Write-Host "  Escolha uma opcao:`n" -ForegroundColor White
    Write-Host "  [1] " -NoNewline -ForegroundColor Yellow; Write-Host "Listar todas as midias do portfolio" -ForegroundColor White
    Write-Host "  [2] " -NoNewline -ForegroundColor Yellow; Write-Host "Alterar URL de uma midia existente" -ForegroundColor White
    Write-Host "  [3] " -NoNewline -ForegroundColor Yellow; Write-Host "Adicionar nova midia" -ForegroundColor White
    Write-Host "  [4] " -NoNewline -ForegroundColor Yellow; Write-Host "Remover uma midia" -ForegroundColor White
    Write-Host "  [5] " -NoNewline -ForegroundColor Yellow; Write-Host "Fazer deploy (publicar alteracoes no site)" -ForegroundColor White
    Write-Host "  [0] " -NoNewline -ForegroundColor Red; Write-Host "Sair`n" -ForegroundColor White
}

function Select-Category {
    Write-Host "`n  Qual categoria?" -ForegroundColor White
    Write-Host "  [1] Artes (Ilustracoes)" -ForegroundColor Yellow
    Write-Host "  [2] Videos" -ForegroundColor Yellow
    Write-Host "  [3] NSFW (18+)" -ForegroundColor Yellow
    $choice = Read-Host "`n  Opcao"
    if ($arrays.ContainsKey($choice)) { return $arrays[$choice] }
    Write-Warn "Opcao invalida."; return $null
}

# --- Loop principal ---
$hasChanges = $false

while ($true) {
    Show-Menu
    $option = Read-Host "  Opcao"
    
    switch ($option) {
        "1" {
            # Listar
            foreach ($key in ($arrays.Keys | Sort-Object)) {
                $a = $arrays[$key]
                Show-Items -ArrayName $a.Name -Label $a.Label
            }
            Read-Host "`n  Pressione ENTER para voltar ao menu"
        }
        "2" {
            # Alterar URL
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            Show-Items -ArrayName $cat.Name -Label $cat.Label
            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { continue }
            
            $num = Read-Host "`n  Numero do item para alterar"
            $idx = [int]$num - 1
            if ($idx -lt 0 -or $idx -ge $items.Count) { Write-Err "Numero invalido."; continue }
            
            Write-Host "`n  URL atual: " -NoNewline -ForegroundColor DarkGray
            $currentUrl = $items[$idx].MediaUrl
            if ($currentUrl) { Write-Host $currentUrl -ForegroundColor Green }
            else { Write-Host "(vazio)" -ForegroundColor DarkYellow }
            
            $newUrl = Read-Host "  Nova URL (deixe vazio para remover)"
            
            if (Set-ItemUrl -ArrayName $cat.Name -ItemIndex $idx -NewUrl $newUrl) {
                if ($newUrl) { Write-Success "URL atualizada com sucesso!" }
                else { Write-Success "URL removida com sucesso!" }
                $hasChanges = $true
            }
        }
        "3" {
            # Adicionar
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Host "`n  Tipo de midia:" -ForegroundColor White
            Write-Host "  [1] Imagem" -ForegroundColor Yellow
            Write-Host "  [2] Video" -ForegroundColor Yellow
            $typeChoice = Read-Host "  Opcao"
            $type = if ($typeChoice -eq "2") { "video" } else { "image" }
            
            $url = Read-Host "  URL da midia (ou ENTER para placeholder)"
            
            $doubleChoice = Read-Host "  Ocupa 2 colunas no grid? (s/N)"
            $isDouble = $doubleChoice -eq "s" -or $doubleChoice -eq "S"
            
            if (Add-Item -ArrayName $cat.Name -Type $type -MediaUrl $url -Double $isDouble) {
                Write-Success "Item adicionado com sucesso!"
                $hasChanges = $true
            }
        }
        "4" {
            # Remover
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            Show-Items -ArrayName $cat.Name -Label $cat.Label
            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { continue }
            
            $num = Read-Host "`n  Numero do item para REMOVER"
            $idx = [int]$num - 1
            if ($idx -lt 0 -or $idx -ge $items.Count) { Write-Err "Numero invalido."; continue }
            
            $confirm = Read-Host "  Tem certeza que quer remover o item $num? (s/N)"
            if ($confirm -eq "s" -or $confirm -eq "S") {
                if (Remove-Item-FromArray -ArrayName $cat.Name -ItemIndex $idx) {
                    Write-Success "Item removido com sucesso!"
                    $hasChanges = $true
                }
            } else {
                Write-Warn "Operacao cancelada."
            }
        }
        "5" {
            # Deploy
            if (-not $hasChanges) { 
                Write-Warn "Nenhuma alteracao pendente para publicar."
                $forceDeploy = Read-Host "  Deseja forcar o deploy mesmo assim? (s/N)"
                if ($forceDeploy -ne "s" -and $forceDeploy -ne "S") { continue }
            }
            Deploy-Changes -CommitMsg "Update portfolio media via manager"
            $hasChanges = $false
        }
        "0" {
            if ($hasChanges) {
                Write-Warn "Voce tem alteracoes nao publicadas!"
                $deployNow = Read-Host "  Deseja fazer deploy antes de sair? (s/N)"
                if ($deployNow -eq "s" -or $deployNow -eq "S") {
                    Deploy-Changes -CommitMsg "Update portfolio media via manager"
                }
            }
            Write-Host "`n  Ate mais! " -ForegroundColor Cyan
            break
        }
        default {
            Write-Warn "Opcao invalida. Tente novamente."
        }
    }
}
