FROM mtgupf/essentia:ubuntu16.04-python3

WORKDIR /tmp
ADD install_kaldi.sh .

RUN apt-get update && apt-get install --no-install-recommends -y \
        zlib1g-dev automake autoconf libtool subversion libatlas3-base \
        libatlas-base-dev build-essential wget python\
        python-setuptools python3-setuptools python3-pip \
    && sh install_kaldi.sh \
    && apt-get purge -y ca-certificates build-essential subversion \
        zlib1g-dev automake autoconf wget libtool python \
    && rm -rf /var/lib/apt/lists/*

# Rong-specific requirement for scripts taken from examples directory
RUN mkdir -p /opt/kaldi/tools/config && touch /opt/kaldi/tools/config/common_path.sh

ENV PATH="/opt/kaldi/bin:${PATH}"
ENV LD_LIBRARY_PATH="/opt/kaldi/lib:${LD_DIBRARY_PATH}"

ADD kaldi_script /opt/kaldi/scripts
