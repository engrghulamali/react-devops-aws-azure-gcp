#!/bin/bash
set -e

# Update and install Docker
apt-get update -y
apt-get install -y docker.io

# Enable & start Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Apply new group membership
newgrp docker <<EOF
  echo "${docker_password}" | docker login -u "${docker_username}" --password-stdin
  docker run -d -p 80:80 ${docker_image}
EOF

