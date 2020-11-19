# wordpress-install.sh

Script permettant l'automatisation de l'installation de l'outil **wordpress**. 


# Fichiers

 - wordpress-install.sh

## Installation

Récupérez le script sur votre machine avec git :

``` 
    git clone https://github.com/AwiZy63/wordpress-install-scripts.git
``` 

Lancez le script :

``` 
    cd wordpress-install-scripts/ && sudo chmod +x wordpress-install.sh && bash wordpress-install.sh
``` 

Installation du script : 

> Voulez vous installer les dépendances ?

``` 
    Y # si vous voulez installer les dépendances + la pile LinuxApacheMySQLPhp
``` 

Création de la base de données :

> Choisissez un nom de base de données [default: wp_db] :

``` 
    #Choisissez un nom de base de donnée non existant ou laissez vide si première installation
``` 

> Choisissez un nom d'utilisateur [default: wp_user] :

``` 
    #Choisissez un nom d'utilisateur pour votre base de données
``` 

> Choisissez un mot de passe [default: wp_password] :

``` 
    #Choisissez un mot de passse sécurisé pour votre base de données
``` 

> Choisissez le chemin absolue du dossier d'installation [default: /var/www/html/]


Attention /!\ : Le chemin de votre installation doit obligatoirement finir par un "/" (slash)

``` 
    #Choisissez un chemin dans votre système où vous souhaitez installer wordpress exemple: /home/wp_folder/ , ou laissez vide pour l'installer dans /var/www/html/
``` 

## Enjoy !

