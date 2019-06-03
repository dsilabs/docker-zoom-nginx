#
# Dockerfile for Zoom under nginx and uwsgi
#

FROM ubuntu:16.04

MAINTAINER Herb Lainchbury <herb@dynamic-solutions.com>


RUN apt-get update

# install python3.7
WORKDIR /tmp
RUN apt-get update -y -qq
RUN apt-get install -y -q wget
RUN apt-get install -y -q build-essential checkinstall
RUN apt-get install -y -q libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev zlib1g-dev openssl libffi-dev python3-dev python3-setuptools
RUN wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz
RUN tar xvf Python-3.7.3.tar.xz
RUN cd Python-3.7.3 && ./configure && make altinstall

# install os packages
RUN apt-get update -y -qq
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y python3-pip

# update pip3
RUN pip3.7 install --upgrade pip

# install zoom
RUN mkdir -p /work/libs
WORKDIR /work/libs
RUN git clone https://github.com/dsilabs/zoom.git
RUN pip3.7 install -r zoom/requirements.txt
RUN echo /work/libs/zoom > zoom.pth
RUN mv zoom.pth /usr/local/lib/python3.7/site-packages
RUN chmod +x zoom/bin/zoom
RUN ln -s /work/libs/zoom/bin/zoom /usr/local/bin/zoom

# setup a default instance
RUN cp -r /work/libs/zoom/web /work/web
RUN rm -rf /work/web/apps
RUN rm -rf /work/web/sites/localhost

# install uwsgi
RUN pip3.7 install uwsgi
RUN mkdir /work/uwsgi
ADD uwsgi.ini /work/uwsgi/uwsgi.ini

# install nginx
RUN apt-get install -y nginx
ADD uwsgi.conf /etc/nginx/conf.d/uwsgi.conf
ADD nginx.zoom /etc/nginx/sites-available/zoom
RUN ln -s /etc/nginx/sites-available/zoom /etc/nginx/sites-enabled/zoom
RUN rm /etc/nginx/sites-enabled/default

# install start script
ADD start.sh /work

# run the server
CMD ["/bin/bash", "start.sh"]

