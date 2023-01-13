#image that allows me to avoid having to download things twice
FROM archlinux:base-devel-20230108.0.116909 as ccpc
RUN pacman-key --init
RUN pacman -Sy archlinux-keyring --noconfirm
RUN pacman -S --needed base-devel git --noconfirm

#setup the nobody user directory
RUN echo "nobody ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chsh nobody --shell "/bin/bash"
RUN chown -R root:nobody /root
RUN chmod -R 770 /root

#ROM image data
WORKDIR /root
RUN pacman -Sw sdl2 sdl2_mixer poco --noconfirm
RUN git clone https://aur.archlinux.org/craftos-pc-data-git.git
WORKDIR craftos-pc-data-git
RUN chown -R nobody:nobody .
RUN su nobody -c "makepkg -si --noconfirm"

#CraftOS-PC
WORKDIR /root
RUN git clone https://aur.archlinux.org/craftos-pc-git.git
WORKDIR craftos-pc-git
RUN chown -R nobody:nobody .
RUN su nobody -c "makepkg -si --noconfirm"

WORKDIR /root


FROM archlinux:base-20230108.0.116909 as core

WORKDIR /root
#Copy packages over
COPY --from=ccpc /var/cache/pacman/pkg/sdl2-*.zst .
COPY --from=ccpc /var/cache/pacman/pkg/sdl2_mixer-*.zst .
COPY --from=ccpc /var/cache/pacman/pkg/poco-*.zst .
COPY --from=ccpc /root/craftos-pc-git/craftos-pc-git-*.zst .
COPY --from=ccpc /root/craftos-pc-data-git/craftos-pc-data-git-*.zst .

RUN pacman-key --init
RUN pacman -Sy archlinux-keyring --noconfirm
RUN pacman -U * --noconfirm

COPY main.sh /main.sh
ENTRYPOINT [ "bash", "-c" ]
CMD ["/main.sh"]