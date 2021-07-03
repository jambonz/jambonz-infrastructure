module.exports = {
  apps : [
    {
      name: 'sbc-rtpengine-sidecar',
      cwd: '/home/admin/apps/sbc-rtpengine-sidecar',
      script: 'app.js',
      instance_var: 'INSTANCE_ID',
      out_file: '/home/admin/.pm2/logs/jambonz-sbc-rtpengine-sidecar.log',
      err_file: '/home/admin/.pm2/logs/jambonz-sbc-rtpengine-sidecar.log',
      exec_mode: 'fork',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        LOGLEVEL: 'info',
        JAMBONES_SBCS: '${JAMBONES_SBC_SIP_IPS}',
        ENABLE_METRICS: 1,
        STATS_HOST: '127.0.0.1',
        STATS_PORT: 8125,
        STATS_PROTOCOL: 'tcp',
        STATS_TELEGRAF: 1
      }
    }
  ]
};