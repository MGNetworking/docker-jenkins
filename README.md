# JENKINS

### Introduction
Ce projet est composé des fichiers suivants :
* Un dockerfile qui permet de créer une image à partir du [Reference docker hub]( https://hub.docker.com/layers/jenkins/jenkins/lts-jdk11/images/sha256-8f7043722b3bb576fde60fa4ab59465a4b77e677c92774514897301ab77825a3?context=explore)
* Un docker compose qui permettra lancer la construction de l'image jenkins. 
Et à partir de cette image créera un conteneur docker de l'image Jenkins
* Un fichier init.sh qui script initialisation. Il devra créer le ou les volumes et lancera le docker compose
ainsi que les logs du conteneur en cours d'exécution.

### Git Branch
Ce projet contient 2 branch :
* preprod
* master

### RUN
Pour lancer l'exécution de ce projet après l'avoir récupéré de dépôt, vous devez modifier les droits 
d'exécution du fichier `init.sh`.
Voici la commande à exécuter :

```shell
sudo chmod +x init.sh
```

Après avoir exécuté cette commande, le fichier init.sh pourra être lancé avec la commande suivant :

```shell
./init.sh
```





