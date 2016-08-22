FROM centos:latest
RUN yum update -y && \

    `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
    yum install -y yum-utils wget patch gcc mysql vim tar git epel-release bzip2 httpd unzip openssh-clients rsync sudo openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel make && \

    `# grant all on apache user ` \
    usermod -u 1000 apache && \
    groupmod -g 1000 apache && \

    `# install ruby ` \
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
    source ~/.bashrc && \
    rbenv --version && \
    echo 'rbenv installed.' && \

    rbenv install 2.3.0 && \
    rbenv global 2.3.0 && \
    ruby -v && \
    echo 'ruby installed.' && \

    `# To avoid error: sudo: sorry, you must have a tty to run sudo  https://hub.docker.com/r/liubin/fluentd-agent/~/dockerfile/` \
    sed -i -e "s/Defaults    requiretty.*/ #Defaults    requiretty/g" /etc/sudoers && \
    wget -qO- https://toolbelt.heroku.com/install.sh | sh && \
    echo 'PATH="/usr/local/heroku/bin:$PATH"' >> ~/.zshrc && \
    source ~/.zshrc && \
    heroku version && \
    echo 'heroku installed.'

WORKDIR /var/www/html/
COPY ./httpd.conf /etc/httpd/conf/httpd.conf
EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
