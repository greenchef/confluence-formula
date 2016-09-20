{%- from 'confluence/conf/settings.sls' import confluence with context %}


apache:
  pkg.installed:
    - pkgs:
       - apache2
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache

apache-restart:
  module.wait:
    - name: service.restart
    - m_name: apache2

apache-reload:
  module.wait:
    - name: service.reload
    - m_name: apache2

confluence-vhost:
  file.managed:
    - name: /etc/apache2/sites-available/confluence
    - source: salt://confluence/templates/confluence-vhost.tmpl

disable-default-site:
  file.absent:
    - name: /etc/apache2/sites-enabled/000-default
    - listen_in:
      - module: apache-reload
    - require:
      - file: enable-confluence-site

enable-confluence-site:
  file.symlink:
    - name: /etc/apache2/sites-enabled/confluence
    - target: /etc/apache2/sites-available/confluence
    - listen_in:
      - module: apache-reload
    - require:
      - file: confluence-vhost
 
a2enmod proxy:
  cmd.wait:
    - watch:
      - pkg: apache
    - listen_in:
      - module: apache-restart

a2enmod proxy_http:
  cmd.wait:
    - watch:
      - pkg: apache
    - listen_in:
      - module: apache-restart
