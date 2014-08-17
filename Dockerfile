# This is a comment
# Inspirado em:
#   http://repositorio.interlegis.gov.br/il.spdo/trunk/docs/install-spdo.sh
#   https://github.com/gauthierc/Docker/blob/master/Plone/Dockerfile

FROM ubuntu:12.04
MAINTAINER Ramiro Batista da Luz <ramiroluz@gmail.com>

# base
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV INSTALL_DIR /var/interlegis/spdo
ENV DOWNLOAD_URL http://launchpad.net/plone/4.1/4.1.4/+download/Plone-4.1.4-UnifiedInstaller.tgz

RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales
RUN apt-get -qq update
RUN apt-get -y install build-essential git-core libfreetype6 libfreetype6-dev libjpeg62 libjpeg62-dev libmysqlclient-dev libreadline6 libreadline-dev libssl-dev mysql-client ssh subversion zlib1g zlib1g-dev wget python-software-properties

# supervisor
RUN apt-get install supervisor -y
RUN update-rc.d -f supervisor disable
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Plone 4.1.4 UnifiedInstaller
RUN mkdir -p $INSTALL_DIR/installer
RUN cd $INSTALL_DIR/installer; wget $DOWNLOAD_URL; tar -zxvf Plone-4.1.4-UnifiedInstaller.tgz
RUN cd $INSTALL_DIR/installer/Plone-4.1.4-UnifiedInstaller; ./install.sh --target=$INSTALL_DIR standalone
RUN rm -rf $INSTALL_DIR/installer

# SPDO
RUN cd $INSTALL_DIR/zinstance/src; svn co http://repositorio.interlegis.gov.br/il.spdo/trunk/ il.spdo
RUN ln -sf $INSTALL_DIR/zinstance/src/il.spdo/il/spdo/buildout/*.cfg $INSTALL_DIR/zinstance/
RUN cd $INSTALL_DIR/zinstance; ./bin/buildout -c develop.cfg

# SPDO mysql connection
ADD config.py $INSTALL_DIR/zinstance/src/il.spdo/il/spdo/config.py
ADD saconnections.xml $INSTALL_DIR/zinstance/src/il.spdo/il/spdo/profiles/default/saconnections.xml

RUN mkdir -p $INSTALL_DIR/anexos
RUN chown -R plone.plone $INSTALL_DIR/anexos

# start script
ADD startup /usr/local/bin/startup
RUN chmod +x /usr/local/bin/startup

CMD ["/usr/local/bin/startup"]

# SPDO port
EXPOSE 8380
