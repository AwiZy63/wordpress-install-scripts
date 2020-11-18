#!/bin/sh
# grp.sh

#    printf '\e[32m\e[m' "$1 $2 $3 $4"; 
ok() {
    printf "$1 $2 $3 $4\n";
} 
 
EXPECTED_ARGS=4
E_BADARGS=65
MYSQL=`which mysql`
MKDIR=`which mkdir`

RESULT=`mysql -u$2 -p$3 -e "SHOW DATABASES" | grep $1`

Q1="CREATE DATABASE IF NOT EXISTS $1;"
Q2="GRANT ALL ON *.* TO '$2'@'localhost' IDENTIFIED BY '$3';"
Q3="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}"

# apache directory link
apache="/etc/apache2/"
ports="/etc/apache2/ports.conf"
vhosts="/etc/apache2/sites-available/"
# default apache virtualHost name
fileNumberDefault=0
defaultFileName="$fileNumberDefault-wordpress.conf"
vHostDefaultPort=80
vHostNewPort=1799

if [ $# -ne $EXPECTED_ARGS ]
then
  echo Utilisation: "$0 [db_name] [db_user] [db_pass] [/chemin_absolue_du_dossier/]"
  exit $E_BADARGS
fi
$MYSQL -uroot -p -e "$SQL"
if "`mysql -u$2 -p$3 -e 'show databases;'`"
then
# Creation du vHost

# Configuration du port
while grep -q "$vHostDefaultPort" $ports
do
   
    vHostDefaultPort=$((vHostNewPort+=1))

    # Si le port n'existe pas, le créer.
    if ! grep -q "$vHostDefaultPort" $ports
    then
        
        # Ecriture du Port dans le ports.conf.
        sudo sed -i "4 a Listen $vHostDefaultPort" $ports
        break
    fi
    
done

# Texte du virtualHost
vHostText="
<VirtualHost *:$vHostDefaultPort>\n\n

    ServerAdmin webmaster@localhost\n
    DocumentRoot $4wordpress\n\n

    <Directory $4wordpress/>\n
        AllowOverride All\n
    </Directory>\n\n

    ErrorLog ${APACHE_LOG_DIR}/error.log\n
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\n

</VirtualHost>
"

# Creation du fichier vHost
while [ -e $defaultFileName ]
do
   
    defaultFileName="$((fileNumberDefault+=1))-wordpress.conf"

    # Si le fichier n'existe pas, le créer.
    if [ ! -e $defaultFileName ]
    then
        # Ecriture du fichier vHost.
        sudo echo -e $vHostText >  $defaultFileName
        break
    fi

done
    sudo echo -e $vHostText > $defaultFileName

# Creation de la base de données et de son utilisateur 



sudo $MKDIR -p $4
cd $4

# Telechargement et installation de Wordpress
sudo curl -O https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
sudo rm latest.tar.gz

cd ./wordpress/

# Creation de la configuration Wordpress
sudo mv wp-config-sample.php wp-config.php

# Insertion des informations de base de données dans la config WordPress
sudo sed -i -e "s/database_name_here/$1/g" ./wp-config.php
sudo sed -i -e "s/username_here/$2/g" ./wp-config.php
sudo sed -i -e "s/password_here/$3/g" ./wp-config.php

# Attribution des droits et permissions
sudo chown -R www-data:www-data $4wordpress
sudo find $4wordpress/ -type d -exec chmod 750 {} \;
sudo find $4wordpress/ -type f -exec chmod 640 {} \;


#sudo sed -i -e "" $4/wordpress/wp-config.php
ok "La base de donnée $1 et l'utilisateur $2 ont bien été créé, avec les mot de passe : $3 \n\n Wordpress a bien été installé dans le repertoire $4 \n\n Accedez à votre interface à partir de cette adresse : http://localhost:$vHostNewPort/"
else
    echo "Vos informations MySQL sont incorrectes veuillez réessayer."
fi