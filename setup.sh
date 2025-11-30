#!/bin/bash

# Script de configuration Traefik avec remplacement automatique des valeurs

echo "=== Configuration Traefik ==="
echo ""

# Demander le nom d'utilisateur
read -p "Entrez le nom d'utilisateur pour Traefik: " USERNAME

# Demander le mot de passe
read -sp "Entrez le mot de passe: " PASSWORD
echo ""

# Demander confirmation du mot de passe
read -sp "Confirmez le mot de passe: " PASSWORD_CONFIRM
echo ""

# Vérifier que les mots de passe correspondent
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Erreur: Les mots de passe ne correspondent pas!"
    exit 1
fi

read -p "Entrez votre adresse e-mail: " EMAIL
echo ""

read -p "Entrez le nom de domaine pour Traefik (ex: example.com): " DOMAIN
echo ""

read -sp "Entrez votre token cloudflare: " CLOUDFLARE_TOKEN
echo ""

# Créer le dossier secrets s'il n'existe pas
mkdir -p ./secrets

# Enregistrer les secrets Cloudflare
echo "$EMAIL" > ./secrets/cloudflare-email.secret
echo "$CLOUDFLARE_TOKEN" > ./secrets/cloudflare-token.secret
echo "Secrets Cloudflare enregistrés dans ./secrets/"

# Générer le hash du mot de passe pour Traefik
echo "Génération des identifiants..."
HASHED_PASSWORD=$(openssl passwd -apr1 "$PASSWORD")

# Échapper les caractères spéciaux pour sed
HASHED_USER="$USERNAME:$HASHED_PASSWORD"
ESCAPED_HASHED_USER=$(echo "$HASHED_USER" | sed 's/\$/\\$/g' | sed 's/\//\\\//g')

# Remplacer dans compose.yml
if [ -f "compose.yml" ]; then
    sed -i "s/{{domain\.name}}/$DOMAIN/g" compose.yml
    sed -i "s/{{hashed_user}}/$ESCAPED_HASHED_USER/g" compose.yml
    echo "✓ compose.yml mis à jour"
else
    echo "⚠ compose.yml non trouvé"
fi

# Remplacer dans traefik.yml
if [ -f "traefik.yml" ]; then
    sed -i "s/{{domain\.name}}/$DOMAIN/g" traefik.yml
    sed -i "s/{{email}}/$EMAIL/g" traefik.yml
    echo "✓ traefik.yml mis à jour"
else
    echo "⚠ traefik.yml non trouvé"
fi

echo ""
echo "=== Configuration terminée ==="
echo "Utilisateur: $USERNAME"
echo "Domaine: $DOMAIN"
echo "Email: $EMAIL"