#!/bin/bash
# Ce scipt permet de créer l'images jenkins_ops
# puis l'ajoute au dépôt

# Définir le nom du dépôt
DOCKER_REGISTRY=sonatype-nexus.backhole.ovh

# exécution du script dans l'environnement en cours
. ./script/docker_id.sh

# Importation de l'image utiliser dans le dockerfile
# Dans le but d'éviter l'import en cache
docker pull jenkins/jenkins:lts-jdk17

# Construire l'image
docker compose build --no-cache

# Demander à l'utilisateur de saisir le mot de passe
read -p "Veuillez saisir votre nom d'utilisateur de votre depot Docker: " DOCKER_USERNAME
read -s -p "Veuillez saisir votre mot de passe de votre depot Docker: " DOCKER_PASSWORD
echo # Ajouter un saut de ligne pour une meilleure présentation

# connexion au dépot
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD" "$DOCKER_REGISTRY"

# Pousser l'image vers le dépôt personnel
docker compose push

# déconnexion du dépôt
docker logout "$DOCKER_REGISTRY"