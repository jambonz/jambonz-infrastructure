module.exports = {
  apps : [
   {
       name: 'node-red',
       cwd: '/home/admin/apps/node-red',
       script: 'packages/node_modules/node-red/red.js',
       out_file: '/home/admin/.pm2/logs/node-red.log',
       err_file: '/home/admin/.pm2/logs/node-red.log',
       combine_logs: true,
       instance_var: 'INSTANCE_ID',
       exec_mode: 'fork',
       instances: 1,
       autorestart: true,
       watch: false,
       max_memory_restart: '1G',
       env: {
       },
   }
   ]
};