FROM ubuntu

EXPOSE 27015/udp
VOLUME ["/home/container/rocket/unturned/Servers/"]

RUN useradd -m -d /home/container container
RUN apt-get update && apt-get install -y apt-utils cron ca-certificates lib32gcc1 unzip net-tools lib32stdc++6 lib32z1 lib32z1-dev curl wget screen tmux libmono-cil-dev mono-runtime

RUN mkdir -p /home/container/rocket/steamcmd
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
RUN tar -xzvf steamcmd_linux.tar.gz
RUN mkdir -p /home/container/rocket/unturned

ADD bash/start.sh /home/container/rocket/start.sh
RUN chmod a+x /home/container/rocket/start.sh
RUN (crontab -l ; echo "* * * * * /home/container/rocket/steamcmd/start.sh rocket") | sort - | uniq - | crontab -

ADD bash/update.sh /home/container/rocket/update.sh
RUN chmod a+x /home/container/rocket/update.sh
RUN (crontab -l ; echo "@daily /home/container/rocket/steamcmd/update.sh") | sort - | uniq - | crontab -

ADD credentials/STEAM_USERNAME /root/.steam_user
ADD credentials/STEAM_PASSWORD /root/.steam_pass
ADD credentials/ROCKET_API_KEY /root/.rocket_id

COPY        ./bash/update.sh /update.sh
COPY        ./bash/start.sh  /start.sh
CMD         ["/bin/bash", "/update.sh"]
