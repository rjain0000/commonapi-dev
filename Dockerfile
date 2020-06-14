FROM gcc:9

RUN apt-get update && \
      apt-get -y install sudo

RUN useradd -u 501 -g dialout -ms /bin/bash rahul

RUN adduser rahul sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN sudo apt-get install -y cmake zlib1g-dev libdbus-glib-1-dev






USER rahul
WORKDIR /home/rahul

RUN git clone --branch v2.18.4  https://github.com/GENIVI/dlt-daemon.git 
RUN mkdir -p dlt-daemon/build
WORKDIR /home/rahul/dlt-daemon/build
RUN cmake ..
RUN make
RUN sudo make install
# optional: sudo ldconfig



WORKDIR /home/rahul/
RUN git clone https://github.com/GENIVI/capicxx-core-runtime.git
RUN mkdir -p capicxx-core-runtime/build
WORKDIR /home/rahul/capicxx-core-runtime/build
RUN cmake -D CMAKE_INSTALL_PREFIX=/usr/local ..
RUN make
RUN sudo make install

WORKDIR /home/rahul/
RUN git clone https://github.com/GENIVI/capicxx-dbus-runtime.git


RUN wget http://dbus.freedesktop.org/releases/dbus/dbus-1.13.6.tar.gz
RUN tar -xzf dbus-1.13.6.tar.gz
WORKDIR /home/rahul/dbus-1.13.6

RUN patch -t -p1 < ../capicxx-dbus-runtime/src/dbus-patches/capi-dbus-correct-dbus-connection-block-pending-call.patch
RUN patch -t -p1 < ../capicxx-dbus-runtime/src/dbus-patches/capi-dbus-block-acquire-io-path-on-send.patch
RUN patch -t -p1 < ../capicxx-dbus-runtime/src/dbus-patches/capi-dbus-add-send-with-reply-set-notify.patch
RUN patch -t -p1 < ../capicxx-dbus-runtime/src/dbus-patches/capi-dbus-send-with-reply-and-block-delete-reply-on-error.patch
RUN patch -t -p1 < ../capicxx-dbus-runtime/src/dbus-patches/capi-dbus-1-pc.patch
RUN patch -t -p1 < ../capicxx-dbus-runtime/src/dbus-patches/capi-dbus-add-support-for-custom-marshalling.patch
RUN ./configure
RUN make -C dbus 
RUN sudo make -C dbus install
RUN sudo make install-pkgconfigDATA

RUN mkdir -p /home/rahul/capicxx-dbus-runtime/build
WORKDIR /home/rahul/capicxx-dbus-runtime/build
RUN cmake -D USE_INSTALLED_COMMONAPI=ON -D CMAKE_INSTALL_PREFIX=/usr/local ..
RUN make
RUN sudo make install


WORKDIR /home/rahul/ws

