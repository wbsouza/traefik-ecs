[
  {
    "name": "traefik",
    "image": "traefik:v2.3",
    "essential": true,
    "command": [
      "--api.dashboard=true",
      "--api.insecure",
      "--api.debug=true",
      "--providers.ecs.clusters=${ecs_cluster_name}", 
      "--log.level=${debug_level}", 
      "--providers.ecs.region=${region}",
      "--entryPoints.web.address=:80",
      "--entryPoints.websecure.address=:443",
      "--certificatesresolvers.le.acme.httpchallenge=true",
      "--certificatesresolvers.le.acme.httpchallenge.entrypoint=web",
      "--certificatesresolvers.le.acme.email=${lets_encrypt_email}",
      "--certificatesresolvers.le.acme.storage=/letsencrypt/acme.json"
    ],
    "mountPoints": [
      {
        "sourceVolume": "letsencrypt",
        "containerPath": "/letsencrypt",
        "readOnly": false
      }
    ],
    "logConfiguration":{
      "logDriver": "awslogs",
      "options": {
          "awslogs-group": "${loggroup}",
          "awslogs-region": "${region}",
          "awslogs-stream-prefix": "traefik"
      }
    },
    "Environment" : [{
      "name": "AWS_ACCESS_KEY_ID",
      "value": "${aws_access_key}"
    }],
    "Secrets" :[{
      "name": "AWS_SECRET_ACCESS_KEY",
      "valuefrom": "${secret_arn}"
    }],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      },
      {
        "containerPort": 443,
        "hostPort": 443
      },
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]





     