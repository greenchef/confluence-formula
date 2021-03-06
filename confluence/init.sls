{%- from 'confluence/conf/settings.sls' import confluence with context %}

include:
  - sun-java
  - sun-java.env
#  - apache.vhosts.standard
#  - apache.mod_proxy_http

### APPLICATION INSTALL ###
unpack-confluence-tarball:
  archive.extracted:
    - name: {{ confluence.prefix }}
    - source: {{ confluence.source_url }}/atlassian-confluence-{{ confluence.version }}.tar.gz
    - source_hash: {{ salt['pillar.get']('confluence:source_hash', '') }}
    - archive_format: tar
    - user: confluence
    - tar_options: z
    - unless: ps aux | grep confluence | grep -v grep
    - if_missing: {{ confluence.prefix }}/atlassian-confluence-{{ confluence.version }}
    - runas: confluence
    - keep: True
    - require:
      - module: confluence-stop
      - file: confluence-init-script
      - user: confluence
    - listen_in:
      - module: confluence-restart

create-confluence-symlink:
  file.symlink:
    - name: {{ confluence.prefix }}/confluence
    - target: {{ confluence.prefix }}/atlassian-confluence-{{ confluence.version }}
    - user: confluence
    - watch:
      - archive: unpack-confluence-tarball

unpack-dbdriver-tarball:
  archive.extracted:
    - name: {{ confluence.prefix }}/confluence/mysql_driver/
    - source: {{ confluence.dbdriver_url }}/mysql-connector-java-{{ confluence.dbdriver_version }}.tar.gz
    - source_hash: {{ salt['pillar.get']('confluence:dbdriver_hash', '') }}
    - archive_format: tar
    - user: confluence
    - tar_options: z
    - keep: True
    - require:
      - module: confluence-stop
      - file: confluence-init-script
      - user: confluence
      - file: create-confluence-symlink
    - watch:
      - file: create-confluence-symlink
    - listen_in:
      - module: confluence-restart

fix-confluence-filesystem-permissions:
  file.directory:
    - user: confluence
    - recurse:
      - user
    - names:
      - {{ confluence.prefix }}/atlassian-confluence-{{ confluence.version }}
      - {{ confluence.home }}
      - {{ confluence.log_root }}
      - {{ confluence.attachments_root }}
    - watch:
      - archive: unpack-confluence-tarball
      - archive: unpack-dbdriver-tarball

create-attachments-symlink:
  file.symlink:
    - name: /var/atlassian/application-data/confluence/attachments
    - target: {{ confluence.attachments_root }}
    - user: confluence
    - watch:
      - archive: unpack-confluence-tarball
      - archive: unpack-dbdriver-tarball

### SERVICE ###
confluence-service:
  service.running:
    - name: confluence
    - enable: True
    - require:
      - archive: unpack-confluence-tarball
      - archive: unpack-dbdriver-tarball
      - file: confluence-init-script

# used to trigger restarts by other states
confluence-restart:
  module.wait:
    - name: service.restart
    - m_name: confluence

confluence-stop:
  module.wait:
    - name: service.stop
    - m_name: confluence

confluence-init-script:
  file.managed:
    - name: '/lib/systemd/system/confluence.service'
    - source: salt://confluence/templates/confluence.systemd.tmpl
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
      confluence: {{ confluence|json }}

create-confluence-service-symlink:
  file.symlink:
    - name: '/etc/systemd/system/confluence.service'
    - target: '/lib/systemd/system/confluence.service'
    - user: root
    - watch:
      - file: confluence-init-script

confluence:
  user.present

fs.file-max:
  sysctl.present:
    - value: 2000000

### FILES ###
{{ confluence.prefix }}/confluence/conf/server.xml:
  file.managed:
    - source: salt://confluence/templates/server.xml.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - listen_in:
      - module: confluence-restart

{{ confluence.prefix }}/confluence/confluence/WEB-INF/classes/confluence-init.properties:
  file.managed:
    - source: salt://confluence/templates/confluence-init.properties.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - context:
      confluence: {{ confluence|json }}
    - listen_in:
      - module: confluence-restart

{{ confluence.prefix }}/confluence/confluence.jks:
  file.managed:
    - source: salt://salt/files/confluence.jks
    - user: {{ confluence.user }}
    - listen_in:
      - module: confluence-restart

{{ confluence.prefix }}/confluence/bin/setenv.sh:
  file.managed:
    - source: salt://confluence/templates/setenv.sh.tmpl
    - user: {{ confluence.user }}
    - template: jinja
    - mode: 0644
    - listen_in:
      - module: confluence-restart

{{ confluence.prefix }}/confluence/lib/mysql-connector-java-{{ confluence.dbdriver_version }}-bin.jar:
  file.managed:
    - source: {{ confluence.prefix }}/confluence/mysql_driver/mysql-connector-java-{{ confluence.dbdriver_version }}/mysql-connector-java-{{ confluence.dbdriver_version }}-bin.jar
    - user: {{ confluence.user }}
    - watch_in:
      - module: confluence-restart

/etc/fstab:
  file.managed:
    - source: salt://confluence/templates/fstab.tmpl
    - user: root
    - template: jinja
    - mode: 0644
    - context:
      confluence: {{ confluence|json }}

/opt/sumologic/sumocollector/sources/confluence.json:
  file.serialize:
    - user: {{ confluence.user }}
    - formatter: json
    - dataset:
        "api.version": "v1"
        source:
          sourceType: LocalFile
          name: Confluence
          pathExpression: "{{ confluence.prefix }}/confluence/logs/catalina.out"

# Get the cluster
{% set cluster = salt['grains.get']('ec2_tags:cluster') %}
{% if salt['grains.get']('ec2_tags:cluster') == 'production' %}
  {% set cluster = 'prod' %}
{% elif salt['grains.get']('ec2_tags:cluster') == 'devtools' %}
  {% set cluster = 'dev' %}
{% endif %}

# Get the application
{% set app = salt['grains.get']('ec2_tags:application') %}
{% if salt['grains.get']('ec2_tags:application') == 'mongodb' %}
  {% set app = 'cluster/mongo' %}
{% endif %}

          # Set the sourceCategory
          category: "{{cluster}}/{{app}}/confluence"
