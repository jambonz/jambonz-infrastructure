module.exports = {
  apps : [
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
		},
  },
  {
    name: 'jambonz-webapp',
    script: 'npm',
    cwd: '/home/admin/apps/jambonz-webapp',
    args: 'run serve'
  }
 ]
};