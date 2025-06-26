FROM debian

# 解决中文乱码
ENV LANG=C.UTF-8

# 以root用户安装软件
USER root

# copy frp, port-proxy, 用于内网穿透和内网端口代理
ADD ./frp /usr/local/bin/

RUN DEBIAN_FRONTEND="noninteractive" apt-get update -y \
    && apt-get install --yes \
    curl \
    zsh \
    sudo \
    less \
    systemd \
    vim \
    htop \
    lsof \ 
    sqlite3

# change default shell to zsh


# 安装 多版本 node lts 14 16
RUN curl -fsSL -o /usr/local/bin/n https://raw.githubusercontent.com/tj/n/master/bin/n \
    && chmod 0755 /usr/local/bin/n \
    && n install 22

# 安装 code-server
# RUN npm install -g npm@^8
# RUN npm config set python python3
# RUN npm config set registry https://registry.npmmirror.com
# RUN yarn config set registry https://registry.npmmirror.com

# RUN npm i -g yarn
# RUN npm i -g code-server@4.101.2
# RUN yarn cache clean

# 安装 code-server
RUN curl -fsSL https://github.com/coder/code-server/releases/download/v4.101.2/code-server-4.101.2-linux-amd64.tar.gz -o code-server-4.101.2-linux-amd64.tar.gz \
    && tar -xzf code-server-4.101.2-linux-amd64.tar.gz \
    && mv code-server-4.101.2-linux-amd64 /usr/local/code-server \
    && ln -f /usr/local/code-server/bin/code-server /usr/local/bin/code-server \
    && rm -rf code-server-4.101.2-linux-amd64.tar.gz code-server-4.101.2-linux-amd64


RUN DEBIAN_FRONTEND="noninteractive" apt-get update -y \
    && apt-get install --yes \
    git  

# 添加用户 coder
RUN groupadd --gid 1001 coder \
  && useradd --uid 1001 --gid coder --shell /bin/zsh --create-home coder \
  && echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

# 修改file watch max count
# RUN chmod +w /etc/sysctl.conf && echo fs.inotify.max_user_watches=524288 >> /etc/sysctl.conf
# RUN chmod +w /etc/sysctl.conf && echo fs.inotify.max_user_watches=52800 >> /etc/sysctl.conf && chmod -w /etc/sysctl.conf


# 切换到 coder
USER coder

WORKDIR /home/coder

# 安装 ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 安装 vscode 插件
RUN code-server --install-extension TabNine.tabnine-vscode \
    && code-server --install-extension esbenp.prettier-vscode \
    && code-server --install-extension eamodio.gitlens  \
    && code-server --install-extension donjayamanne.githistory \
    && code-server --install-extension yzhang.markdown-all-in-one \
    && code-server --install-extension GitHub.github-vscode-theme

# 配置 PATH 环境变量
ENV PATH="/home/coder/.yarn/bin:$PATH"

# 配置npm私服
RUN yarn config set registry https://npmmirror.rd.chanjet.com \
    && npm config set registry https://npmmirror.rd.chanjet.com

# 安装 cjet工具集
# RUN yarn global add @chanjet/cjet-cmd \
#    @chanjet/cjet-proxy \
#    @chanjet/cjet

# # 安装 mdf-cli
# RUN yarn global add @chanjet/chanjet-mdf-cli

# # 安装 mdf vscode 插件
# RUN code-server --install-extension Chanjet.chanjet-mdf-vsdesigner
