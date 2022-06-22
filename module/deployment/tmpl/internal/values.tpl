enabled: true

# Service
mongodb:
    enabled: true
    pvc:
        storageClassName: null # You must specify a storage class name. Otherwise, the mongodb pod will not use pvc.
        accessModes: 
            - "ReadWriteOnce"
        requests:
            storage: 8Gi
redis:
    enabled: true
consul: # refer to https://github.com/hashicorp/consul-helm
    enabled: true
    server:
        replicas: 3
    ui:
        enabled: false

billing:
    enabled: false
    image:
        name: spaceone/billing
        version: 1.9.7

    application_grpc: {}

identity:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/identity
      version: 1.9.7.3

    pod:
        spec: {}

secret:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/secret
      version: 1.9.7.1
    application_grpc:
        BACKEND: ConsulConnector
        CONNECTORS:
            ConsulConnector:
                host: spaceone-consul-server
                port: 8500
    volumeMounts:
        application_grpc: []
        application_scheduler: []
        application_worker: []

    pod:
        spec: {}

repository:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/repository
      version: 1.9.7.1

plugin:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/plugin
      version: 1.9.7.2
 
    scheduler: true
    worker: true
    application_scheduler:
#        TOKEN: ___CHANGE_YOUR_ROOT_TOKEN___ 
        TOKEN_INFO:
            protocol: consul
            config:
                host: spaceone-consul-server
            uri: root/api_key/TOKEN

    pod:
        spec: {}

config:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/config
      version: 1.9.7.1

    pod:
        spec: {}

inventory:
    enabled: true
    replicas: 1
    replicas_worker: 2
    image:
      name: public.ecr.aws/megazone/spaceone/inventory
      version: 1.9.7.2
    scheduler: true
    worker: true
    application_grpc:
#        TOKEN: ___CHANGE_YOUR_ROOT_TOKEN___ 
        TOKEN_INFO:
            protocol: consul
            config:
                host: spaceone-consul-server
            uri: root/api_key/TOKEN
        collect_queue: collector_q

    application_scheduler:
#        TOKEN: ___CHANGE_YOUR_ROOT_TOKEN___ 
        TOKEN_INFO:
            protocol: consul
            config:
                host: spaceone-consul-server
            uri: root/api_key/TOKEN
    application_worker:
#        TOKEN: ___CHANGE_YOUR_ROOT_TOKEN___ 
        TOKEN_INFO:
            protocol: consul
            config:
                host: spaceone-consul-server
            uri: root/api_key/TOKEN
        HANDLERS:
          authentication: []
          authorization: []
          mutation: []

#
    volumeMounts:
        application_grpc: []
        application_scheduler: []
        application_worker: []

    pod:
        spec: {}

######################################
# if you want NLB for spacectl
# change ClusterIP to LoadBalancer
#####################################

#    service:
#      type: LoadBalancer
#      annotations:
#          service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
#          external-dns.alpha.kubernetes.io/hostname: inventory.spaceone.dev
#      ports:
#        - name: grpc
#          port: 50051
#          targetPort: 50051
#          protocol: TCP
#

##############################
# for monitoring webhook
# 1) Update WEBHOOK_DOMAIN:
#    - if your SpaceONE domain is spaceone.dev
#    - set WEBHOOK_DOMAIN as monitoring-webhook.spaceone.dev 
# 2) Update TOKEN or TOKEN_INFO
# 3) Update Ingress for rest API
#    - make sure that your certificate includes monitoring WEBHOOK_DOMAIN
#    - external dns is your WEBHOOK_DOMAIN name
##############################
monitoring:
    enabled: true
    grpc: true
    scheduler: true
    worker: true
    rest: false
    replicas: 1
    replicas_rest: 1
    replicas_worker: 1
    image:
      name: public.ecr.aws/megazone/spaceone/monitoring
      version: 1.9.7.1
    application_grpc:
      WEBHOOK_DOMAIN: https://monitoring_webhook_domain
#      TOKEN: __CHANGE_YOUR_ROOT_TOKEN___
      TOKEN_INFO:
          protocol: consul
          config:
              host: spaceone-consul-server
          uri: root/api_key/TOKEN
      INSTALLED_DATA_SOURCE_PLUGINS:
        - name: AWS CloudWatch
          plugin_info:
            plugin_id: plugin-41782f6158bb
            provider: aws
        - name: Azure Monitor
          plugin_info:
            plugin_id: plugin-c6c14566298c
            provider: azure
        - name: Google Cloud Monitoring
          plugin_info:
            plugin_id: plugin-57773973639a
            provider: google_cloud

    application_rest:
#      TOKEN: __CHANGE_YOUR_ROOT_TOKEN___
      TOKEN_INFO:
          protocol: consul
          config:
              host: spaceone-consul-server
          uri: root/api_key/TOKEN

    application_scheduler:
#      TOKEN: __CHANGE_YOUR_ROOT_TOKEN___
      TOKEN_INFO:
          protocol: consul
          config:
              host: spaceone-consul-server
          uri: root/api_key/TOKEN

    application_worker:
      WEBHOOK_DOMAIN: https://monitoring_webhook_domain
#      TOKEN: __CHANGE_YOUR_ROOT_TOKEN___
      TOKEN_INFO:
          protocol: consul
          config:
              host: spaceone-consul-server
          uri: root/api_key/TOKEN

#    ingress:
#        annotations:
#            alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS":443}]'
#            alb.ingress.kubernetes.io/inbound-cidrs: 0.0.0.0/0 # replace or leave out
#            alb.ingress.kubernetes.io/scheme: internet-facing
#            alb.ingress.kubernetes.io/target-type: ip 
#            alb.ingress.kubernetes.io/healthcheck-path: "/check"
#            alb.ingress.kubernetes.io/load-balancer-attributes: idle_timeout.timeout_seconds=600
#            alb.ingress.kubernetes.io/load-balancer-name: spaceone-prd-core-monitoring
#        servicePort: 80
#        path: /

    pod:
        spec: {}

statistics:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/statistics
      version: 1.9.7.1
 
    scheduler: true
    worker: true
    application_scheduler:
#        TOKEN: ___CHANGE_YOUR_ROOT_TOKEN___ 
        TOKEN_INFO:
            protocol: consul
            config:
                host: spaceone-consul-server
            uri: root/api_key/TOKEN

    pod:
        spec: {}

notification:
    enabled: true
    replicas: 1
    image:
      name: public.ecr.aws/megazone/spaceone/notification
      version: 1.9.7.1
    application_grpc:
        INSTALLED_PROTOCOL_PLUGINS:
          - name: Slack
            plugin_info:
              plugin_id: slack-notification-protocol
              options: {}
              schema: slack_webhook
          - name: Telegram
            plugin_info:
              plugin_id: plugin-telegram-noti-protocol
              options: {}
              schema: telegram_auth_token
          - name: Email
            plugin_info:
              plugin_id: plugin-email-noti-protocol
              options: {}
              secret_data:
                smtp_host: ${smpt_host}
                smtp_port: ${smpt_port}
                user: ${smpt_user}
                password: ${smpt_password}
              schema: email_smtp

    pod:
        spec: {}

cost-analysis:
    enabled: true
    scheduler: false
    worker: true
    replicas: 1
    replicas_worker: 2
    image:
      name: public.ecr.aws/megazone/spaceone/cost-analysis
      version: 1.9.7.1

    # Overwrite scheduler config
    application_scheduler:
        TOKEN: <root_token>

    application_grpc:
        DEFAULT_EXCHANGE_RATE:
            KRW: 1242.7
            JPY: 129.8

    application_worker:
        DEFAULT_EXCHANGE_RATE:
            KRW: 1242.7
            JPY: 129.8

    volumeMounts:
        application: []
        application_worker: []
        application_scheduler: []
        application_rest: []

    pod:
        spec: {}

marketplace-assets:
    enabled: false


# include config/alb.yaml (for ALB)
# include config/nlb.yaml (for NLB)
supervisor:
    enabled: true
    image:
      name: public.ecr.aws/megazone/spaceone/supervisor
      version: 1.9.7
    application: {}
    application_scheduler:
        NAME: root
        HOSTNAME: root-supervisor.svc.cluster.local
        BACKEND: KubernetesConnector
        CONNECTORS:
            RepositoryConnector:
                endpoint:
                    v1: grpc://repository.spaceone.svc.cluster.local:50051
            PluginConnector:
                endpoint:
                    v1: grpc://plugin.spaceone.svc.cluster.local:50051
            KubernetesConnector:
                namespace: root-supervisor
                start_port: 50051
                end_port: 50052
                headless: true
                replica:
                    inventory.Collector: 2
                    inventory.Collector?aws-ec2: 4
                    inventory.Collector?aws-cloud-services: 4
                    inventory.Collector?aws-power-state: 4
                    monitoring.DataSource: 2

#        TOKEN: ___CHANGE_YOUR_ROOT_TOKEN___ 
        TOKEN_INFO:
            protocol: consul
            config:
                host: spaceone-consul-server.spaceone.svc.cluster.local
            uri: root/api_key/TOKEN

    pod:
        spec: {}

ingress:
    enabled: false

spaceone-initializer:
    enabled: false
    image:
        version: 1.9.7

domain-initialzer:
    enabled: false

#######################################
# TYPE 1. global variable (for docdb) 
#######################################
global:
    namespace: spaceone
    supervisor_namespace: root-supervisor
    backend:
        sidecar: []
        volumes: []
    frontend:
        sidecar: []
        volumes: []
    shared_conf:
        HANDLERS:
            authentication:
            - backend: spaceone.core.handler.authentication_handler.AuthenticationGRPCHandler
              uri: grpc://identity:50051/v1/Domain/get_public_key
            authorization:
            - backend: spaceone.core.handler.authorization_handler.AuthorizationGRPCHandler
              uri: grpc://identity:50051/v1/Authorization/verify
            mutation:
            - backend: spaceone.core.handler.mutation_handler.SpaceONEMutationHandler
        CONNECTORS:
            IdentityConnector:
                endpoint:
                    v1: grpc://identity:50051
            SecretConnector:
                endpoint:
                    v1: grpc://secret:50051
            RepositoryConnector:
                endpoint:
                    v1: grpc://repository:50051
            PluginConnector:
                endpoint:
                    v1: grpc://plugin:50051
            ConfigConnector:
                endpoint:
                    v1: grpc://config:50051
            InventoryConnector:
                endpoint:
                    v1: grpc://inventory:50051
            MonitoringConnector:
                endpoint:
                    v1: grpc://monitoring:50051
            StatisticsConnector:
                endpoint:
                    v1: grpc://statistics:50051
            NotificationConnector:
                endpoint:
                    v1: grpc://notification:50051
            CostAnalysisConnector:
                endpoint:
                    v1: grpc://cost-analysis:50051/v1
        CACHES:
            default:
                backend: spaceone.core.cache.redis_cache.RedisCache
                host: redis
                port: 6379
                db: 0
                encoding: utf-8
                socket_timeout: 10
                socket_connect_timeout: 10


#######################################
# TYPE 2. global variable (for mongodb cluster)
#######################################
#global:
#    namespace: spaceone
#    supervisor_namespace: root-supervisor
#    backend:
#        sidecar:
#            - name: mongos
#              image: mongo:4.4.0-bionic
#              command: [ 'mongos', '--config', '/mnt/mongos.yml', '--bind_ip_all' ]
#              volumeMounts:
#                - name: mongos-conf
#                  mountPath: /mnt/mongos.yml
#                  subPath: mongos.yml
#                  readOnly: true
#                - name: mongo-shard-key
#                  mountPath: /opt/mongos/mongo-shard.pem
#                  subPath: mongo-shard.pem
#                  readOnly: true
#        volumes:
#            - name: mongo-shard-key
#              secret:
#                  defaultMode: 0400
#                  secretName: mongo-shard-key
#            - name: mongos-conf
#              configMap:
#                  name: mongos-conf