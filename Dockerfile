FROM alpine:3.16

RUN apk update \
    && apk add --virtual build-dependencies \
                                 build-base \
                                 gcc \
                                 wget \
                                 git \
                                 curl \
                                 zlib-dev \
                                 cmake \
                                 cargo \
                                 pcre-dev \
    && rm -rf /var/cache/apk/*

RUN curl -O https://nginx.org/download/nginx-1.16.1.tar.gz \
    && tar xzvf nginx-1.16.1.tar.gz \
    && git clone --recursive https://github.com/cloudflare/quiche \
    && cd nginx-1.16.1 \
    && patch -p01 < ../quiche/nginx/nginx-1.16.patch \
    && ./configure                                 \
       --prefix=$PWD                           \
       --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \
       --with-http_v3_module                   \
       --with-openssl=../quiche/quiche/deps/boringssl \
       --with-quiche=../quiche \
    &&   make

CMD ["nginx", "-g", "daemon off;"]
