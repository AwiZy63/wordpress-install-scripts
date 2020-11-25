#!/bin/sh

clear
echo
echo "==============================================="
echo "== Bienvenue sur l'installation de Wordpress =="
echo "==============================================="
echo
echo "Script fait par Bastien (avec la fine aide de Matthieu)"
echo

confirm() {
    read -r -p "${1} [y/N] " response

    case "$response" in
    [yY][eE][sS] | [yY] | [oO][uU][iI] | [oO])
        true
        ;;
    *)
        false
        ;;
    esac
}

if confirm "Voulez vous installer les dépendances ?"; then
    clear
    echo
    echo "== Installation des dépendances en cours =="
    echo
    sudo apt update && sudo apt install apache2 mariadb-server php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
    sudo service apache2 start
    sudo service mysql start
    sudo service apache2 reload
    clear
else
    clear
fi

EXPECTED_ARGS=0
E_BADARGS=1
MYSQL=$(which mysql)

if [ $# -ne $EXPECTED_ARGS ]; then
    echo Utilisation: "$0 (sans arguments)"
    exit $E_BADARGS
fi

sql_informations() {
    while true; do
        echo
        echo "== Installation des dépendances terminée =="
        echo

        read -r -p "${1} un nom de base de données [default: wp_db] : " responseDBName

        case "$responseDBName" in
        *)
            if [ ! $responseDBName = 0 ]; then
                sqlDB=$responseDBName
            else
                sqlDB=wp_db
            fi
            ;;
        esac

        echo

        read -r -p "${1} un nom d'utilisateur [default: wp_user] : " responseDBUser

        case "$responseDBUser" in
        *)
            if [ ! $responseDBUser = 0 ]; then
                sqlUser=$responseDBUser
            else
                sqlUser=wp_user
            fi
            ;;
        esac

        echo

        read -r -p "${1} un mot de passe [default: wp_password] : " responseDBPass

        case "$responseDBPass" in
        *)
            if [ ! $responseDBPass = 0 ]; then
                sqlPass=$responseDBPass
            else
                sqlPass=wp_password
            fi
            ;;
        esac

        echo
        read -r -p "êtes vous sûr ? [y/N] : " responseDBConfirm

        case "$responseDBConfirm" in
        [yY][eE][sS] | [yY] | [oO][uU][iI] | [oO])
            true
            break
            ;;
        *)
            false
            clear
            ;;
        esac
    done
}

if sql_informations "Choisissez"; then
    Q1="CREATE DATABASE IF NOT EXISTS $sqlDB;"
    Q2="GRANT ALL ON *.* TO '$sqlUser'@'localhost' IDENTIFIED BY '$sqlPass';"
    Q3="FLUSH PRIVILEGES;"
    SQL="${Q1}${Q2}${Q3}"
    sudo $MYSQL -u root -e "$SQL"
    
    echo
    echo "Nom de la base de données : $sqlDB"
    echo "Nom d'utilisateur : $sqlUser"
    echo "Mot de passe : $sqlPass"

    echo
    echo "Patientez 5 secondes.."
    echo
    sleep 5
    clear
fi

install_directory() {

    while true; do
        echo
        echo "== Creation de la base de données terminée =="
        echo
        read -r -p "${1} le chemin absolue du dossier d'installation [default: /var/www/html/] : " responseInstallDir

        case "$responseInstallDir" in
        *)
            if [ ! $responseInstallDir = 0 ]; then
                installDirectory=$responseInstallDir
            else
                installDirectory=/var/www/html/
            fi
            ;;
        esac

        echo

        read -r -p "êtes vous sûr ? [y/N] : " responseInstallDirConfirm

        case "$responseInstallDirConfirm" in
        [yY][eE][sS] | [yY] | [oO][uU][iI] | [oO])
            true
            break
            ;;
        *)
            false
            ;;
        esac
    done
}

if install_directory "Choisissez"; then
    echo
    echo "Chemin d'installation : ${installDirectory}"
    echo
    echo "Patientez 5 secondes.."
    sleep 5
fi

install_confirmation() {

    while true; do

        read -r -p "${1} confirmer l'installation dans ce repertoire ? ${installDirectory} ? [y/N] : " responseInstallationConfirm

        case "$responseInstallationConfirm" in
        [yY][eE][sS] | [yY] | [oO][uU][iI] | [oO])
            true
            break
            ;;
        *)
            false
            clear
            echo
            echo "Annulation.."
            sleep 0.5
            exit
            ;;
        esac
    done
}

if install_confirmation "Voulez vous"; then
    echo
    echo "Choix confirmer, wordpress va l'installer sur votre système"
    echo
    echo "Patientez 5 secondes.."
    sleep 5
    clear
fi

##############################
#   Installation Wordpress   #
##############################

# apache directory link
apache="/etc/apache2/"
ports="/etc/apache2/ports.conf"
vhosts="/etc/apache2/sites-available/"
# default apache virtualHost name
fileNumberDefault=0
defaultFileName="$fileNumberDefault-wordpress.conf"
vHostDefaultPort=80
vHostNewPort=1799

# Creation du vHost

# Configuration du port
while grep -q "$vHostDefaultPort" $ports; do
    vHostDefaultPort=$((vHostNewPort += 1))
    # Si le port n'existe pas, le créer.
    if ! grep -q "$vHostDefaultPort" $ports; then

        # Ecriture du Port dans le ports.conf.
        sudo sed -i "4 a Listen $vHostDefaultPort" $ports
        break
    fi
done

# Texte du virtualHost
vHostText="
##############################################################\n
#   VitualHost Généré par le script Wordpress Auto-Install   #\n
#                         by AwiZy63                         #\n
##############################################################\n\n

<VirtualHost *:$vHostDefaultPort>\n\n

    ServerName localhost\n
    ServerAdmin webmaster@localhost\n
    DocumentRoot ${installDirectory}wordpress\n\n

    <Directory ${installDirectory}wordpress>\n
        AllowOverride All\n
    </Directory>\n\n

    ErrorLog ${APACHE_LOG_DIR}/error.log\n
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\n

</VirtualHost>
"

# Creation du fichier vHost
while [ -e ${vhosts}${defaultFileName} ]; do
    defaultFileName="$((fileNumberDefault += 1))-wordpress.conf"
    # Si le fichier n'existe pas, le créer.
    if [ ! -e ${vhosts}${defaultFileName} ]; then
        # Ecriture du fichier vHost.
        sudo echo -e ${vHostText} >${defaultFileName}
        sudo mv ./${defaultFileName} ${vhosts}${defaultFileName}
        break
    fi
done
sudo echo -e ${vHostText} >${defaultFileName}
sudo mv ./${defaultFileName} ${vhosts}${defaultFileName}

sleep 0.5

sudo mkdir -p $installDirectory
cd $installDirectory

sleep 0.5

# Telechargement et installation de Wordpress
sudo curl -O https://wordpress.org/latest.tar.gz

sleep 0.5

sudo tar -xvf latest.tar.gz

sudo rm latest.tar.gz

sleep 0.5

cd ${installDirectory}wordpress/

sleep 0.5

# Creation de la configuration Wordpress
sudo mv ${installDirectory}wordpress/wp-config-sample.php ${installDirectory}wordpress/wp-config.php

sleep 0.5

# Insertion des informations de base de données dans la config WordPress
sudo sed -i -e "s/database_name_here/${sqlDB}/g" ${installDirectory}wordpress/wp-config.php
sudo sed -i -e "s/username_here/${sqlUser}/g" ${installDirectory}wordpress/wp-config.php
sudo sed -i -e "s/password_here/${sqlPass}/g" ${installDirectory}wordpress/wp-config.php

sleep 0.5

# Attribution des droits et permissions
sudo chown -R www-data:www-data ${installDirectory}wordpress
sudo find ${installDirectory}wordpress/ -type d -exec chmod 750 {} \;
sudo find ${installDirectory}wordpress/ -type f -exec chmod 640 {} \;

# Activation du vHost et redemarrage du service Apache2
sleep 0.5
sudo a2ensite ${defaultFileName}
sleep 0.5
sudo service apache2 restart
sleep 0.5

sleep 1.5

clear

echo
echo "==========================================================="
echo "              Wordpress a bien été installé !              "
echo "==========================================================="
echo
echo "Nom de la base de données : $sqlDB"
echo "Nom d'utilisateur         : $sqlUser"
echo "Mot de passe              : $sqlPass"
echo
echo "==========================================================="
echo
echo "Chemin d'installation     : ${installDirectory}"
echo
echo "==========================================================="
echo
echo "Votre wordpress est accessible à l'adresse suivante :"
echo
echo "- http://localhost:${vHostNewPort}/"
echo
echo "==========================================================="
echo
firefox http://localhost:${vHostNewPort}/
