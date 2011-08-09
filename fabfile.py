from fabric.api import task

from pusher import env
env = env.defaults()

env.local_static = "."


@task
def deploy():
    from pusher import static
    static.sync()
