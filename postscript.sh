#!/bin/sh

#Debug 
exec > /tmp/logcse 2>&1
set -x


vmAdmin=$1
storageAccountName=$2
storageAccountKey=$3

logContainer="log"
share1Container="share1"
share2Container="share2"

linuxMountPoint="/mnt/azure" 

blobFuseConfigPath="/etc/blobfuse_azureblob.cfg"


blobFuseConfigContentPrefix="accountName  $storageAccountName\naccountKey $storageAccountKey"
blobFuseTempPath="/mnt/blobfusetmp"
fsTabPath="/etc/fstab"
mountScriptPath="/home/$vmAdmin/mount.sh"
tmpBlobFuseConfig="/home/$vmAdmin/blobfuse_tmp.cfg"



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

#sudo apt-get update -y
#sudo dpkg --configure -a
#sudo apt-get upgrade -y 
#sudo apt-get --yes  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

sudo mkdir -p $blobFuseTempPath  
sudo chown  $vmAdmin  $blobFuseTempPath


# Build three blobfuse config files

for index in $logContainer $share1Container $share2Container
do
blobFuseConfigContent="$blobFuseConfigContentPrefix\ncontainerName $index"
echo $blobFuseConfigContent > $tmpBlobFuseConfig.$index
sudo cp $tmpBlobFuseConfig.$index $blobFuseConfigPath.$index   
sudo chmod 700  $blobFuseConfigPath.$index

# Create  mountpoint and mount blob on it
sudo mkdir -p  "$linuxMountPoint/$index"
sudo /usr/bin/blobfuse  $linuxMountPoint/$index  --tmp-path=$blobFuseTempPath  --config-file=$blobFuseConfigPath.$index  -o allow_other -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --file-cache-timeout-in-seconds=120 --log-level=LOG_DEBUG 

#              
# Persist blobfuse mountpount after a reboot. For that, you have to crate a mount.sh in home dir and use it in fstab
#	
# Generate three mount.sh files on the fly. 
echo "/usr/bin/blobfuse $linuxMountPoint/$index  --tmp-path=$blobFuseTempPath  --config-file=$blobFuseConfigPath.$index  -o allow_other -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --file-cache-timeout-in-seconds=120 --log-level=LOG_DEBUG" > $mountScriptPath.$index
chmod +x $mountScriptPath.$index
      
# Add each line  to fstab  
sudo cp $fsTabPath $fsTabPath.orig
sudo bash -c "echo $mountScriptPath.$index  $linuxMountPoint/$index fuse _netdev >> $fsTabPath"

done
