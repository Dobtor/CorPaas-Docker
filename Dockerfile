# **基於 Odoo 18.0 官方映像**
FROM dobtorsi/odoo:18.0

MAINTAINER Ryan <support@dobtor.com>

USER root

# **更新 APT 並安裝必要的系統工具**
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y \
    software-properties-common \
    locales \
    wget \
    curl \
    build-essential \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-simplejson \
    libffi-dev \
    libssl-dev \
    mercurial \
    swig \
    htop \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-noto-color-emoji \
    fonts-noto-mono \
    gnupg lsb-release

# **安裝 PostgreSQL 18 Client（配合 Cloud SQL 版本）**
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y postgresql-client-18

# **設定語系**
RUN echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN echo 'C.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen
RUN dpkg-reconfigure locales && /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# **確認系統預設的 Python 版本**
RUN python3 --version

# **升級 pip（繞過 PEP 668 限制）**
RUN python3 -m pip install --upgrade setuptools --break-system-packages

# **安裝 Odoo 依賴的 Python 套件（繞過 PEP 668 限制）**
RUN pip3 install --break-system-packages \
    psycogreen mercadopago genshi py3o.template google-api-python-client \
    geopy pyOpenSSL fabric erppeek fabtools xlrd pycryptodome PyGitHub GitPython \
    sendgrid raven python-barcode zxcvbn ecpay_invoice3 openupgradelib \
    pathspec

# **安裝 Report Designer 相關工具**
RUN pip3 install genshi py3o.template --break-system-packages
RUN apt-get remove -y unoconv && apt-get -y autoremove && apt-get update && apt-get install -y unoconv

# **安裝額外的系統工具**
RUN apt-get install -y python3-matplotlib font-manager \
    libcups2-dev python3-gevent \
    cloc

# **安裝 Remote Backup**
# RUN pip install pysftp --break-system-packages

# **安裝 System Monitor**
RUN apt-get install -y htop

# **清理系統，減少 Docker 映像大小**
RUN apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# **切換回 Odoo 使用者**
USER odoo