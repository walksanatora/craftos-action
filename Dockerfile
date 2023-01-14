#image that allows me to avoid having to download things twice
FROM archlinux:base-devel-20230108.0.116909 AS ccpc
RUN pacman-key --init
RUN pacman -Sy archlinux-keyring --noconfirm
RUN pacman -S --needed base-devel git --noconfirm

#setup the nobody user directory
RUN echo "nobody ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chsh nobody --shell "/bin/bash"
RUN chown -R nobody:nobody /root
#RUN chmod -R 774 /root

#ROM image package, though this will be overwritten, i should remove it from the patched pkgbuild
WORKDIR /root
RUN pacman -Syw sdl2 poco --noconfirm
RUN git clone https://aur.archlinux.org/craftos-pc-data-git.git
WORKDIR craftos-pc-data-git
RUN chown -R nobody:nobody .
RUN su nobody -c "makepkg -si --noconfirm"

#modified CraftOS-PC pkgbuild
WORKDIR /root
RUN mkdir craftos-pc-git
WORKDIR craftos-pc-git
COPY ccpc.pkgbuild PKGBUILD
RUN chown -R nobody:nobody .
RUN su nobody -c "makepkg -si --noconfirm"

#WORKDIR /
#ENTRYPOINT [ "bash" ]

FROM archlinux:base-20230108.0.116909 AS main
WORKDIR /root

#Copy built packages over from ccpc
COPY --from=ccpc /var/cache/pacman/pkg/sdl2-*.zst .
COPY --from=ccpc /var/cache/pacman/pkg/poco-*.zst .
COPY --from=ccpc /root/craftos-pc-git/craftos-pc-git-*.zst .
COPY --from=ccpc /root/craftos-pc-data-git/craftos-pc-data-git-*.zst .


#install the packages
RUN pacman-key --init
RUN pacman -Sy archlinux-keyring --noconfirm
RUN pacman -U * --noconfirm

#install the files
COPY main.sh /main.sh
RUN rm -rf /usr/share/craftos
COPY craftos2-rom-CI /usr/share/craftos
ENTRYPOINT ["/main.sh"]