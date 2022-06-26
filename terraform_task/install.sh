#!/bin/bash
sudo apt update
sudo apt install apache2 -y
sudo rm -r /var/www/html/index.html
system=`hostnamectl`
sudo echo "
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Document</title>
</head>
<body>
    <h2>Hello World</h2>
    <h2>My Operating System details:</h2>
    <pre>$system</pre>
</body>
</html>" >> /var/www/html/index.html
sudo systemctl start apache2
sudo apt-get update
sudo apt-get install \
     ca-certificates \
     curl \
     gnupg \
     lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo apt-get install docker-ce=5:20.10.16~3-0~ubuntu-jammy docker-ce-cli=5:20.10.16~3-0~ubuntu-jammy containerd.io docker-compose-plugin -y
docker --version