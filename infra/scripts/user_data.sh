#!/bin/bash -xe
# This script runs as root on the EC2 instance at first boot.

# Redirect all output to a log file for easier debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Variables
readonly MOUNT_POINT="/minecraft"
readonly EBS_DEVICE_NAME="/dev/sdf" 
readonly MINECRAFT_VERSION="1.21.11"

# Update packages and install dependencies
echo "Updating packages and installing dependencies..."
yum update -y
yum install -y java-21-amazon-corretto-headless screen

# --- EBS Volume Setup ---
echo "Setting up EBS volume..."

# Wait for the device to be attached
while [ ! -b ${EBS_DEVICE_NAME} ]; do
  echo "Waiting for device ${EBS_DEVICE_NAME}..."
  sleep 5
done

# Check if the volume is already formatted
if ! file -s ${EBS_DEVICE_NAME} | grep -q "XFS"; then
    echo "Formatting EBS volume with XFS..."
    mkfs -t xfs ${EBS_DEVICE_NAME}
fi

# Create mount point directory
mkdir -p ${MOUNT_POINT}

# Get UUID of the volume for fstab
EBS_UUID=$(lsblk -f | grep ${EBS_DEVICE_NAME##*/} | awk '{print $3}')

# Add to /etc/fstab for automounting on boot
if ! grep -q "UUID=${EBS_UUID}" /etc/fstab; then
    echo "Adding EBS volume to /etc/fstab..."
    echo "UUID=${EBS_UUID} ${MOUNT_POINT} xfs defaults,nofail 0 2" >> /etc/fstab
fi

# Mount the volume and set ownership
mount -a
chown -R ec2-user:ec2-user ${MOUNT_POINT}
echo "EBS volume mounted on ${MOUNT_POINT}"

# --- Minecraft Server Setup ---
cd ${MOUNT_POINT}
echo "Setting up Minecraft server in ${MOUNT_POINT}..."

# Download Minecraft server jar if it doesn't exist
if [ ! -f "server.jar" ]; then
    echo "Downloading Minecraft server version ${MINECRAFT_VERSION}..."
    # Updated URL for 1.21.11
    wget "https://piston-data.mojang.com/v1/objects/64bb6d763bed0a9f1d632ec347938594144943ed/server.jar" -O server.jar
fi

# Agree to EULA
echo "eula=true" > eula.txt

# Start Minecraft server in a detached screen session as ec2-user
echo "Starting Minecraft server..."
# Use Java 21 for Minecraft 1.21+
sudo -u ec2-user bash -c "cd ${MOUNT_POINT} && screen -S minecraft -d -m java -Xmx2G -Xms1G -jar server.jar nogui"

echo "User data script finished."
