
from fabric.api import *

env.hosts = ['twindle.pudo.org']
env.key_filename = '/Users/lindenbergf/ec2/spon_ec2.pem'
env.user = 'ubuntu'
deploy_dir = '/home/ubuntu/twindle/'
backup_dir = '/home/ubuntu/backup'


def deploy():
    run('mkdir -p ' + backup_dir)
    run('pg_dump -f ' + backup_dir + '/twindle-`date +%Y%m%d`.sql twindle')
    with cd(deploy_dir + 'app'):
        run('git pull')
        run('git reset --hard HEAD')
        run('npm install .')
    sudo('supervisorctl reread')
    sudo('supervisorctl reload')


def install():
    sudo('rm -rf ' + deploy_dir)
    sudo('mkdir -p ' + deploy_dir)
    sudo('chown -R ' + env.user + ' ' + deploy_dir)
    put('deploy/*', deploy_dir)

    sudo('mv ' + deploy_dir + 'nginx.conf /etc/nginx/sites-available/twindle')
    sudo('ln -sf /etc/nginx/sites-available/twindle /etc/nginx/sites-enabled/twindle')
    sudo('service nginx restart')

    sudo('ln -sf ' + deploy_dir + 'supervisor.conf /etc/supervisor/conf.d/twindle.conf')
    run('mkdir ' + deploy_dir + 'logs')
    #sudo('chown -R ubtuntu.ubtuntu ' + deploy_dir + 'logs')

    run('git clone git://github.com/pudo/twindle.git ' + deploy_dir + 'app')
    deploy()
