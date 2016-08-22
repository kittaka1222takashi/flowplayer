FROM centos:latest
RUN yum update -y && \

    `# Install yum-utils (provides yum-config-manager) + some basic web-related tools...` \
    yum install -y yum-utils wget patch gcc mysql vim tar git epel-release bzip2 httpd unzip openssh-clients rsync sudo openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel make && \

    `# Install PHP 7.0 from Remi YUM repository...` \
    rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \

    yum install -y \
    php70-php \
    php70-php-bcmath \
    php70-php-cli \
    php70-php-common \
    php70-php-devel \
    php70-php-fpm \
    php70-php-gd \
    php70-php-gmp \
    php70-php-intl \
    php70-php-json \
    php70-php-mbstring \
    php70-php-mcrypt \
    php70-php-mysqlnd \
    php70-php-opcache \
    php70-php-pdo \
    php70-php-pear \
    php70-php-process \
    php70-php-pspell \
    php70-php-xml \

    `# Also install the following PECL packages:` \
    php70-php-pecl-imagick \
    php70-php-pecl-mysql \
    php70-php-pecl-uploadprogress \
    php70-php-pecl-uuid \
    php70-php-pecl-zip \

    `# Temporary workaround: one dependant package fails to install when building image (and the yum error is: Error unpacking rpm package httpd-2.4.6-40.el7.centos.x86_64)...` \
    || true && \

    `# Set PATH so it includes newest PHP and its aliases...` \
    ln -sfF /opt/remi/php70/enable /etc/profile.d/php70-paths.sh && \

    `# The above will set PATH when container starts... but not when php is used on container build time.` \
    `# Therefore create symlinks in /usr/local/bin for all PHP tools...` \
    ln -sfF /opt/remi/php70/root/usr/bin/{pear,pecl,phar,php,php-cgi,php-config,phpize} /usr/local/bin/. && \

    php --version && \

    `# Move PHP config files from /etc/opt/remi/php70/* to /etc/* ` \
    mv -f /etc/opt/remi/php70/php.ini /etc/php.ini && ln -s /etc/php.ini /etc/opt/remi/php70/php.ini && \
    rm -rf /etc/php.d && mv /etc/opt/remi/php70/php.d /etc/. && ln -s /etc/php.d /etc/opt/remi/php70/php.d && \

    echo 'PHP 7 installed.' && \

    `# install composer ` \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer && \
    `# install prestissimo (composer plugin) https://github.com/hirak/prestissimo  http://tech.mercari.com/entry/2016/02/01/164829` \
    composer global require "hirak/prestissimo:^0.3" && \
    echo 'composer installed.'&& \

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
