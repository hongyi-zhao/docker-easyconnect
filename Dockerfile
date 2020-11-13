
#For vpn.nxu.edu.cn, the `7.6.7` will cause the problem of the EasyConnect client version does not match the server.
#EC_VER=7.6.3  # 此变量填写 ec_urls 文件夹中的版本，`7.6.3`或`7.6.7`
#docker build --network host --build-arg EC_URL=$(cat ec_urls/${EC_VER}.txt) --tag hongyi-zhao/docker-easyconnect -f Dockerfile .

FROM debian:buster-slim
        
RUN sed -ri '/^deb( |-src )/d' /etc/apt/sources.list && \
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free' > /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free' >> /etc/apt/sources.list && \
    apt-get update
    #apt-get install -y --no-install-recommends --no-install-suggests apt-transport-https apt-utils ca-certificates software-properties-common gnupg-agent && \
    #sed -ri 's/^(deb( |-src )http):/\1s:/' /etc/apt/sources.list && \ 
    #apt-get update && \
RUN apt-get install -y --no-install-recommends --no-install-suggests curl \
        libcanberra-gtk-module libgtk2.0-0 libx11-xcb1 libxtst6 libnss3 libasound2 libdbus-glib-1-2 iptables xclip \
        dante-server tigervnc-standalone-server tigervnc-common psmisc flwm x11-utils

ARG EC_URL

RUN cd tmp &&\
    curl -x socks5://127.0.0.1:18888 "${EC_URL}" -o EasyConnect.deb &&\
    dpkg -i EasyConnect.deb && rm EasyConnect.deb

COPY ./docker-root /

#ENV TYPE="" PASSWORD="" LOOP=""
#ENV DISPLAY

VOLUME /root/

CMD ["start.sh"]
