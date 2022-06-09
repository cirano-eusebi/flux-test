$wsl_ip = (wsl hostname -I).split()[0]
sudo netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectaddress=$wsl_ip connectport=30080
sudo netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectaddress=$wsl_ip connectport=30443
netsh interface portproxy show all
