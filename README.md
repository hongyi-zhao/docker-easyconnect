# docker-easyconnect

让深信服开发的**非自由**的 EasyConnect 代理软件运行在 docker 中，并开放 Socks5 供宿主机连接以使用代理。

这个 image 基于 EasyConnect 官方“Linux”版的 deb 包。

[如何运行“Linux”版 EasyConnect (`7.6.3.0.86415`版) (doc/run-linux-easyconnect-how-to.md)](doc/run-linux-easyconnect-how-to.md)是这次折腾的总结。

另外如果希望使用全局代理，最直接的方式大概是使用`--net host -e NODANTED=1`参数，将虚拟机与宿主机置于同一网络环境。但个人不太推荐此种方式，经过折腾过后又写了[记折腾容器化 EasyConnect 的全局透明代理](https://hagb.name/2020/06/26/easyconnect-proxy.html)一文总结（但仍觉不甚方便，希望能有更好的方式）。

望批评、指正。欢迎提交 issue、PR，包括但不仅限于 bug、各种疑问、代码和文档（最近有点语无伦次）的改进。

## EasyConnect 版本

[`ec_urls`](ec_urls) 目录中以`版本号.txt`为文件名的文本文件保存了下载链接。（欢迎提交 issue 或 PR）

### 已经过测试的版本

`7.6.3`版（<http://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_01/EasyConnect_x64.deb>）.

### 待测试的版本（欢迎提交 issue 或 PR）

`7.6.7`版（<http://download.sangfor.com.cn/download/product/sslvpn/pkg/linux_767/EasyConnect_x64_7_6_7_3.deb>）.

### 其他

请通过设置下文叙述的`EC_URL`变量进行测试，欢迎提交 issue 或 PR.

## Pull or build

### 从 Docker Hub 上直接获取：

```
docker pull hagb/docker-easyconnect:TAG
```

其中 TAG 可以是如下值（不带 VNC 服务端的 image 比带 VNC 服务端的 image 小）：

- `latest`: 默认值，带 VNC 服务端的`7.6.3`版 image，
- `vncless`: 不带 VNC 服务端的`7.6.3`版 image
- `7.6.3`: 带 VNC 服务端的`7.6.3`版 image
- `vncless-7.6.3`: 不带 VNC 服务端的`7.6.3`版 image
- `7.6.7`: 带 VNC 服务端的`7.6.7`版 image
- `vncless-7.6.7`: 不带 VNC 服务端的`7.6.7`版 image

### 从 Dockerfile 构建

带 VNC 服务端：

```
git clone https://github.com/hagb/docker-easyconnect.git
cd docker-easyconnect
EC_VER=7.6.3  # 此变量填写 ec_urls 文件夹中的版本，`7.6.3`或`7.6.7`
docker image build --build-arg EC_URL=$(cat ec_urls/${EC_VER}.txt) --tag hagb/docker-easyconnect -f Dockerfile .
```

无 VNC 服务端：

```
git clone https://github.com/hagb/docker-easyconnect.git
cd docker-easyconnect
EC_VER=7.6.3  # 此变量填写 ec_urls 文件夹中的版本，`7.6.3`或`7.6.7`
docker image build --build-arg EC_URL=$(cat ec_urls/${EC_VER}.txt) --tag hagb/docker-easyconnect -f Dockerfile.vncless .
```

如果需要测试[`ec_urls`](ec_urls)目录中尚未包含的 EasyConnect 版本，可以将该版本的 deb 安装包下载地址写入到文本文件`ec_urls/版本号.txt`中，或者直接将地址赋予编译变量`EC_URL`（以上文为例则是用该地址替换`$(cat ec_urls/${EC_VER}.txt)`）

## Usage

**参数里的`--device /dev/net/tun --cap-add NET_ADMIN`是不可少的。** 因为 EasyConnect 要创建虚拟网络设备`tun0`。

### 环境变量

- `TYPE`（仅适用于带 vnc 的 image）: 如何显示 EasyConnect 前端（目前没有找到纯 cli 的办法）。有以下两种选项:

	- `x11`或`X11`: 将直接通过`DISPLAY`环境变量的值显示 EasyConnect 前端，请同时设置`DISPLAY`环境变量。

	- 其它任何值（默认值）: 将在`5901`端口开放 vnc 服务以操作 EasyConnect 前端。

- `DISPLAY`: `$TYPE`为`x11`或使用无 vnc 的 image 时通过该变量来显示 EasyConnect 界面。

- `PASSWORD`: 用于设置 vnc 服务的密码，该变量的值默认为空字符串，表示密码不作改变。变量不为空时，密码（应小于或等于 8 位）就会被更新到变量的值。默认密码是`password`.

- `URLWIN`: 默认为空，此时当 EasyConnect 想要调用浏览器时，不会弹窗，若该变量设为任何非空值，则会弹出一个包含链接文本框。

- `EXIT`: 默认为空，此时前端退出后会自动重启。不为空时，前端退出后不自动重启。

- `NODANTED`: 默认为空。不为空时提供 socks5 代理的`danted`将不会启动（可用于和`--net host`参数配合，提供全局透明代理）。

- `ECPASSWORD`: 默认为空，使用 vnc 时用于将密码放入粘帖板，应对密码复杂且无法保存的情况 (eg: 需要短信验证登陆)。

### Socks5

EasyConnect 创建`tun0`后，Socks5 代理会在容器的`1080`端口开启。这可用`-p`参数转发到`127.0.0.1`上。

### VNC 服务器

带 VNC 时，默认情况下，环境变量`TYPE`留空会在`5901`端口开启 VNC 服务器。

### 处理 EasyConnect 的浏览器弹窗

处理成将链接（追加）写入`/root/open-urls`，如果设置了`URLWIN`环境变量为非空值，还会弹出一个包含链接的文本框。

### 配置、登陆信息持久化

只需要用`-v`参数将宿主机的目录挂载到容器的 /root 。

如`-v $HOME/.ecdata:/root`。

由此还能实现全自动登陆。

## 例子

以下例子中，登录信息均保存在`~/.ecdata/`文件夹（`-v $HOME/.ecdata:/root`），开放的 Socks5 在`127.0.0.1:1080`（`-p 127.0.0.1:1080:1080`）。

### X11 socket

下面这个例子可以在当前桌面环境中启动 EasyConnect 前端，并且该前端退出后不会自动重启（`-e EXIT=1`），EasyConnect 要进行浏览器弹窗时会弹出含链接的文本框（`-e URLWIN=1`）。

```
xhost +LOCAL:
docker run --device /dev/net/tun --cap-add NET_ADMIN -ti -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/root/.Xauthority -e EXIT=1 -e DISPLAY=$DISPLAY -e URLWIN=1 -e TYPE=x11 -v $HOME/.ecdata:/root -p 127.0.0.1:1080:1080 hagb/docker-easyconnect
xhost -LOCAL:
```

### vnc 

下面这个例子中，前端退出会自动重启前端，VNC 服务器在`127.0.0.1:5901`（`-p 127.0.0.1:5901:5901`），密码为`xxxxxx`（`-e PASSWORD=xxxxxx`）。

```
docker run --device /dev/net/tun --cap-add NET_ADMIN -ti -e PASSWORD=xxxxxx -v $HOME/.ecdata:/root -p 127.0.0.1:5901:5901 -p 127.0.0.1:1080:1080 hagb/docker-easyconnect
```

## 已知问题

### `Failed to login in with this user account, for a user is online!`

该问题在`7.6.3`版上有出现，`7.6.7`版上未知。

有时登陆时卡一小会儿，然后弹出`Failed to login in with this user account, for a user is online!`的窗口，但实际上同一账号并没有其他客户端同时在线。点击`OK`后 EasyConnect 退出。

在 docker 命令行内临时删去设置`EXIT`环境变量的`-e EXIT=`参数（如果有），在弹窗发生后点击`OK`，使客户端重启，重启后问题消失。

### 无法显示中文

原因是 image 内无中文字体。可以通过修改 EasyConnect 前端的语言为英语来绕过中文显示的问题。也可以安装或挂载中文字体进容器中。

详见 [#2](https://github.com/Hagb/docker-easyconnect/issues/2)。

## 参考资料

登陆过程的一个 hack ([docker-root/usr/local/bin/start-sangfor.sh](docker-root/usr/local/bin/start-sangfor.sh))参考了这篇文章：<https://www.twblogs.net/a/5e65e6c4bd9eee211685b8cc>,<https://blog.51cto.com/13226459/2476193>。在此对该文作者表示感谢。

## 版权及许可证

> Copyright © 2020 contributors
>
> This work is free. You can redistribute it and/or modify it under the  
> terms of the Do What The Fuck You Want To Public License, Version 2,  
> as published by Sam Hocevar. See the COPYING file for more details. 

可以对这份东西做任何事情。

>        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE  
>                    Version 2, December 2004  
>
> Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>  
>
> Everyone is permitted to copy and distribute verbatim or modified  
> copies of this license document, and changing it is allowed as long  
> as the name is changed.  
>  
>            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE  
>   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION  
>  
>  0. You just DO WHAT THE FUCK YOU WANT TO. 
