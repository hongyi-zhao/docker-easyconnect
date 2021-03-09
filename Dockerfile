#For vpn.nxu.edu.cn, the `7.6.7` will cause the problem of the EasyConnect client version does not match the server.
# EC_VER=7.6.3  # 此变量填写 ec_urls 文件夹中的版本，`7.6.3`或`7.6.7`
#$ export EC_VER=7.6.3; docker build --network host --build-arg EC_URL=$(cat ec_urls/${EC_VER}.txt) --tag hongyi-zhao/docker-easyconnect -f Dockerfile .

FROM debian:buster
        
RUN sed -ri '/^deb( |-src )/d' /etc/apt/sources.list && \
    echo 'deb http://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free' > /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ buster main contrib non-free' >> /etc/apt/sources.list && \
    apt-get update
    # Considering that I only have the http proxy converted from socks5, don't use https transport.
    #apt-get install -y --no-install-recommends --no-install-suggests apt-transport-https apt-utils ca-certificates software-properties-common gnupg-agent && \
    #sed -ri 's/^(deb( |-src )http):/\1s:/' /etc/apt/sources.list && \ 
    #apt-get update && \
#RUN apt-get install -y --no-install-recommends --no-install-suggests curl \
#        libcanberra-gtk-module libgtk2.0-0 libx11-xcb1 libxtst6 libnss3 libasound2 libdbus-glib-1-2 iptables xclip \
#        dante-server tigervnc-standalone-server tigervnc-common psmisc flwm x11-utils 
#        

# Install more tools to facilitate debugging       
RUN env DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386 && apt-get update
RUN env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --no-install-suggests systemd systemd-sysv iproute2 iptables \
    iputils-ping iputils-tracepath dnsutils net-tools netcat socat haproxy \
    gcc make cmake git curl gawk uuid apt-file bash-completion \
    gdebi synaptic equivs unrar lsb-release apt-utils apt-transport-https openssh-server openssh-client filezilla \
    xfonts-wqy fonts-wqy-microhei fonts-wqy-zenhei nano gedit gedit-plugins vim xclip xsel \
    libcanberra-gtk-module libgtk2.0-0 libx11-xcb1 libxtst6 libnss3 libasound2 libdbus-glib-1-2 iptables xclip \
    dante-server tigervnc-standalone-server tigervnc-common psmisc flwm x11-utils 

ARG EC_URL

RUN cd tmp &&\
    curl -x socks5://127.0.0.1:18888 "${EC_URL}" -o EasyConnect.deb &&\
    dpkg -i EasyConnect.deb && rm EasyConnect.deb

COPY ./docker-root /

RUN rm -f /usr/share/sangfor/EasyConnect/resources/conf/easy_connect.json &&\
    mv /usr/share/sangfor/EasyConnect/resources/conf/ /usr/share/sangfor/EasyConnect/resources/conf_backup &&\
    ln -s /root/conf /usr/share/sangfor/EasyConnect/resources/conf

#ENV TYPE="" PASSWORD="" LOOP=""
#ENV DISPLAY

VOLUME /root/ /usr/share/sangfor/EasyConnect/resources/logs/

CMD ["start.sh"]
