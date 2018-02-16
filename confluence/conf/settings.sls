{% set p  = salt['pillar.get']('confluence', {}) %}
{% set g  = salt['grains.get']('confluence', {}) %}


{%- set default_version      = '6.4' %}
{%- set default_prefix       = '/opt' %}
{%- set default_source_url   = 'https://s3-us-west-2.amazonaws.com/salt-artifacts2' %}
{%- set default_dbdriver_url = 'https://dev.mysql.com/get/Downloads/Connector-J/' %}
{%- set default_log_root     = '/var/log/confluence' %}
{%- set default_attachments_root = '/mnt/attachments' %}
{%- set default_confluence_user    = 'confluence' %}
{%- set default_db_server    = 'localhost' %}
{%- set default_db_name      = 'confluence' %}
{%- set default_db_username  = 'confluence' %}
{%- set default_db_password  = 'confluence' %}
{%- set default_jks_password = 'changeit' %}
{%- set default_jvm_Xms      = '384m' %}
{%- set default_jvm_Xmx      = '768m' %}
{%- set default_jvm_MaxPermSize = '384m' %}
{%- set default_efs_home = 'localhost' %}
{%- set default_efs_opt = 'localhost' %}
{%- set default_ulimit = '8192' %}

{%- set version        = g.get('version', p.get('version', default_version)) %}
{%- set dbdriver_version = g.get('dbdriver_version', p.get('dbdriver_version', default_version)) %}
{%- set source_url     = g.get('source_url', p.get('source_url', default_source_url)) %}
{%- set dbdriver_url   = g.get('dbdriver_url', p.get('dbdriver_url', default_dbdriver_url)) %}
{%- set log_root       = g.get('log_root', p.get('log_root', default_log_root)) %}
{%- set attachments_root = g.get('attachments_root', p.get('attachments_root', default_attachments_root)) %}
{%- set prefix         = g.get('prefix', p.get('prefix', default_prefix)) %}
{%- set confluence_user = g.get('user', p.get('user', default_confluence_user)) %}
{%- set db_server      = g.get('db_server', p.get('db_server', default_db_server)) %}
{%- set db_name        = g.get('db_name', p.get('db_name', default_db_name)) %}
{%- set db_username    = g.get('db_username', p.get('db_username', default_db_username)) %}
{%- set db_password    = g.get('db_password', p.get('db_password', default_db_password)) %}
{%- set jks_password   = g.get('jks_password', p.get('jks_password', default_jks_password)) %}
{%- set jvm_Xms        = g.get('jvm_Xms', p.get('jvm_Xms', default_jvm_Xms)) %}
{%- set jvm_Xmx        = g.get('jvm_Xmx', p.get('jvm_Xmx', default_jvm_Xmx)) %}
{%- set jvm_MaxPermSize = g.get('jvm_MaxPermSize', p.get('jvm_MaxPermSize', default_jvm_MaxPermSize)) %}
{%- set efs_home       = g.get('efs_home', p.get('efs_home', default_efs_home)) %}
{%- set efs_opt        = g.get('efs_opt', p.get('efs_opt', default_efs_opt)) %}
{%- set ulimit         = g.get('ulimit', p.get('ulimit', default_ulimit)) %}

{%- set confluence_home  = salt['pillar.get']('users:%s:home' % confluence_user, '/home/confluence') %}

{%- set confluence = {} %}
{%- do confluence.update( { 'version'        : version,
                      'source_url'     : source_url,
                      'dbdriver_url'   : dbdriver_url,
                      'dbdriver_version': dbdriver_version,
                      'log_root'       : log_root,
                      'attachments_root' : attachments_root,
                      'home'           : confluence_home,
                      'prefix'         : prefix,
                      'user'           : confluence_user,
                      'db_server'      : db_server,
                      'db_name'        : db_name,
                      'db_username'    : db_username,
                      'db_password'    : db_password,
                      'jks_password'   : jks_password,
                      'jvm_Xms'        : jvm_Xms,
                      'jvm_Xmx'        : jvm_Xmx,
                      'jvm_MaxPermSize': jvm_MaxPermSize,
                      'efs_home'       : efs_home,
                      'efs_opt'        : efs_opt,
                      'ulimit'         : ulimit
                  }) %}

