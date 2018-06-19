FROM mtgupf/essentia:ubuntu16.04-python3

RUN apt-get update && apt-get install --no-install-recommends -y \
        zlib1g-dev automake autoconf libtool subversion libatlas3-base \
        libatlas-base-dev git build-essential wget python\
        python-setuptools python3-setuptools python3-pip \
    && git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /tmp/kaldi \
    && cd /tmp/kaldi/tools \
    && make -j$(nproc) \
    && mkdir -p /opt/kaldi/bin /opt/kaldi/lib /opt/kaldi/include \
    && mv openfst/bin/* sctk/bin/* sph2pipe*/sph2pipe /opt/kaldi/bin \
    && mv openfst/lib/* /opt/kaldi/lib \
    && mv openfst/include/* /opt/kaldi/include \
    && rmdir openfst/lib openfst/include \
    && ln -s /opt/kaldi/lib openfst/lib \
    && ln -s /opt/kaldi/include openfst/include \
    && cd ../src \
    && ./configure --shared \
    && sed 's|\( -g # -O0.*\)| -O3 -DNDEBUG #\1|' -i~ kaldi.mk \
    && make depend -j$(nproc) \
    && make -j$(nproc) \
    && for f in $(find . -type f -executable | grep -F bin/); do echo $f $(file $f); done | grep 'ELF 64-bit LSB executable' | sed 's| .*||' | xargs mv -t /opt/kaldi/bin \
    && mv $(realpath lib/*) /opt/kaldi/lib \
    && cd \
    && rm -rf /tmp/kaldi \
    && apt-get purge -y \
        ca-certificates \
        build-essential \
        git \
        subversion \
        zlib1g-dev \
        automake \
        autoconf \
        wget \
        libtool \
        python \
        python3

ENV PATH="/opt/kaldi/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/kaldi/lib:${LD_DIBRARY_PATH}"

ADD kaldi_script /opt/kaldi/scripts

ENTRYPOINT ["/bin/bash", "-c"]