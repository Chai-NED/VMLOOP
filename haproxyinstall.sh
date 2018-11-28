#!/bin/sh


#
# Pre-req
# 1. The Ubuntu VM must exist for this HAProxy to install
# 2. Execute this on the Ubuntu HAProxy VM
# 
#Debug 
exec > /tmp/logcse 2>&1
set -x

apt-get update

#Install stable release of HAProxy1.8 and it should run automatically by default
apt-get install -y haproxy=1.8.\*

 #!/bin/sh

#
# The Azure Custom Script Extension will execute this script after a VM has been created by a template. It requires
# three arguments to be passed in from your template.
# 
# 1. VM admin name
# 2. Existing storage account name
# 3. Storage account key from #3
#



vmAdmin=$1
storageAccountName=$2
storageAccountKey=$3

linuxMountPointLog="/mnt/azure/log" 
tmpBlobFuseConfig="/home/$vmAdmin/blobfuse_tmp.cfg"
blobFuseConfigPath="/etc/blobfuse_azureblob.cfg"
blobFuseConfigContentPrefix="accountName  $storageAccountName\naccountKey $storageAccountKey"
blobFuseTempPath="/mnt/blobfusetmp"
fsTabPath="/etc/fstab"
mountScriptPath="/home/$vmAdmin/mount.sh"


# # sudo wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb 
# sudo dpkg -i packages-microsoft-prod.deb 
# sudo apt-get update -y  
# sudo apt-get upgrade -y 
 
 curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > ./microsoft-prod.list
 sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/
 curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
 sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/
 sudo apt-get update -y
   
# Install blobfuse. Default on Ubuntu is /usr/bin
sudo apt-get install -y blobfuse fuse 


sudo mkdir -p $blobFuseTempPath  
sudo chown  $vmAdmin  $blobFuseTempPath


# Build blobfuse config file
blobFuseConfigContent="$blobFuseConfigContentPrefix\ncontainerName log"
echo $blobFuseConfigContent > $tmpBlobFuseConfig
sudo cp $tmpBlobFuseConfig $blobFuseConfigPath   
sudo chmod 700  $blobFuseConfigPath

# Create a mountpoint and mount blob on it
sudo mkdir -p  $linuxMountPointLog
sudo /usr/bin/blobfuse  $linuxMountPointLog  --tmp-path=$blobFuseTempPath  --config-file=$blobFuseConfigPath  -o allow_other -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --file-cache-timeout-in-seconds=120 --log-level=LOG_DEBUG 

#              
# Persist blobfuse mountpount after a reboot. For that, you have to crate a mount.sh in home dir and use it in fstab
#	
# Generate mount.sh on the fly. 
echo "/usr/bin/blobfuse $linuxMountPointLog  --tmp-path=$blobFuseTempPath  --config-file=$blobFuseConfigPath  -o allow_other -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --file-cache-timeout-in-seconds=120 --log-level=LOG_DEBUG" > $mountScriptPath
chmod +x $mountScriptPath
      
# Add a line to fstab  
sudo cp $fsTabPath $fsTabPath.orig
sudo bash -c "echo $mountScriptPath  $linuxMountPointLog fuse _netdev >> $fsTabPath"
	
