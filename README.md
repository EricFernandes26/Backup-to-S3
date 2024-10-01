# Backup-to-S3
Scripts PowerShell para Backup e Restore do SQL Server com Amazon S3



# Visão Geral
Este repositório contém dois scripts PowerShell que facilitam o backup e o download de arquivos de backup (.bak) de um banco de dados SQL Server usando o Amazon S3. Estes scripts são úteis para criar uma estratégia de backup automatizada e confiável, que armazena os dados de forma segura na nuvem.

# Scripts Incluídos:
script bkp.ps1:  Faz backup completo de um banco de dados do SQL Server e envia o arquivo para o Amazon S3.
script restore.ps1: Baixa o backup mais recente do Amazon S3 para um diretório local.
