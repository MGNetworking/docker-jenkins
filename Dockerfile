# Image Jenkins avec ajout de docker

FROM jenkins/jenkins:lts-jdk11
LABEL authors="Maxime Ghalem"

# sélection de l'utilisateur root pour l'installation
USER root

# Mise à jour avant installation
RUN apt-get update && apt-get full-upgrade -y

# Installation des dépendances
RUN apt-get install \
    ca-certificates \
    curl \
    gnupg

# Ajout de la clé GPG officielle Docker
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg

# Configuration du dépôt
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mise à jour de la sources de paquets
RUN apt-get update && apt-get full-upgrade -y

# Installer la dernière version Docker
RUN apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Ajout du user jenkins au groupe docker
RUN usermod -aG docker jenkins

# retour au user jenkins
USER jenkins


