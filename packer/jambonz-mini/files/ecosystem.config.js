module.exports = {
  apps : [
  {
    name: 'jambonz-webapp',
    script: 'npm',
    cwd: '/home/admin/apps/jambonz-webapp',
    args: 'run serve'
  },
  {
    name: 'jambonz-smpp-esme',
    cwd: '/home/admin/apps/jambonz-smpp-esme',
    script: 'app.js',
    out_file: '/home/admin/.pm2/logs/jambonz-smpp-esme.log',
    err_file: '/home/admin/.pm2/logs/jambonz-smpp-esme.log',
    combine_logs: true,
    instance_var: 'INSTANCE_ID',
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '2G',
    env: {
      NODE_ENV: 'production',
      HTTP_PORT: 3020,
      AVOID_UDH: true,
      JAMBONES_MYSQL_HOST: '127.0.0.1',
      JAMBONES_MYSQL_USER: 'admin',
      JAMBONES_MYSQL_PASSWORD: 'JambonzR0ck$',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '127.0.0.1',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_LOGLEVEL: 'info'
    }
  },
  {
    name: 'jambonz-api-server',
    cwd: '/home/admin/apps/jambonz-api-server',
    script: 'app.js',
    out_file: '/home/admin/.pm2/logs/jambonz-api-server.log',
    err_file: '/home/admin/.pm2/logs/jambonz-api-server.log',
    combine_logs: true,
    instance_var: 'INSTANCE_ID',
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      AUTHENTICATION_KEY: 'JWT-SECRET-GOES_HERE',
      JWT_SECRET: 'JWT-SECRET-GOES_HERE',
      JAMBONES_MYSQL_HOST: '127.0.0.1',
      JAMBONES_MYSQL_USER: 'admin',
      JAMBONES_MYSQL_PASSWORD: 'JambonzR0ck$',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '127.0.0.1',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_LOGLEVEL: 'info',
      JAMBONE_API_VERSION: 'v1',
      JAMBONES_TIME_SERIES_HOST: '127.0.0.1',
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1,
      HTTP_PORT:  3002,
      HOMER_BASE_URL: 'http://127.0.0.1:9080',
      HOMER_USERNAME: 'admin',
      HOMER_PASSWORD: 'sipcapture',
      JAEGER_BASE_URL: 'http://127.0.0.1:16686'
    }
  },
  {
    name: 'sbc-call-router',
    cwd: '/home/admin/apps/sbc-call-router',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    combine_logs: true,
    out_file: '/home/admin/.pm2/logs/jambonz-sbc-call-router.log',
    err_file: '/home/admin/.pm2/logs/jambonz-sbc-call-router.log',
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      HTTP_PORT:  4000,
      JAMBONES_INBOUND_ROUTE: '127.0.0.1:4002',
      JAMBONES_OUTBOUND_ROUTE: '127.0.0.1:4003',
      JAMBONZ_TAGGED_INBOUND: 1,
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1,
      JAMBONES_NETWORK_CIDR: 'PRIVATE_IP/32'
		}
  },
  {
    name: 'sbc-sip-sidecar',
    cwd: '/home/admin/apps/sbc-sip-sidecar',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/jambonz-sbc-sip-sidecar.log',
    err_file: '/home/admin/.pm2/logs/jambonz-sbc-sip-sidecar.log',
    combine_logs: true,
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      JAMBONES_LOGLEVEL: 'info',
      RTPENGINE_PING_INTERVAL: 30000,
      DRACHTIO_HOST: '127.0.0.1',
      DRACHTIO_PORT: 9022,
      DRACHTIO_SECRET: 'cymru',
      JAMBONES_NETWORK_CIDR: 'PRIVATE_IP/32',
      JAMBONES_MYSQL_HOST: '127.0.0.1',
      JAMBONES_MYSQL_USER: 'admin',
      JAMBONES_MYSQL_PASSWORD: 'JambonzR0ck$',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '127.0.0.1',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_TIME_SERIES_HOST: '127.0.0.1',
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1
		}
  },
  {
    name: 'sbc-outbound',
    cwd: '/home/admin/apps/sbc-outbound',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/jambonz-sbc-outbound.log',
    err_file: '/home/admin/.pm2/logs/jambonz-sbc-outbound.log',
    combine_logs: true,
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    env: {
      NODE_ENV: 'production',
      JAMBONES_LOGLEVEL: 'info',
      JAMBONES_NETWORK_CIDR: 'PRIVATE_IP/32',
      MIN_CALL_LIMIT: 9999,
      RTPENGINE_PING_INTERVAL: 30000,
      DRACHTIO_HOST: '127.0.0.1',
      DRACHTIO_PORT: 9022,
      DRACHTIO_SECRET: 'cymru',
      JAMBONES_RTPENGINE_UDP_PORT: 6000,
      JAMBONES_RTPENGINES: '127.0.0.1:22222',
      JAMBONES_MYSQL_HOST: '127.0.0.1',
      JAMBONES_MYSQL_USER: 'admin',
      JAMBONES_MYSQL_PASSWORD: 'JambonzR0ck$',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '127.0.0.1',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_TIME_SERIES_HOST: '127.0.0.1',
      JAMBONES_TRACK_ACCOUNT_CALLS: 0,
      JAMBONES_TRACK_SP_CALLS: 0,
      JAMBONES_TRACK_APP_CALLS: 0,
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1,
      MS_TEAMS_FQDN: ''
		}
  },
  {
    name: 'sbc-inbound',
    cwd: '/home/admin/apps/sbc-inbound',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/jambonz-sbc-inbound.log',
    err_file: '/home/admin/.pm2/logs/jambonz-sbc-inbound.log',
    combine_logs: true,
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    env: {
      NODE_ENV: 'production',
      JAMBONES_NETWORK_CIDR: 'PRIVATE_IP/32',
      JAMBONES_LOGLEVEL: 'info',
      DRACHTIO_HOST: '127.0.0.1',
      DRACHTIO_PORT: 9022,
      DRACHTIO_SECRET: 'cymru',
      JAMBONES_RTPENGINE_UDP_PORT: 7000,
      JAMBONES_RTPENGINES: '127.0.0.1:22222',
      JAMBONES_MYSQL_HOST: '127.0.0.1',
      JAMBONES_MYSQL_USER: 'admin',
      JAMBONES_MYSQL_PASSWORD: 'JambonzR0ck$',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '127.0.0.1',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_TIME_SERIES_HOST: '127.0.0.1',
      JAMBONES_TRACK_ACCOUNT_CALLS: 0,
      JAMBONES_TRACK_SP_CALLS: 0,
      JAMBONES_TRACK_APP_CALLS: 0,
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1,
      MS_TEAMS_SIP_PROXY_IPS: '52.114.148.0, 52.114.132.46, 52.114.75.24, 52.114.76.76, 52.114.7.24, 52.114.14.70'
		}
  },
  {
    name: 'sbc-rtpengine-sidecar',
    cwd: '/home/admin/apps/sbc-rtpengine-sidecar',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/jambonz-sbc-rtpengine-sidecar.log',
    err_file: '/home/admin/.pm2/logs/jambonz-sbc-rtpengine-sidecar.log',
    combine_logs: true,
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      LOGLEVEL: 'info',
      DTMF_ONLY: true,
      RTPENGINE_DTMF_LOG_PORT: 22223,
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1
    }
  },
  {
    name: 'jambonz-feature-server',
    cwd: '/home/admin/apps/jambonz-feature-server',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/jambonz-feature-server.log',
    err_file: '/home/admin/.pm2/logs/jambonz-feature-server.log',
    combine_logs: true,
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    env: {
      NODE_ENV: 'production',
      AUTHENTICATION_KEY: 'JWT-SECRET-GOES_HERE',
      JWT_SECRET: 'JWT-SECRET-GOES_HERE',
      JAMBONES_GATHER_EARLY_HINTS_MATCH: 1,
      JAMBONES_OTEL_ENABLED: 1,
      OTEL_EXPORTER_JAEGER_ENDPOINT: 'http://localhost:14268/api/traces',
      OTEL_EXPORTER_OTLP_METRICS_INSECURE: 1,
      OTEL_EXPORTER_JAEGER_GRPC_INSECURE: 1,
      OTEL_TRACES_SAMPLER: 'parentbased_traceidratio',
      OTEL_TRACES_SAMPLER_ARG: 1.0,
      VMD_HINTS_FILE: '/home/admin/apps/jambonz-feature-server/data/example-voicemail-greetings.json',
      ENABLE_METRICS: 1,
      STATS_HOST: '127.0.0.1',
      STATS_PORT: 8125,
      STATS_PROTOCOL: 'tcp',
      STATS_TELEGRAF: 1,
      AWS_REGION: 'AWS_REGION_NAME',
      JAMBONES_NETWORK_CIDR: 'PRIVATE_IP/32',
      JAMBONES_API_BASE_URL: '--JAMBONES_API_BASE_URL--',
      JAMBONES_GATHER_EARLY_HINTS_MATCH: 1,
      JAMBONES_MYSQL_HOST: '127.0.0.1',
      JAMBONES_MYSQL_USER: 'admin',
      JAMBONES_MYSQL_PASSWORD: 'JambonzR0ck$',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '127.0.0.1',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_LOGLEVEL: 'info',
      JAMBONES_TIME_SERIES_HOST: '127.0.0.1',
      HTTP_PORT: 3000,
      DRACHTIO_HOST: '127.0.0.1',
      DRACHTIO_PORT: 9023,
      DRACHTIO_SECRET: 'cymru',
      JAMBONES_SBCS: 'PRIVATE_IP',
      JAMBONES_FREESWITCH: '127.0.0.1:8021:JambonzR0ck$',
      SMPP_URL: 'http://PRIVATE_IP:3020'
    }
  }
]
};
