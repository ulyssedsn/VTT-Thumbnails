FROM ruby:3.0.2-slim

RUN apt-get update -qq && apt-get -y install \
      autoconf \
      automake \
      build-essential \
      checkinstall \
      cmake \
      git-core \
      libass-dev \
      libfreetype6-dev \
      libgnutls28-dev \
      libsdl2-dev \
      libssl-dev \
      libtool \
      libva-dev \
      libvdpau-dev \
      libvorbis-dev \
      libxcb1-dev \
      libxcb-shm0-dev \
      libxcb-xfixes0-dev \
      meson \
      nasm \
      ninja-build \
      pkg-config \
      texinfo \
      wget \
      yasm \
      zlib1g-dev

RUN mkdir -p /usr/src/ffmpeg
WORKDIR /usr/src/ffmpeg
RUN git clone http://github.com/FFmpeg/FFmpeg.git . && \
    git reset 7bba0dd6382e30d646cb406034a66199e071d713 --hard

RUN   ./configure \
      --extra-libs="-ldl" \
      --disable-doc \
      --enable-gpl \
      --enable-nonfree \
      --enable-openssl \
      --enable-version3 && \
    make -j"$((`nproc`+1))" && \
    make install

ENV APP_HOME=/var/www/bumblebee \
    USERNAME=bumblebee \
    UID=1000
WORKDIR ${APP_HOME}

COPY . ${APP_HOME}

RUN bundle config --local without 'development test' && \
    bundle config --local path vendor/bundle && \
    bundle install --jobs 5 --quiet && \
    rm -rf ${APP_HOME}/tmp/* && \
    adduser -uid ${UID} ${USERNAME} && \
    chown -R ${UID} ${APP_HOME}

USER ${USERNAME}

CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb"]
