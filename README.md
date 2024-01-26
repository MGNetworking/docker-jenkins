## JENKINS (CI/CD)

* [Les Scripts d'exécution](#les-scripts-dexécution)
* [RUN](#run)
* [Accès navigateur](#accès-navigateur)
* [Accès Docker](#accès-docker)
* [Dockerfile](#dockerfile)
* [Documentation](#documentation)

### But

Le but de ce projet et la personnalisation du service [Jenkins](https://www.jenkins.io/) de manière à pouvoir interagir
avec la `CLI` du docker Host.
En utilisant une image de base jenkins
certifier : [jenkins/jenkins:lts-jdk17](https://hub.docker.com/layers/jenkins/jenkins/lts-jdk17/images/sha256-7d7371ab14525a0b0032e8a714f8ef6cfe5d0c37e3b9e6b68239543f2df9ba92?context=explore),
j'ai apporté plusieurs couches des modifications.

Pour plus de détail sur les modifications apportées voir la partie [Dockerfile](#dockerfile).

NB : Si vous voulez utiliser ce projet et que vous possédez un dépot privet, vous n'aurez qu'à modifier, dans le fichier
`.env` les références de votre dépôt.

Aussi, ce projet contient des scripts `Bash`. Il est conçu pour fonctionner sur Os Linux. Mais avec Windows, vous pouvez
utiliser [WSL](https://fr.wikipedia.org/wiki/Windows_Subsystem_for_Linux) qui un sous-système linux dans Windows.

### Les Scripts d'exécution

Ce projet est composé des fichiers suivants :

* Un `dockerfile` qui permet de créer une image à partir du `docker compose`
* Trois scripts placés dans le dossier `/script` qui interagisse avec le `dockerfile` et le `docker compose`

1. `docker_id.sh`

Il permet récupérer l'identifiant docker de la machine host. Cet identifiant sera utilisé au moment de la crèation du
groupe docker dans l'image Jenkins. Puis ce groupe sera ajouter à l'utilisateur Jenkins. Cela permettra à Jenkins
d'avoir les droites d'exécution sur le socket docker et donnera accès au conteneur du système host.

Cela n'est pas suffisant pour avoir l'accès au conteneur sur le système host. Il faut mapper le socket du système
avec le socket du conteneur jenkins. Mais le mapping de celui-ci ce fait à la création du conteneur par
l'intermédiaire de la section volume.

2. `build_push.sh`

Ce script permet construire l'image docker à partir du `docker compose`. Il exécute le script `docker_id.sh` dans
l'environnement du script `build_push.sh` ce qui lui permet de récupérer l'export du groupe Id docker.

Puis, Dans le but d'économisé les requests vers https://hub.docker.com/ un pull de l'image cible est réalisé en suite
la construction de l'image exécutée en utilisant le `docker compose `du projet sans utilise la mise en cache.

Après la création de cette image, une demande de connexion au dépot `Sonatype Nexus` ciblent le dépôt privé est
effectué. Après ouverture de la connexion l'ajoute de l'image fraichement créer et pousser dans le dépôt, puis
fermeture de la connexion.

3. `run.sh`

Ce script permet de créer un conteneur Jenkins sur la base de l'image se trouvant sur le dépôt. Il exécute une
demande de connexion, de la même manière que dans le script `build_push.sh`. Cette connexion va permettre `pull`
l'image se trouvant dans le dépôt privet.

Ensuite, le dossier `/jenkins_home` et créer puis modifier pour lui attribuer le `user/group` jenkins `1000:1000` qui
était créé dans l'image de base :
[jenkins/jenkins:lts-jdk17](https://hub.docker.com/layers/jenkins/jenkins/lts-jdk17/images/sha256-7d7371ab14525a0b0032e8a714f8ef6cfe5d0c37e3b9e6b68239543f2df9ba92?context=explore)

Puis en utilisant le `docker compose`, le conteneur sera créer, en mode détaché, en utilisant l'image récupérée du
dépôt. Les logs de ce conteneur seront affiché dans le terminal. Cela permettra de voir le processus d'exécution du
conteneur. Ainsi, vous pourrez récupérer le 1ᵉʳ mot de passe générer à la 1ʳᵉ utilisation.

### RUN

Pour lancer l'exécution de ce projet après l'avoir récupéré de dépôt, vous devez peut-être modifier les droits
d'exécution. Voici la commande à exécuter :

```shell
# modification des droit d'exécution
sudo chmod +x docker_id.sh build_push.sh run.sh
```

Order de lancement depuis la racine du projet :

```shell
# création de l'images + push vers dépôt
./script/build_push.sh

# création du conteneur
./script/run.sh
```

### Accès navigateur

| Designation | Adresse ip jenkins                                             |
|-------------|----------------------------------------------------------------|
| localhost   | [http://localhost:7788/jenkins](http://localhost:7788/jenkins) |

NB : Pour rappel, le nom de domain renvoi vers une IP fix et le port 80. Une redirection doit être effectuée
vers un revers proxy. Le reverse proxy redirigera la connexion vers l'adresse `IP:PORT` du conteneur jenkins.

Pour le développement, vous pouvez modifier le fichier host de manière à associer un nom de domain à votre
adresse `IP:PORT` local de Jenkins.

### Accès Docker

Accéder au conteneur `jenkins` puis listé les conteneurs en cours d'exécution :

```shell
docker exec -ti jenkins bash
docker ps 
```

### Dockerfile

Ce dockerfile utilise comme base l'image
[jenkins/jenkins:lts-jdk17](https://hub.docker.com/r/jenkins/jenkins/tags?page=1&name=lts-jdk17)
dans le but d'ajouté des couches de construction. Ces couches sont caractérisé par l'instruction `RUN`.
Voici dans l'ordre d'exécution la list de ces couches :

Mise à jour avant installation

```dockerfile
RUN apt-get update && apt-get full-upgrade -y
```

Installation des dépendances

```dockerfile
RUN apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    sudo \
    jq \
    nano \
    python3
```

Ajout de la clé GPG Docker

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

Configuration du dépôt Docker pour les packages Debian

```dockerfile
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Mise à jour de la source de paquets

```dockerfile
RUN apt-get update && apt-get full-upgrade -y
```

Puis pour pouvoir avoir accès au conteneur docker via le `docker.sock`, on procède à l'installation de
la `docker-ce-cli` et du `containerd.io` .

```dockerfile
RUN apt-get install docker-ce-cli containerd.io -y
```

`docker-ce-cli`  
Il s'agit du paquet qui fournit l'interface en ligne de commande (CLI) pour Docker Engine Community Edition (CE). Docker
CE est la version gratuite de Docker destinée à un usage non-commercial. La CLI est utilisée pour interagir avec Docker,
que ce soit pour la création, la gestion ou l'exécution de conteneurs.

`containerd.io`  
C'est un conteneur d'exécution open source utilisé par docker qui gère le cycle de vie des conteneurs sur la machine
hôte. Docker utilise `containerd` comme moteur d'exécution par défaut pour exécuter des conteneurs.

Création du groupe Docker

```dockerfile
RUN groupadd -g ${GID_DOCKER} docker
```

Ajout de l'utilisateur Jenkins au groupe Docker

```dockerfile
RUN usermod -aG docker jenkins
```

Il y a un total de 8 couches ajoutées à l'image Docker de base. Ces couches vont permettre l'accès au daemon docker de
la machine Host.

### Documentation

Le projet de [Gouvernance](https://www.jenkins.io/project/governance/) pour des informations sur le projet open source,
leur philosophie, valeurs et pratiques de développement.

Le code de conduite de [Jenkins](https://www.jenkins.io/project/conduct/).

Docker hub [jenkins](https://hub.docker.com/r/jenkins/jenkins/tags?page=1&name=lts-jdk17)  
GitHub de  [jenkins](https://github.com/jenkinsci)   
README du [jenkins](https://github.com/jenkinsci/docker/blob/master/README.md)

Exemple  [Jenkins-workflow](https://github.com/funkwerk/jenkins-workflow)  
Exemple  [Jenkinsfile](https://gist.github.com/merikan/228cdb1893fca91f0663bab7b095757c)
