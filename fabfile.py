
from fabric.api import *

env.hosts = ['norton.pudo.org']
deploy_dir = '/var/www/twindle.pudo.org/'
backup_dir = '/var/www/opendatalabs.org/backup'
remote_user = 'fl'

def deploy():
    run('mkdir -p ' + backup_dir)
    run('pg_dump -f ' + backup_dir + '/spon_twitter-`date +%Y%m%d`.sql spon_twitter')
    with cd(deploy_dir + 'app'):
        run('git pull')
        run('git reset --hard HEAD')
        run('npm install .')
    sudo('supervisorctl reread')
    sudo('supervisorctl restart twindle.pudo.org')

def install():
    sudo('rm -rf ' + deploy_dir)
    sudo('mkdir -p ' + deploy_dir)
    sudo('chown -R ' + remote_user + ' ' + deploy_dir)
    put('deploy/*', deploy_dir)

    sudo('mv ' + deploy_dir + 'nginx.conf /etc/nginx/sites-available/twindle.pudo.org')
    sudo('ln -sf /etc/nginx/sites-available/twindle.pudo.org /etc/nginx/sites-enabled/twindle.pudo.org')
    sudo('service nginx restart')

    sudo('ln -sf ' + deploy_dir + 'supervisor.conf /etc/supervisor/conf.d/twindle.pudo.org.conf')
    run('mkdir ' + deploy_dir + 'logs')
    sudo('chown -R www-data.www-data ' + deploy_dir + 'logs')

    run('git clone git://github.com/pudo/twindle.git ' + deploy_dir + 'app')
    deploy()

