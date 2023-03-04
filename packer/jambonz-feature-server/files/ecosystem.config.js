module.exports = {
  apps : [
  {
    name: 'jambonz-feature-server',
    cwd: '/home/admin/apps/jambonz-feature-server',
    script: 'app.js',
    instance_var: 'INSTANCE_ID',
    out_file: '/home/admin/.pm2/logs/jambonz-feature-server.log',
    err_file: '/home/admin/.pm2/logs/jambonz-feature-server.log',
    exec_mode: 'fork',
    instances: 1,
    autorestart: true,
    watch: false,
    env: {
      NODE_ENV: 'production',
      JWT_SECRET: 'JWT-SECRET-GOES_HERE',
      JAMBONES_GATHER_EARLY_HINTS_MATCH: 1,
      ENABLE_DATADOG_METRICS: 0,
      JAMBONES_NETWORK_CIDR: '172.31.32.0/24',
      JAMBONES_MYSQL_HOST: '${JAMBONES_MYSQL_HOST}',
      JAMBONES_GATHER_EARLY_HINTS_MATCH: 1,
      JAMBONES_MYSQL_USER: '${JAMBONES_MYSQL_USER}',
      JAMBONES_MYSQL_PASSWORD: '${JAMBONES_MYSQL_PASSWORD}',
      JAMBONES_MYSQL_DATABASE: 'jambones',
      JAMBONES_MYSQL_CONNECTION_LIMIT: 10,
      JAMBONES_REDIS_HOST: '${JAMBONES_REDIS_HOST}',
      JAMBONES_REDIS_PORT: 6379,
      JAMBONES_LOGLEVEL: 'info',
      HTTP_PORT: 4001,
      DRACHTIO_HOST: '127.0.0.1',
      DRACHTIO_PORT: 9023,
      DRACHTIO_SECRET: 'cymru',
      JAMBONES_SBCS: '172.31.32.100:5060',
      JAMBONES_FEATURE_SERVERS: '127.0.0.1:9023:cymru',
      JAMBONES_FREESWITCH: '127.0.0.1:8021:JambonzR0ck$'
		}
  }]
};