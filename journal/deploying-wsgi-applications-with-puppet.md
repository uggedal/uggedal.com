% Deploying WSGI applications with Puppet
% 2011-05-15

Deploying Python WSGI applications can be a bit tedious. My preferred way
of hosting such applications on Debian GNU/Linux involves:

1. Checking out a copy of the application code.
2. Installing Virtualenv and creating a virtualenv for the application.
3. Installing all dependencies of the application from a requirements file
   into the virtualenv.
4. Installing Gunicorn into the virtualenv for the application.
5. Create a init script which starts Gunicorn with the application.
6. Installing Monit and configure it to monitor the Gunicorn process.
7. Installing and configuring Nginx.
8. Setting up a virtual host in Nginx which proxies through a UNIX socket
   to the Gunicorn process.

Enter Puppet -- a *declarative* configuration management tool. With Puppet you
describe how you want the setup of your stack to look like. Puppet can then
recreate that stack from any known starting point. Contrast this with
automation tools like Fabric which is *imperative* in nature. So in stead of
saying "Install that package, delete that file, run that script" with
imperative tools your conversation looks more like "I have a machine with
this package and its started on boot with this user" with declarative tools
like Puppet.

Using Puppet and some Puppet modules I recently created the process
is distilled to the following steps for a WSGI blog application:

1. Place your applications source code including a `requirements.txt`
   under `/usr/local/src/blog`.
2. Install Puppet:

  ```sh
  apt-get install puppet
  ```
3. Paste the following into a puppet manifest file (`blog.pp`):

    ```puppet
    Exec {
      path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    }

    include webapp::python

    webapp::python::instance { "blog":
      domain => "blog.uggedal.com",
      wsgi_module => "blog:app",
      requirements => true,
    }
    ```
4. Clone the following Puppet modules into a modules directory:

    ```sh
    mkdir modules
    git clone git://github.com/puppetmodules/puppet-module-webapp.git modules/webapp
    git clone git://github.com/puppetmodules/puppet-module-python.git modules/python
    git clone git://github.com/puppetmodules/puppet-module-monit.git modules/monit
    git clone git://github.com/puppetmodules/puppet-module-nginx.git modules/nginx
    ```
4. Run the file with Puppet (as root or with sudo):
        
    ```sh
    puppet apply --modulepath=modules blog.pp
    ```

Note that running this Puppet manifest as root will potentially overwrite
files you already have configured on your machine like:

* `/etc/nginx/nginx.conf`
* `/etc/monit/monitrc`

Do you need a database? Get PostgreSQL installed, configured, and a user and
database created by:

1. Add the following to `blog.pp`:

    ```puppet
    include postgresql::server
    include postgresql::python

    postgresql::database { "blog":
      owner => "bloguser",
    }
    ```
1. Clone my [PostgreSQL Puppet module][postgresql]:

    ```sh
    git clone git://github.com/puppetmodules/puppet-module-postgresql.git modules/postgresql
    ```
3. Run Puppet again:

    ```sh
    puppet apply --modulepath=modules blog.pp
    ```

Take a look at the README of my [Puppet webapp module][webapp] for more
detailed instructions including how to use it with Django applications.
You should also check out the modules used by the webapp module:
[Nginx module][nginx], [Monit module][monit], and [Python module][python].

[postgresql]: https://github.com/puppetmodules/puppet-module-postgresql
[webapp]: https://github.com/puppetmodules/puppet-module-webapp
[nginx]: https://github.com/puppetmodules/puppet-module-nginx
[monit]: https://github.com/puppetmodules/puppet-module-monit
[python]: https://github.com/puppetmodules/puppet-module-python
