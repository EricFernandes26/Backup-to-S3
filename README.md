
# README - Scripts PowerShell para Backup e Restore do SQL Server com Amazon S3

## Visão Geral

Este repositório contém dois scripts PowerShell que facilitam o backup e o download de arquivos de backup (`.bak`) de um banco de dados SQL Server usando o **Amazon S3**. Estes scripts são úteis para criar uma estratégia de backup automatizada e confiável, que armazena os dados de forma segura na nuvem.

Vale lembrar que toda a estrutura de pastas foi criada no **C:** do windowns tendo AmbientedeBackup como pasta pai e as pastas RestoreSQLServer, BackupSQLServer e Script de Backup como filhos.

### Scripts Incluídos:

1. **Backup-SQLServer-To-S3.ps1**: Faz backup completo de um banco de dados do SQL Server e envia o arquivo para o **Amazon S3**.
2. **Download-Backup-From-S3.ps1**: Baixa o backup mais recente do **Amazon S3** para um diretório local.

---

## Script 1: `Backup-SQLServer-To-S3.ps1`

### **Descrição**
Este script realiza o **backup completo** do banco de dados especificado no **SQL Server** e faz o upload desse backup para um bucket no **Amazon S3**. Ele é ideal para agendar backups automáticos e garantir que os dados sejam salvos na nuvem de maneira segura.

### **Passos do Script**
1. **Definir Parâmetros**:
   - Nome do banco de dados, diretório local para armazenar o backup temporariamente, nome do bucket S3 e prefixo no S3 para salvar o arquivo.
2. **Backup do Banco de Dados SQL Server**:
   - Utiliza o comando `BACKUP DATABASE` via `Invoke-Sqlcmd` para salvar um arquivo `.bak` no diretório especificado.
3. **Upload para o Amazon S3**:
   - Com o uso da **AWS CLI** (`aws s3 cp`), o script envia o backup para o **bucket S3**.
4. **Limpeza de Backups Locais**:
   - Mantém apenas os **5 backups mais recentes** no diretório local, removendo os backups antigos para otimizar o uso do armazenamento.

### **Pré-requisitos**
- **AWS CLI** configurada (`aws configure`) para acesso ao S3.
- Permissões de **escrita e leitura** no bucket do S3 para o usuário IAM configurado.
- **Módulo PowerShell SQL Server** para uso do `Invoke-Sqlcmd`.

### **Como Usar**
- Edite o script para ajustar os valores dos parâmetros:
  ```powershell
  $bancoDados = "AdventureWorks2022"
  $localBackupDir = "C:\AmbientedeBackup\BackupSQLServer\"
  $s3Bucket = "sql-server-bkp-ep"
  $s3KeyPrefix = "backup/"
  ```
- Execute manualmente no **PowerShell** ou crie uma tarefa agendada usando o **Task Scheduler** do Windows para rodar diariamente.

---

## Script 2: `Download-Backup-From-S3.ps1`

### **Descrição**
Este script faz o **download** do arquivo de backup (`.bak`) mais recente do **Amazon S3** para um diretório local. O script filtra os arquivos `.bak` e identifica qual deles tem o timestamp mais recente no nome, garantindo que o backup mais recente seja baixado.

### **Passos do Script**
1. **Definir Parâmetros**:
   - Nome do bucket S3, prefixo do bucket, e diretório local onde os backups serão baixados.
2. **Listar Arquivos do S3**:
   - Utiliza `aws s3api list-objects` para listar todos os arquivos no bucket S3 com o prefixo especificado.
3. **Filtrar e Identificar o Backup Mais Recente**:
   - Filtra os arquivos que possuem a extensão `.bak` e utiliza a **data/hora no nome do arquivo** para identificar o backup mais recente.
4. **Download do Arquivo**:
   - Com o comando **`aws s3 cp`**, baixa o backup mais recente para o diretório local especificado.
5. **Verificação**:
   - Certifica-se de que o arquivo foi baixado corretamente e exibe mensagens adequadas de confirmação ou erro.

### **Pré-requisitos**
- **AWS CLI** configurada (`aws configure`) para acesso ao S3.
- Permissões de **leitura** no bucket do S3.
- Diretório local deve existir ou o script deve ser capaz de criá-lo.

### **Como Usar**
- Edite o script para ajustar os valores dos parâmetros:
  ```powershell
  $s3Bucket = "sql-server-bkp-ep"
  $s3KeyPrefix = "backup/"
  $localRestoreDir = "C:\AmbientedeBackup\RestoreSQLServer\"
  ```
- Execute manualmente no **PowerShell** para baixar o backup mais recente.

---

## Exemplos de Execução

### **Execução Manual**

- **Backup**:
  ```powershell
  .\Backup-SQLServer-To-S3.ps1
  ```
  Esse comando irá iniciar o backup do banco de dados especificado e enviar o arquivo para o bucket S3 configurado.

- **Download do Backup Mais Recente**:
  ```powershell
  .\Download-Backup-From-S3.ps1
  ```
  Esse comando irá buscar o arquivo `.bak` mais recente no bucket do S3 e baixá-lo para o diretório local especificado.

### **Automatização com Task Scheduler**

1. **Backup Automático**: Use o **Task Scheduler** para executar o script `Backup-SQLServer-To-S3.ps1` diariamente às **23h**, garantindo uma rotina de backup segura.
2. **Restore Planejado**: Se necessário, também é possível agendar o download do backup ou mantê-lo manual, conforme a demanda.

---

## Considerações de Segurança

- **Permissões de Acesso ao S3**: Certifique-se de que as políticas de IAM estejam bem configuradas, permitindo apenas as permissões necessárias para acesso ao bucket.
- **Segurança dos Backups**: Use criptografia no bucket S3 (SSE-S3 ou SSE-KMS) para garantir que os backups estejam seguros em repouso.
- **Privilégios no SQL Server**: Execute o script com uma conta que tenha permissões apropriadas para executar backups e restores no SQL Server.

---

## Conclusão

Esses scripts proporcionam uma solução simples e automatizada para o **backup** e **restauração** de bancos de dados SQL Server utilizando a infraestrutura segura e escalável do **Amazon S3**. Ao configurar esses scripts de maneira adequada, você pode garantir a segurança e disponibilidade dos dados, com processos automatizados que podem ser facilmente gerenciados e monitorados.
