auth:
  postgresPassword: "${postgres_password}"
  database: appdb
  username: appuser
  password: "${app_password}"

primary:
  persistence:
    enabled: true
    size: 5Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 512Mi
      cpu: 500m

readReplicas:
  replicaCount: 1
  persistence:
    enabled: true
    size: 5Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 250m
    limits:
      memory: 512Mi
      cpu: 500m
