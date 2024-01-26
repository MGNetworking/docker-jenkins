#!/bin/bash

# Vérifiez si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Veuillez installer Docker avant d'exécuter ce script."
    exit 1
fi

# Récupérez l'ID du groupe Docker
DOCKER_GID=$(getent group docker | cut -d: -f3)

# Affichez l'ID du groupe Docker
echo "L'ID du groupe Docker sur la machine hôte est : $DOCKER_GID"

# export du groupe ID docker
export DOCKER_GID