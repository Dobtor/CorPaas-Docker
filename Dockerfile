FROM dobtorsi/odoo:11.0
MAINTAINER Ryan <support@dobtor.com>

USER root

# Generate locale (es_US for right odoo es_US language config, and C.UTF-8 for postgres and general locale data)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y locales -qq
RUN echo 'es_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'C.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN dpkg-reconfigure locales && /usr/sbin/update-locale LANG=es_US.UTF-8
ENV LANG es_US.UTF-8
ENV LANGUAGE es_US.UTF-8
ENV LC_ALL es_US.UTF-8

# Install some deps
RUN apt-get update
RUN apt-get install -y python-pip git wget

# Workers and longpolling dependencies
RUN apt-get install -y python-gevent
RUN pip install psycogreen

# update pip and install setuptools (required for intalling pip requirements)
RUN pip install --upgrade pip
RUN pip install --upgrade setuptools

## Install pip dependencies for adhoc used odoo repositories

# used by many pip packages
RUN apt-get install -y python-dev

# odoo-extra
RUN apt-get install -y python-matplotlib font-manager

# adhoc-website
RUN pip install mercadopago

# odoo argentina (nuevo modulo de FE)
RUN apt-get install -y swig build-essential libffi-dev libssl-dev python-m2crypto python-httplib2 mercurial
RUN pip install geopy==0.95.1
RUN pip install BeautifulSoup
RUN pip install pyOpenSSL
RUN pip install suds
# para pyafipws
RUN pip install -r https://raw.githubusercontent.com/reingart/pyafipws/master/requirements.txt
RUN pip install git+https://github.com/reingart/pyafipws@master
RUN chmod 777 -R /usr/local/lib/python2.7/dist-packages/pyafipws/

# openupgradelib para varios modulos de oca y luego propios
RUN pip install openupgradelib

# odoo etl, infra and others
RUN apt-get install -y python-simplejson
RUN pip install fabric
RUN pip install erppeek
RUN pip install fabtools

# new infra (esto nos fuerza la instalacion de httplib2 0.10.3 que no funciona con pyafipws, por ahora no lo estamos usando tampoco)
#RUN pip install google-api-python-client

# oca reports
RUN pip install xlwt

# odoo kineses
RUN pip install xlrd

# oca partner contacts
RUN pip install unicodecsv

# oca telephony
RUN pip install phonenumbers
RUN pip install py-Asterisk

# aeroo direct print
RUN apt-get install -y libcups2-dev
RUN pip install git+https://github.com/aeroo/aeroolib.git@master
RUN pip install pycups==1.9.68

# akretion/odoo-usability
RUN pip install BeautifulSoup4

# OCA server-tools
RUN pip install validate_email

# OCA knowledge
RUN pip install python-magic

# odoo support
RUN pip install erppeek

# Remote backup
RUN pip install pysftp

# System Mointor
RUN apt-get install htop

# Fonts
RUN apt-get -y install fontconfig xfonts-utils
RUN wget http://downloads.sourceforge.net/wqy/wqy-zenhei-0.8.38-1.deb
RUN dpkg -i wqy-zenhei-0.8.38-1.deb
RUN fc-list | grep WenQuanYi
RUN rm wqy-zenhei-0.8.38-1.deb

# WeChat
RUN pip install pycrypto
RUN pip install xmltodict
RUN pip install optionaldict


## Clean apt-get (copied from odoo)
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make auto_install = False for various modules

#RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python3/dist-packages/odoo/addons/base_import/__manifest__.py

#RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python3/dist-packages/odoo/addons/portal/__manifest__.py

USER odoo
