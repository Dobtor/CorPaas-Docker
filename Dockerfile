FROM dobtorsi/odoo:14.0
MAINTAINER Ryan <support@dobtor.com>

USER root

# Generate locale (en_US for right odoo en_US language config, and C.UTF-8 for postgres and general locale data)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y locales -qq
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'C.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN dpkg-reconfigure locales && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install some deps
RUN apt-get update
RUN python3 -m pip uninstall pip
RUN apt-get install -y python3-pip git wget


# Workers and longpolling dependencies
RUN apt-get install -y python3-gevent
RUN pip3 install psycogreen

# update pip and install setuptools (required for intalling pip requirements)
RUN pip3 install --upgrade pip
RUN pip3 install --upgrade setuptools

## Install pip dependencies for adhoc used odoo repositories

# used by many pip packages
RUN apt-get install -y python3-dev

# odoo-extra
RUN apt-get install -y python3-matplotlib font-manager

# adhoc-website
RUN pip3 install mercadopago

# odoo extra
RUN apt-get install -y swig build-essential libffi-dev libssl-dev mercurial
RUN pip3 install geopy
RUN pip3 install pyOpenSSL


# openupgradelib para varios modulos de oca y luego propios
#RUN pip3 install openupgradelib

# odoo etl, infra and others
RUN apt-get install -y python3-simplejson
RUN pip3 install fabric
RUN pip3 install erppeek
RUN pip3 install fabtools

# new infra (esto nos fuerza la instalacion de httplib2 0.10.3 que no funciona con pyafipws, por ahora no lo estamos usando tampoco)
RUN pip3 install pyasn1-modules
RUN pip3 install google-api-python-client

# oca reports
#RUN pip3 install xlwt

# odoo kineses
#RUN pip install xlrd

# oca partner contacts
#RUN pip install unicodecsv

# oca telephony
#RUN pip install phonenumbers
#RUN pip install py-Asterisk

# aeroo direct print
#RUN apt-get install -y libcups2-dev
#RUN pip install git+https://github.com/aeroo/aeroolib.git@master
#RUN pip install pycups==1.9.68

# akretion/odoo-usability
#RUN pip install BeautifulSoup4

# OCA server-tools
RUN pip3 install raven

# OCA knowledge
#RUN pip install python-magic

# OCA barcode
RUN pip3 install python-barcode

# ECpay invoice
RUN pip3 install ecpay_invoice3

# Remote backup

#RUN pip install pysftp

# System Mointor
RUN apt-get install htop

# Fonts
RUN apt-get -y install fontconfig xfonts-utils
RUN wget http://downloads.sourceforge.net/wqy/wqy-zenhei-0.8.38-1.deb
RUN dpkg -i wqy-zenhei-0.8.38-1.deb
RUN fc-list | grep WenQuanYi
RUN rm wqy-zenhei-0.8.38-1.deb

# WeChat
#RUN pip install pycrypto
RUN pip install xmltodict
#RUN pip install optionaldict

# Import
RUN pip install xlrd
RUN pip3 install pycryptodome
RUN pip install PyGitHub
RUN pip install GitPython

## Clean apt-get (copied from odoo)
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Make auto_install = False for various modules

#RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python3/dist-packages/odoo/addons/base_import/__manifest__.py

#RUN sed  -i  "s/'auto_install': True/'auto_install': False/" /usr/lib/python3/dist-packages/odoo/addons/portal/__manifest__.py

USER odoo
