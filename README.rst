======
confluence
======

Formulas to set up and configure Atlassian Confluence.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``confluence``
----------

Installs the confluence standalone tarball and starts the service.  Configures
~confluence/dbconfig.xml, but assumes database creation handled by another forumla
(e.g. postgres-formula).  

``confluence.proxy``
------------------

Enables a basic Apache proxy for confluence.
