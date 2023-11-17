#!/bin/bash

# Création du dossier /jenkins_home avec les permissions appropriées
sudo mkdir jenkins_home

# modif jenkins dossier
sudo chown -R 1000:1000 jenkins_home/

# Démarrage du conteneur Jenkins avec Docker Compose
docker compose up -d

# voir les logs
docker compose logs -f
