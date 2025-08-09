
mkdir -p /usr/local/keycloak
cd /usr/local/keycloak
wget -O keycloak-${KEYCLOAK_VER}.zip https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VER}/keycloak-${KEYCLOAK_VER}.zip
unzip keycloak-${KEYCLOAK_VER}.zip
ln -s keycloak-${KEYCLOAK_VER} keycloak-server
keytool -genkeypair -keystore /usr/local/keycloak/keystore.jks -deststoretype pkcs12 -storepass password -keypass password -alias jetty -keyalg RSA -keysize 4096 -validity 5000 -dname "CN=keycloak.${LAB_DOMAIN}, OU=openshift4-lab, O=openshift4-lab, L=City, ST=State, C=US" -ext "SAN=DNS:keycloak.${LAB_DOMAIN},IP:10.11.12.20" -ext "BC=ca:true"
mv /usr/local/keycloak/keycloak-server/conf/keycloak.conf /usr/local/keycloak/keycloak-server/conf/keycloak.conf.orig
mkdir -p /usr/local/keycloak/home
groupadd keycloak
useradd -g keycloak -d /usr/local/keycloak/home keycloak

cat << EOF > /usr/local/keycloak/keycloak-server/conf/keycloak.conf
hostname=keycloak.${LAB_DOMAIN}
http-enabled=false
https-key-store-file=/usr/local/keycloak/keystore.jks
https-port=7443
bootstrap-admin-username=keycloak
bootstrap-admin-password=keycloak
EOF
