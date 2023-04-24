#!/bin/bash

# Création du dossier /jenkins_home avec les permissions appropriées
mkdir jenkins_home

# Démarrage du conteneur Jenkins avec Docker Compose
docker compose up -d

# voir les logs
docker compose logs -f