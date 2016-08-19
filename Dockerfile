FROM centos:latest
MAINTAINER Takashi Kikuchi <kittaka.takashi@gmail.com>

#https://github.com/million12/docker-nginx-php/blob/master/Dockerfile を参考

RUN yum update -y && \

    `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
    yum install -y yum-utils wget patch vim tar git epel-release bzip2 httpd unzip openssh-clients rsync

RUN usermod -u 1000 apache && \
    groupmod -g 1000 apache

WORKDIR /var/www/html/
COPY ./httpd.conf /etc/httpd/conf/httpd.conf
EXPOSE 80
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
