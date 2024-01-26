#!/bin/bash
# Script récupérer l'images du dépôt et lance le conteneur

# Définir le nom du dépôt
DOCKER_REGISTRY=sonatype-nexus.backhole.ovh

# Demander à l'utilisateur de saisir le mot de passe
read -p "Veuillez saisir votre nom d'utilisateur Docker: " DOCKER_USERNAME
read -s -p "Veuillez saisir votre mot de passe Docker: " DOCKER_PASSWORD
echo # Ajouter un saut de ligne pour une meilleure présentation

# connexion au dépot
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" "$DOCKER_REGISTRY"

# Pull de l'images en correspondance au docker compose cible
docker compose -f ../docker-compose.yml pull

# déconnexion du dépôt
docker logout "$DOCKER_REGISTRY"

# Création du dossier /jenkins_home avec les permissions appropriées
sudo mkdir jenkins_home

# modif jenkins dossier
sudo chown -R 1000:1000 jenkins_home/

# Démarrage du conteneur Jenkins avec Docker Compose
docker compose -f ../docker-compose.yml up -d

# voir les logs
docker compose -f ../docker-compose.yml  logs -f