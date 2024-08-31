apt autoremove docker-compose -y
curl -SL https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
mkdir -p ~/envoy/examples/
cp -r ~/assets/step4/front-proxy/ ~/envoy/examples/
cp -r ~/assets/step4/shared/ ~/envoy/examples/