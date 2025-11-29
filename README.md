Lancer un mini serveur web avec Traefik en utilisant Docker

docker run -d --rm \
--network proxy \
--label 'traefik.enable=true' \
--label 'traefik.http.routers.miniserver.rule=Host(`miniserver.docker.localhost`)' \
--label 'traefik.http.routers.miniserver.entrypoints=websecure' mini-server