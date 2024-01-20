## JENKINS (CI/CD)

* [Introduction](#introduction)
* [RUN](#run)
* [Accès navigateur](#accès-navigateur)
* [Accès Docker](#accès-docker)
* [Dockerfile](#dockerfile)
* [Documentation](#documentation)

### But

Le but de ce projet et la personnalisation le programme [Jenkins](https://www.jenkins.io/) de manière à pouvoir
interagir avec la CLI du docker Host. J'ai repris une image jenkins certifier en y ajoutent une configuration docker cli
et conteneur IO.
Pour plus de détail sur son fonctionnement voir la partie `Dockerfile`.

### Introduction

Ce projet est composé des fichiers suivants :

* Un dockerfile qui permet de créer une image à partir
  du [Reference docker hub]( https://hub.docker.com/layers/jenkins/jenkins/lts-jdk11/images/sha256-8f7043722b3bb576fde60fa4ab59465a4b77e677c92774514897301ab77825a3?context=explore)
* Un docker compose qui permettra lancer la construction de l'image jenkins.
  Et à partir de cette image créera un conteneur docker de l'image Jenkins
* Un fichier script `run-nas.sh` qui initialise le projet pour le Nas Synology. Il créera le
  volume `jenkins_home/` avec les droits utilisateur et groupe configurer et lancera le docker compose ainsi que les
  logs du conteneur en cours d'exécution.

### RUN

Pour lancer l'exécution de ce projet après l'avoir récupéré de dépôt, vous devez modifier les droits
d'exécution du fichier `run-nas.sh`. Voici la commande à exécuter :

```shell
# modification des droit d'exécution
sudo chmod +x run-nas.sh run.sh
```

Ces Scripts sont était conçu pour une version de `docker compose` différente

```shell
./run.sh

./run-nas.sh
```

### Accès navigateur

| Designation   | Adresse ip jenkins                                                           |
|---------------|------------------------------------------------------------------------------|
| PC Dev  local | [http://localhost:7788/jenkins](http://localhost:7788/jenkins)               |
| Serveur Nas   | [https://jenkins.backhole.ovh/jenkins](https://jenkins.backhole.ovh/jenkins) |

NB : Pour rappel, le nom de domain renvoi vers une IP fix et le port 80. Une redirection doit être effectuée
entre le routeur (la box) et le reverse proxy (NGINX). Le reverse proxy redirigera vers l'adresse ip du
container jenkins.

Pour le développement, vous pouvez modifier le fichier host de manière à associer un nom de domain à votre adresse ip
localhost

### Accès Docker

Accéder au container puis listé les containers en cours d'exécution :

```shell
docker exec -ti jenkins bash
docker ps 
```

### Dockerfile

Ce dockerfile utilise
l'image [jenkins/jenkins:lts-jdk11](https://hub.docker.com/r/jenkins/jenkins/tags?page=1&name=lts-jdk11)
dans le but de construire une nouvelle image permettent d'accès au container docker sur la machine Host.

Dans 1er temps, il faut ajoute clé GPG officielle Docker

```dockerfile
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg
```

`install -m 0755 -d /etc/apt/keyrings`  
Cette commande crée le répertoire /etc/apt/keyrings avec les permissions nécessaires.

`curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg `  
Cette commande récupère la clé GPG officielle de Docker, la décode (en utilisant gpg --dearmor), et la sauvegarde en
tant que fichier /etc/apt/keyrings/docker.gpg.

`chmod a+r /etc/apt/keyrings/docker.gpg`   
Cette commande ajuste les permissions du fichier docker.gpg pour qu'il soit lisible par tous les utilisateurs.

Puis configurer le dépôt Docker pour les packages Debian

```dockerfile
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Puis pour pouvoir avoir accès au container docker via le `docker.sock`, on procède à l'installation de la docker-ce-cli
et du containerd.io.

```dockerfile
RUN apt-get install docker-ce-cli containerd.io -y
```

`docker-ce-cli`  
Il s'agit du paquet qui fournit l'interface en ligne de commande (CLI) pour Docker Engine Community
Edition (CE). Docker CE est la version gratuite de Docker destinée à un usage non-commercial. La CLI est utilisée pour
interagir avec Docker, que ce soit pour la création, la gestion ou l'exécution de conteneurs.

`containerd.io`  
C'est un conteneur d'exécution open source utilisé par Docker. Containerd gère le cycle de vie des
conteneurs sur la machine hôte. Docker utilise containerd comme moteur d'exécution par défaut pour exécuter
des conteneurs.

### Documentation

Le projet de [Gouvernance](https://www.jenkins.io/project/governance/) pour des informations sur le projet
open source, leur philosophie, valeurs et pratiques de développement.

Le code de conduite de Jenkins peut être consulté [ici](https://www.jenkins.io/project/conduct/).

GitHub de jenkins [ici](https://github.com/jenkinsci)   
README du jenkins [ici](https://github.com/jenkinsci/docker/blob/master/README.md).

Exemple jenkins-workflow [ici](https://github.com/funkwerk/jenkins-workflow)  
Exemple jenkinsfile [ici](https://gist.github.com/merikan/228cdb1893fca91f0663bab7b095757c)
