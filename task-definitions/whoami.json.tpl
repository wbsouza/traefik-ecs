[
  {
    "name": "whoami",
    "image": "containous/whoami:v1.5.0",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "dockerLabels": {
      "traefik.enable": "true",

      "traefik.http.routers.whoami.entrypoints": "web",
      "traefik.http.routers.whoami.rule": "Host(`${app_hostname}`)",
      "traefik.http.routers.whoami.service": "service-traefik-whoami",

      "traefik.http.routers.whoami-secure.rule": "Host(`${app_hostname}`)",
      "traefik.http.routers.whoami-secure.entrypoints": "websecure",
      "traefik.http.routers.whoami-secure.tls": "true",
      "traefik.http.routers.whoami-secure.tls.options": "default",
      "traefik.http.routers.whoami-secure.service": "service-traefik-whoami",
      "traefik.http.routers.whoami-secure.tls.certresolver": "le",

      "traefik.http.services.service-traefik-whoami.loadbalancer.server.port": "80"
    }
  }
]
