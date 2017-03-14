FROM ubuntu:15.10

VOLUME ["/home/container/rocket/unturned/Servers/"]

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

RUN apt-get update && apt-get install -y apt-utils cron ca-certificates lib32gcc1 unzip net-tools lib32stdc++6 lib32z1 lib32z1-dev curl wget screen tmux libmono-cil-dev mono-runtime

ADD ./start.sh /home/container/rocket/start.sh
RUN chmod a+x /home/container/rocket/start.sh
RUN (crontab -l ; echo "* * * * * /home/container/rocket/steamcmd/start.sh rocket") | sort - | uniq - | crontab -

RUN useradd -m -d /home/container container
USER container
ENV HOME=/home/container USER=container

WORKDIR /home/container

RUN mkdir -p /home/container/rocket/steamcmd
RUN mkdir -p /home/container/rocket/unturned

RUN cd steamcmd
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
RUN tar -xvzf steamcmd_linux.tar.gz
RUN rm steamcmd_linux.tar.gz
RUN ./steamcmd.sh +@sSteamCmdForcePlatformBitness 32 +login "$STEAM_USER" "$STEAM_PASS" +force_install_dir /unturned +app_update 304930 validate +exit

RUN mkdir .update_rocket
RUN cd .update_rocket
RUN wget "https://ci.rocketmod.net/job/Rocket.Unturned%20Linux/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip"
RUN unzip Rocket.zip
RUN mkdir -p steamcmd/unturned/Unturned_Headless_Data/Managed
RUN mv Modules/Rocket.Unturned/*.dll steamcmd/unturned/Unturned_Headless_Data/Managed/

RUN mv RocketLauncher.exe steamcmd/unturned

CMD         ["/bin/bash", "/start.sh"]
