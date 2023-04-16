# Image Jenkins avec ajout de docker

FROM jenkins/jenkins:lts-jdk11
LABEL authors="Maxime Ghalem"

USER root

# Configurer le référentiel
# Mettez à jour
RUN apt-get update && apt-get full-upgrade -y

# Puis l’installation des dépendances

RUN apt-get install \
    ca-certificates \
    curl \
    gnupg

# Ajouter la clé GPG officielle de Docker
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg

# Utilisez la commande suivante pour configurer le dépôt
RUN echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mise à jour de la sources de paquets
RUN apt-get update && apt-get full-upgrade -y

# Installer la dernière version Docker
RUN apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Ajoute l'utilisateur jenkins au groupe docker
RUN usermod -aG docker jenkins

# Donne au groupe docker les droits de lecture et d'écriture sur la socket Docker
RUN chown root:docker /var/run/docker.sock \
    && chmod 660 /var/run/docker.sock

# définir un mot de passe pour l'utilisateur jenkins
RUN echo 'jenkins:c61d496aba684ec5b73a2fc0ea4290fe' | chpasswd

# retour au user jenkins
USER jenkins


