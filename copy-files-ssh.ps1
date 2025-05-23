# Parameters
$linuxServer = "your_server_ip"  # Replace with your Linux server IP or hostname
$username = "your_username"      # Replace with your Linux username
$password = "your_password"      # Replace with your password (or use key-based auth)
$localPath = "C:\Path\To\Files\*" # Replace with the path to your local files
$remotePath = "/tmp/DIR"

# Import the SSH module (Install-Module -Name Posh-SSH if not already installed)
Import-Module Posh-SSH

# Create SSH credential
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

try {
    # Establish SSH session
    $session = New-SSHSession -ComputerName $linuxServer -Credential $credential -AcceptKey

    # Create /tmp/DIR folder and set 555 permissions
    $commands = @"
mkdir -p $remotePath
chmod 555 $remotePath
"@
    Invoke-SSHCommand -SSHSession $session -Command $commands

    # Create SFTP session for file transfer
    $sftpSession = New-SFTPSession -ComputerName $linuxServer -Credential $credential -AcceptKey

    # Copy files from local to remote server
    Get-ChildItem -Path $localPath | ForEach-Object {
        Set-SFTPItem -SFTPSession $sftpSession -Path $_.FullName -Destination $remotePath -Force
    }

    Write-Host "Folder created, permissions set, and files copied successfully."
}
catch {
    Write-Host "Error: $_"
}
finally {
    # Clean up sessions
    if ($sftpSession) { Remove-SFTPSession -SFTPSession $sftpSession }
    if ($session) { Remove-SSHSession -SSHSession $session }
}
