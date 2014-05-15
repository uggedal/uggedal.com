FROM uggedal/alpine
MAINTAINER Eivind Uggedal <eivind@uggedal.com>

RUN apk -U add git make py-pygments py-hoedown

ADD nginx.conf /etc/nginx/conf.d/uggedal.com.conf
ADD poll /usr/bin/poll

CMD ["https://github.com/uggedal/uggedal.com.git", "/var/www/uggedal.com"]
ENTRYPOINT ["poll"]
