# =============================================================================
#  MAKA Portfolio Manager - Gerenciador de Midias do Portfolio (v3.0)
#  Uso: .\manage-portfolio.ps1
# =============================================================================

$ErrorActionPreference = "Stop"
$dataFile = Join-Path $PSScriptRoot "src\data.tsx"

# --- Interface Visual (UI) Premium ---
function Write-Header { 
    Clear-Host
    Write-Host ""
    Write-Host "  ╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║  ███╗   ███╗ █████╗ ██╗  ██╗███████╗       ║" -ForegroundColor Cyan
    Write-Host "  ║  ████╗ ████║██╔══██╗██║ ██╔╝██╔════╝       ║" -ForegroundColor Cyan
    Write-Host "  ║  ██╔████╔██║███████║█████╔╝ ███████╗       ║" -ForegroundColor Yellow
    Write-Host "  ║  ██║╚██╔╝██║██╔══██║██╔═██╗ ╚════██║       ║" -ForegroundColor Yellow
    Write-Host "  ║  ██║ ╚═╝ ██║██║  ██║██║  ██╗███████║       ║" -ForegroundColor Magenta
    Write-Host "  ║  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝       ║" -ForegroundColor Magenta
    Write-Host "  ╚════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "           PORTFOLIO MANAGER v3.0           " -ForegroundColor White -BackgroundColor DarkMagenta
    Write-Host "  ──────────────────────────────────────────────" -ForegroundColor DarkGray
}

function Write-Success($msg) { Write-Host "  [ v ] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  [ ! ] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "  [ x ] $msg" -ForegroundColor Red }
function Write-Sep { Write-Host "  ──────────────────────────────────────────────" -ForegroundColor DarkGray }

function Pause-Screen {
    Write-Host ""
    Read-Host "  [ Pressione ENTER para continuar ]" | Out-Null
}

function Prompt-Choice($message, $validOptions) {
    while ($true) {
        $choice = Read-Host "  $message"
        if ($validOptions -contains $choice) { return $choice }
        Write-Warn "Opção inválida. Tente novamente."
    }
}

# --- Leitura do data.tsx ---
function Get-DataContent {
    if (-not (Test-Path $dataFile)) { Write-Err "Arquivo não encontrado: $dataFile"; exit 1 }
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
            ArrayName = $ArrayName
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
        $typeLabel = if ($item.Type -eq 'image') { "Imagem" } else { "Vídeo " }
        $urlDisplay = if ($item.MediaUrl) { $item.MediaUrl } else { "(vazio - sem mídia vinculada)" }
        $doubleTag = if ($item.Double) { " [DESTAQUE]" } else { "" }
        
        Write-Host "  [$num] " -NoNewline -ForegroundColor Cyan
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
    if (-not $match.Success) { return $false }
    
    $block = $match.Groups[1].Value
    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { return $false }
    
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
    if (-not $match.Success) { return $false }
    
    $block = $match.Groups[1].Value
    $itemMatches = [regex]::Matches($block, '\{([^{}]*(?:\{[^{}]*\}[^{}]*)*)\}')
    if ($ItemIndex -lt 0 -or $ItemIndex -ge $itemMatches.Count) { return $false }
    
    $oldItem = $itemMatches[$ItemIndex].Value
    $newBlock = $block -replace [regex]::Escape($oldItem) + ",?\s*", ""
    $newContent = $content.Replace($block, $newBlock)
    Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
    return $true
}

# --- Wipe Functions (Limpeza em Massa) ---
function Wipe-MediaUrls {
    param([string]$TargetType)
    $count = 0
    foreach ($cat in $arrays.Values) {
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

function Wipe-EntireSlots {
    param([string]$TargetType)
    $count = 0
    foreach ($cat in $arrays.Values) {
        # Lê de trás pra frente para não quebrar os índices enquanto deleta
        $items = Parse-PortfolioItems $cat.Name
        for ($i = $items.Count - 1; $i -ge 0; $i--) {
            if ($items[$i].Type -eq $TargetType) {
                Remove-Item-FromArray -ArrayName $cat.Name -ItemIndex $i | Out-Null
                $count++
            }
        }
    }
    return $count
}

# --- Deploy Automatico ---
function Deploy-Changes {
    Write-Host "`n  [ Iniciando Sincronização Automática com o GitHub ]" -ForegroundColor Cyan
    
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
        
        Write-Host "  > Registrando alterações no Git... " -NoNewline -ForegroundColor DarkGray
        git add src/data.tsx index.html src/App.tsx 2>&1 | Out-Null
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        git commit -m "Auto-update portfolio media via Manager v3: $timestamp" 2>&1 | Out-Null
        Write-Host "OK!" -ForegroundColor Green
        
        Write-Host "  > Enviando para o servidor do site... " -NoNewline -ForegroundColor DarkGray
        $pushOutput = git push origin main 2>&1
        if ($LASTEXITCODE -ne 0) { 
            Write-Host "FALHOU!" -ForegroundColor Red
            Write-Err "Erro de rede ou permissão ao enviar para o GitHub."
            Pop-Location; return 
        }
        Write-Host "OK!" -ForegroundColor Green
        
        Write-Host "`n  ╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Success "Deploy disparado com SUCESSO!"
        Write-Host "  ║ O site será atualizado em ~1 a 3 minutos em:                   ║" -ForegroundColor White
        Write-Host "  ║ https://DiogoAlbq.github.io/PortfolioMaka/                     ║" -ForegroundColor Yellow
        Write-Host "  ║ Dica: Pressione Ctrl + F5 no navegador para forçar a limpesa   ║" -ForegroundColor DarkGray
        Write-Host "  ╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        
        Pop-Location
    } catch {
        Write-Err "Erro inesperado durante o deploy: $_"
        Pop-Location
    }
}

# --- Dicionario de Categorias ---
$arrays = @{
    "1" = @{ Name = "artItems"; Label = "Artes (Ilustrações)" }
    "2" = @{ Name = "videoItems"; Label = "Vídeos" }
    "3" = @{ Name = "nsfwItems"; Label = "NSFW (18+)" }
}

function Select-Category {
    Write-Host "`n  Selecione a Galeria:" -ForegroundColor White
    Write-Host "  [1] Artes (Ilustrações)" -ForegroundColor Yellow
    Write-Host "  [2] Vídeos" -ForegroundColor Yellow
    Write-Host "  [3] NSFW (18+)" -ForegroundColor Yellow
    Write-Host "  [0] Voltar" -ForegroundColor DarkGray
    
    $choice = Prompt-Choice "Sua opção" @("1","2","3","0")
    if ($choice -eq "0") { return $null }
    return $arrays[$choice]
}

# ========================
#  LOOP PRINCIPAL
# ========================
while ($true) {
    Write-Header
    Write-Host "  Menu de Ações Principais:" -ForegroundColor White
    Write-Host "  [1] " -NoNewline -ForegroundColor Cyan; Write-Host "Visão Geral (Listar todas as mídias)" -ForegroundColor White
    Write-Host "  [2] " -NoNewline -ForegroundColor Yellow; Write-Host "Trocar URL de uma mídia existente" -ForegroundColor White
    Write-Host "  [3] " -NoNewline -ForegroundColor Green; Write-Host "Adicionar NOVA mídia ao site" -ForegroundColor White
    Write-Host "  [4] " -NoNewline -ForegroundColor Red; Write-Host "Remover um slot (mídia) do site" -ForegroundColor White
    Write-Host "  [5] " -NoNewline -ForegroundColor Magenta; Write-Host "Forçar Sincronização / Deploy" -ForegroundColor White
    Write-Host "  [6] " -NoNewline -ForegroundColor DarkRed; Write-Host "ZONA DE PERIGO (Wipe em Massa)" -ForegroundColor White
    Write-Host "  [7] " -NoNewline -ForegroundColor Blue; Write-Host "Configurações do Site (Taxa de Câmbio)" -ForegroundColor White
    Write-Host "  [0] " -NoNewline -ForegroundColor DarkGray; Write-Host "Sair do Gerenciador" -ForegroundColor White
    
    $option = Prompt-Choice "`n  O que deseja fazer?" @("1","2","3","4","5","6","7","0")
    
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
            Write-Host "  ► TROCAR URL DE MÍDIA ◄" -ForegroundColor Yellow
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Header
            Show-Items -ArrayName $cat.Name -Label $cat.Label
            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Pause-Screen; continue }
            
            $numText = Read-Host "`n  Qual o NÚMERO da mídia que deseja alterar? (0 para cancelar)"
            if (-not [int]::TryParse($numText, [ref]$null)) { Write-Warn "Número inválido!"; Start-Sleep 1; continue }
            $idx = [int]$numText - 1
            if ($numText -eq "0") { continue }
            if ($idx -lt 0 -or $idx -ge $items.Count) { Write-Err "Número inexistente."; Start-Sleep 1; continue }
            
            Write-Host "`n  URL atual: " -NoNewline -ForegroundColor DarkGray
            $currentUrl = $items[$idx].MediaUrl
            if ($currentUrl) { Write-Host $currentUrl -ForegroundColor Green }
            else { Write-Host "(vazio)" -ForegroundColor DarkGray }
            
            Write-Host "  (Dica: Deixe vazio e aperte ENTER para remover apenas a mídia, mantendo o card)" -ForegroundColor DarkGray
            $newUrl = Read-Host "  Cole a NOVA URL"
            
            if (Set-ItemUrl -ArrayName $cat.Name -ItemIndex $idx -NewUrl $newUrl) {
                Write-Success "Galeria atualizada localmente!"
                Deploy-Changes
            }
            Pause-Screen
        }
        "3" {
            Write-Header
            Write-Host "  ► ADICIONAR NOVA MÍDIA ◄" -ForegroundColor Green
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Host "`n  Qual o tipo do conteúdo que está adicionando?" -ForegroundColor White
            Write-Host "  [1] Imagem" -ForegroundColor Yellow
            Write-Host "  [2] Vídeo (TikTok, YouTube ou MP4)" -ForegroundColor Yellow
            $typeChoice = Prompt-Choice "Opção" @("1","2")
            $type = if ($typeChoice -eq "2") { "video" } else { "image" }
            
            Write-Host "`n  Cole o link direto da mídia. (Pode deixar vazio para adicionar um card em branco provisório)" -ForegroundColor DarkGray
            $url = Read-Host "  URL"
            
            Write-Host "`n  Deseja que esse item ocupe o espaço de 2 colunas no site? (ideal para vídeos horizontais)" -ForegroundColor DarkGray
            $doubleChoice = Prompt-Choice "(S/N)" @("s","S","n","N")
            $isDouble = $doubleChoice -match "^[sS]"
            
            if (Add-Item -ArrayName $cat.Name -Type $type -MediaUrl $url -Double $isDouble) {
                Write-Success "Mídia adicionada localmente!"
                Deploy-Changes
            }
            Pause-Screen
        }
        "4" {
            Write-Header
            Write-Host "  ► REMOVER SLOT DE MÍDIA ◄" -ForegroundColor Red
            $cat = Select-Category
            if ($null -eq $cat) { continue }
            
            Write-Header
            Show-Items -ArrayName $cat.Name -Label $cat.Label
            $items = Parse-PortfolioItems $cat.Name
            if ($items.Count -eq 0) { Pause-Screen; continue }
            
            $numText = Read-Host "`n  Qual o NÚMERO do slot que deseja DELETAR permanentemente? (0 para cancelar)"
            if (-not [int]::TryParse($numText, [ref]$null)) { Write-Warn "Número inválido!"; Start-Sleep 1; continue }
            $idx = [int]$numText - 1
            if ($numText -eq "0") { continue }
            if ($idx -lt 0 -or $idx -ge $items.Count) { Write-Err "Número inexistente."; Start-Sleep 1; continue }
            
            $confirm = Prompt-Choice "`n  TEM CERTEZA que deseja apagar o slot $($numText)? (S/N)" @("s","S","n","N")
            if ($confirm -match "^[sS]") {
                if (Remove-Item-FromArray -ArrayName $cat.Name -ItemIndex $idx) {
                    Write-Success "Slot removido localmente!"
                    Deploy-Changes
                }
            } else {
                Write-Warn "Ação cancelada."
            }
            Pause-Screen
        }
        "5" {
            Write-Header
            Deploy-Changes
            Pause-Screen
        }
        "6" {
            # ZONA DE PERIGO
            while ($true) {
                Write-Header
                Write-Host "  ► ZONA DE PERIGO (LIMPEZA EM MASSA) ◄" -ForegroundColor DarkRed -BackgroundColor Gray
                Write-Host "`n  Escolha o que deseja fazer:" -ForegroundColor White
                Write-Host "  [1] " -NoNewline -ForegroundColor Yellow; Write-Host "Apagar todas as URLs de IMAGENS (Artes/NSFW)" -ForegroundColor White
                Write-Host "  [2] " -NoNewline -ForegroundColor Yellow; Write-Host "Apagar todas as URLs de VÍDEOS" -ForegroundColor White
                Write-Host "  [3] " -NoNewline -ForegroundColor Red; Write-Host "Deletar COMPLETAMENTE todos os slots de IMAGENS" -ForegroundColor White
                Write-Host "  [4] " -NoNewline -ForegroundColor Red; Write-Host "Deletar COMPLETAMENTE todos os slots de VÍDEOS" -ForegroundColor White
                Write-Host "  [0] " -NoNewline -ForegroundColor DarkGray; Write-Host "Voltar com segurança" -ForegroundColor White
                
                $wipeOpt = Prompt-Choice "`n  Opção" @("1","2","3","4","0")
                if ($wipeOpt -eq "0") { break }
                
                # Validações de confirmação dupla
                Write-Host "`n  ╔════════════════════════════════════════════════════════╗" -ForegroundColor Red
                Write-Host "  ║ AVISO: Esta é uma operação destrutiva irreversível!    ║" -ForegroundColor Red
                Write-Host "  ╚════════════════════════════════════════════════════════╝" -ForegroundColor Red
                
                $targetType = if ($wipeOpt -in @("1","3")) { "image" } else { "video" }
                $actionType = if ($wipeOpt -in @("1","2")) { "Zerar URLs (limpar mídias mas manter cartões na grade)" } else { "Deletar a existência dos slots (a grade vai encolher)" }
                
                Write-Host "  Ação: " -NoNewline -ForegroundColor White; Write-Host $actionType -ForegroundColor Yellow
                Write-Host "  Alvos: " -NoNewline -ForegroundColor White; Write-Host "Todos os itens do tipo '$targetType'" -ForegroundColor Yellow
                
                $securityConfirm = Read-Host "`n  Digite 'CONFIRMAR' com letras maiúsculas para prosseguir, ou ENTER para cancelar"
                if ($securityConfirm -cne "CONFIRMAR") {
                    Write-Warn "Limpeza abortada por segurança."
                    Start-Sleep 2
                    continue
                }
                
                # Executa
                $count = 0
                if ($wipeOpt -in @("1","2")) {
                    $count = Wipe-MediaUrls -TargetType $targetType
                } else {
                    $count = Wipe-EntireSlots -TargetType $targetType
                }
                
                Write-Success "Operação concluída! $count itens foram afetados."
                Deploy-Changes
                Pause-Screen
                break
            }
        }
        "7" {
            Write-Header
            Write-Host "  ► CONFIGURAÇÕES DO SITE ◄" -ForegroundColor Blue
            $content = Get-DataContent
            $pattern = "export const exchangeRate = ([\d\.]+);"
            $match = [regex]::Match($content, $pattern)
            
            if ($match.Success) {
                $currentRate = $match.Groups[1].Value
                Write-Host "`n  Taxa de Câmbio Atual (USD para BRL): " -NoNewline -ForegroundColor White
                Write-Host "R$ $currentRate" -ForegroundColor Green
                
                $newRate = Read-Host "`n  Digite a NOVA taxa de câmbio (ex: 5.80) ou deixe vazio para cancelar"
                if (-not [string]::IsNullOrWhiteSpace($newRate)) {
                    if ($newRate -match "^[\d\.]+$") {
                        $newContent = $content -replace "export const exchangeRate = [\d\.]+;", "export const exchangeRate = $newRate;"
                        Set-Content $dataFile -Value $newContent -Encoding UTF8 -NoNewline
                        Write-Success "Taxa de câmbio atualizada localmente!"
                        Deploy-Changes
                    } else {
                        Write-Err "Valor inválido. Use apenas números e ponto (ex: 5.50)."
                    }
                }
            } else {
                Write-Err "Não foi possível encontrar a variável exchangeRate em data.tsx."
            }
            Pause-Screen
        }
        "0" {
            Write-Host "`n  Saindo do gerenciador... Até a próxima, Maka! `n" -ForegroundColor Cyan
            break
        }
    }
}
