# PowerShell скрипт для развертывания через SSH
# Запустите: powershell -ExecutionPolicy Bypass -File deploy/ssh-deploy.ps1

$server = "root@149.33.4.37"
$password = "PUR42mjSai"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Развертывание проекта через SSH" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Функция для выполнения SSH команд
function Invoke-SSHCommand {
    param(
        [string]$Command
    )
    
    $tempScript = [System.IO.Path]::GetTempFileName()
    $Command | Out-File -FilePath $tempScript -Encoding ASCII
    
    # Используем plink если доступен, иначе ssh
    if (Get-Command plink -ErrorAction SilentlyContinue) {
        Write-Host "Использование plink..." -ForegroundColor Yellow
        $result = echo y | plink -ssh -pw $password $server -m $tempScript 2>&1
    } else {
        Write-Host "Использование ssh (требует ручного ввода пароля)..." -ForegroundColor Yellow
        Write-Host "Пароль: $password" -ForegroundColor Yellow
        $result = ssh -o StrictHostKeyChecking=no $server "bash -s" < $tempScript 2>&1
    }
    
    Remove-Item $tempScript -ErrorAction SilentlyContinue
    return $result
}

Write-Host "1. Клонирование репозитория..." -ForegroundColor Green
$script = @"
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
echo 'Repository cloned'
"@

Invoke-SSHCommand -Command $script

Write-Host ""
Write-Host "2. Исправление Apache..." -ForegroundColor Green
$script = @"
cd /tmp/kt3/deploy
chmod +x fix-apache.sh
bash fix-apache.sh
"@

Invoke-SSHCommand -Command $script

Write-Host ""
Write-Host "3. Развертывание проекта..." -ForegroundColor Green
$script = @"
cd /tmp/kt3/deploy
chmod +x deploy.sh
echo 'y' | bash deploy.sh
"@

Invoke-SSHCommand -Command $script

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Готово!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Проверьте сайт: http://149.33.4.37" -ForegroundColor Yellow
Write-Host ""

