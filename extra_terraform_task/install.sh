sudo yum install epel-release -y
sudo yum install nginx -y
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
</html>" >> /usr/share/nginx/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx