#
# Dockerfile for Zoom
#

FROM ubuntu:16.04

MAINTAINER Herb Lainchbury <herb@dynamic-solutions.com>


RUN apt-get update

# install python3.6
WORKDIR /tmp
RUN apt-get install -y wget
RUN apt-get install -y build-essential
RUN apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
RUN wget https://www.python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz
RUN tar xvf Python-3.6.3.tar.xz
RUN cd Python-3.6.3 && ./configure && make altinstall

# install os packages
RUN apt-get -y install git vim
RUN apt-get -y install python3-pip

# update pip3
RUN pip3.6 install --upgrade pip

# install zoom
RUN mkdir /work
WORKDIR /work
RUN git clone https://github.com/dsilabs/zoom.git
RUN pip3.6 install -r zoom/requirements.txt
RUN echo /work/zoom > zoom.pth
RUN mv zoom.pth /usr/local/lib/python3.6/site-packages
RUN chmod +x zoom/tools/zoom/zoom
RUN ln -s /work/zoom/tools/zoom/zoom /usr/local/bin/zoom

# setup a default instance
RUN cp -r /work/zoom/web /work/web
RUN rm -rf /work/web/apps
RUN rm -rf /work/web/sites/localhost

# install uwsgi
RUN pip3.6 install uwsgi
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

