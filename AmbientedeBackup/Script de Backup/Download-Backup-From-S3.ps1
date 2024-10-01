# Definir parâmetros
$s3Bucket = "sql-server-bkp-ep"                         # Nome do bucket do S3
$s3KeyPrefix = "backup/"                                 # Prefixo no bucket (diretório virtual)
$localRestoreDir = "C:\AmbientedeBackup\RestoreSQLServer\"  # Diretório local para salvar os backups

# Certificar que o diretório de restauração existe
if (!(Test-Path -Path $localRestoreDir)) {
    New-Item -Path $localRestoreDir -ItemType Directory
}

# Listar os arquivos do S3 e identificar o mais recente
Write-Host "Listando os arquivos no bucket S3 para encontrar o mais recente..."
$listObjectsCmd = "aws s3api list-objects --bucket $s3Bucket --prefix $s3KeyPrefix --output json"
$objectsListJson = Invoke-Expression $listObjectsCmd
$objectsList = $objectsListJson | ConvertFrom-Json

# Filtrar apenas os arquivos que possuem a extensão .bak
$bakFiles = $objectsList.Contents | Where-Object { $_.Key -like "*.bak" }

# Verificar se existem arquivos de backup
if ($bakFiles -eq $null -or $bakFiles.Count -eq 0) {
    Write-Host "Nenhum arquivo de backup encontrado no bucket S3."
    exit
}

# Obter o arquivo de backup mais recente com base na data e hora no nome do arquivo
$latestObject = $bakFiles | Sort-Object {
    # Extrair a parte do timestamp do nome do arquivo e convertê-la para um DateTime
    if ($_ -ne $null -and $_.Key -match 'AdventureWorks2022-(\d{8}\d{6})\.bak') {
        [datetime]::ParseExact($matches[1], 'yyyyMMddHHmmss', $null)
    } else {
        [datetime]::MinValue
    }
} -Descending | Select-Object -First 1

if ($latestObject -eq $null) {
    Write-Host "Erro ao identificar o arquivo de backup mais recente."
    exit
}

$s3Key = $latestObject.Key

# Definir o caminho local do arquivo para restaurar
$restoreFile = $s3Key.Split('/')[-1]  # Pegar apenas o nome do arquivo do caminho completo
$caminhoBackupLocal = "$localRestoreDir$restoreFile"

# Baixar o backup do S3
Write-Host "Baixando o backup mais recente ($s3Key) do Amazon S3 para $caminhoBackupLocal..."
$downloadCmd = "aws s3 cp s3://$s3Bucket/$s3Key $caminhoBackupLocal"
Invoke-Expression $downloadCmd

# Verificar se o download foi bem-sucedido
if (-not (Test-Path -Path $caminhoBackupLocal)) {
    Write-Host "Erro ao baixar o backup do Amazon S3."
    exit
} else {
    Write-Host "Backup baixado com sucesso para $caminhoBackupLocal."
}
