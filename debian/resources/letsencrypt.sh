#!/bin/sh

#request the domain and email
read -p 'Domain Name: ' domain_name
read -p 'Email Address: ' email
#domain_name=subdomain.domain.com
#email=username@domain.com

#remove previous install
rm -R /opt/letsencrypt
rm -R /etc/letsencrypt

#enable fusionpbx nginx config
cp nginx/fusionpbx /etc/nginx/sites-available/fusionpbx
#ln -s /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/fusionpbx

/usr/sbin/nginx -t && /usr/sbin/nginx -s reload

git clone https://github.com/letsencrypt/letsencrypt /opt/letsencrypt
chmod 755 /opt/letsencrypt/certbot-auto
/opt/letsencrypt/./certbot-auto
mkdir -p /etc/letsencrypt/configs
mkdir -p /var/www/letsencrypt/

#cd $pwd
#cd "$(dirname "$0")"

cp letsencrypt/domain_name.conf /etc/letsencrypt/configs/$domain_name.conf

sed "s#{domain_name}#$domain_name#g" -i /etc/letsencrypt/configs/$domain_name.conf
sed "s#{email_address}#$email#g" -i /etc/letsencrypt/configs/$domain_name.conf

#letsencrypt
#sed "s@#letsencrypt@location /.well-known/acme-challenge { root /var/www/letsencrypt; }@g" -i /etc/nginx/sites-available/fusionpbx

cd /opt/letsencrypt && ./letsencrypt-auto --config /etc/letsencrypt/configs/$domain_name.conf certonly

sed "s@ssl_certificate         /etc/ssl/certs/nginx.crt;@ssl_certificate /etc/letsencrypt/live/$domain_name/fullchain.pem;@g" -i /etc/nginx/sites-available/fusionpbx
sed "s@ssl_certificate_key     /etc/ssl/private/nginx.key;@ssl_certificate_key /etc/letsencrypt/live/$domain_name/privkey.pem;@g" -i /etc/nginx/sites-available/fusionpbx

/usr/sbin/nginx -t && /usr/sbin/nginx -s reload