#build rom image
FROM alpine:3 as rom
RUN apk add git nodejs
WORKDIR /

#build rom
RUN git clone https://github.com/MCJack123/craftos2-rom/
WORKDIR /craftos2-rom
RUN wget https://raw.githubusercontent.com/MCJack123/craftos2/master/resources/packStandaloneROM.js
RUN node packStandaloneROM.js

#build craftos
FROM alpine:3 as craftos
RUN apk add git gcc make poco-dev sdl2-dev musl-dev
WORKDIR /
RUN git clone --recursive https://github.com/MCJack123/craftos2
WORKDIR /craftos2
RUN make -C craftos2-lua linux "-j$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')"
#COPY --from=rom /craftos2-rom/fs_standalone.cpp /rom.cpp
#RUN ./configure --without-png\
#    --without-webp\
#    --without-hpdf\
#    --with-txt\
#    --without-sdl_mixer\
#    --without-ncurses\
#    --with-standalone-rom=/rom.cpp
#RUN make "-j$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')"
#RUN chmod +x craftos

#the actuall CI
#FROM alpine:3 as main
#COPY --from=craftos /craftos2/craftos /bin/craftos
#COPY main.sh /main.sh
#ENTRYPOINT ["/main.sh"]