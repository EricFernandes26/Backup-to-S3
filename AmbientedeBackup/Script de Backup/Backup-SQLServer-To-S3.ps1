# Definir parâmetros
$bancoDados = "AdventureWorks2022"                         # Nome do banco de dados do SQL Server
$localBackupDir = "C:\AmbientedeBackup\BackupSQLServer\"   # Diretório local onde o backup será salvo (com barra no final)
$s3Bucket = "sql-server-bkp-ep"                            # Nome do bucket do S3 (sem "s3://")
$s3KeyPrefix = "backup/"                                   # Prefixo no bucket (diretório virtual)
$nomeBackup = "$bancoDados-$(Get-Date -Format 'yyyyMMddHHmmss').bak"  # Nome do arquivo de backup com timestamp

# Caminho completo do backup
$caminhoBackup = "$localBackupDir$nomeBackup"

# Certificar que o diretório de backup existe
if (!(Test-Path -Path $localBackupDir)) {
    New-Item -Path $localBackupDir -ItemType Directory
}

# Fazer backup completo do banco de dados SQL Server
Write-Host "Iniciando o backup do banco de dados $bancoDados..."
Invoke-Sqlcmd -Query "BACKUP DATABASE [$bancoDados] TO DISK = '$caminhoBackup' WITH FORMAT, INIT, NAME = 'Full Backup de $bancoDados'" -ServerInstance "localhost"

# Verificar se o backup foi criado com sucesso
if (Test-Path -Path $caminhoBackup) {
    Write-Host "Backup do banco de dados $bancoDados concluído com sucesso em $caminhoBackup"
    
    # Carregar o backup para o S3
    Write-Host "Carregando o backup para o Amazon S3..."
    $uploadCmd = "aws s3 cp '$caminhoBackup' s3://$s3Bucket/$s3KeyPrefix$nomeBackup"
    
    # Executar o comando de upload
    Invoke-Expression $uploadCmd
    
    # Verificar se o upload foi bem-sucedido
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Backup carregado com sucesso para s3://$s3Bucket/$s3KeyPrefix$nomeBackup"
    } else {
        Write-Host "Erro ao carregar o backup para o Amazon S3. Código de erro: $LASTEXITCODE"
    }
    
} else {
    Write-Host "Erro: Não foi possível criar o backup do banco de dados $bancoDados."
}

# Limpeza de backups antigos (opcional) - manter apenas os 5 mais recentes no diretório local
$arquivosBackup = Get-ChildItem -Path $localBackupDir -Filter "*.bak" | Sort-Object LastWriteTime -Descending
if ($arquivosBackup.Count -gt 5) {
    Write-Host "Limpando backups antigos..."
    $arquivosBackup | Select-Object -Skip 5 | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
        Write-Host "Removido backup antigo: $($_.FullName)"
    }
}
