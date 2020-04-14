#!/bin/sh -e
git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /tmp/kaldi
cd /tmp/kaldi/tools
make -j$(nproc)
mkdir -p /opt/kaldi/bin /opt/kaldi/lib /opt/kaldi/include
mv openfst/bin/* sctk/bin/* sph2pipe*/sph2pipe /opt/kaldi/bin
mv openfst/lib/* /opt/kaldi/lib
mv openfst/include/* /opt/kaldi/include
rmdir openfst/lib openfst/include
ln -s /opt/kaldi/lib openfst/lib
ln -s /opt/kaldi/include openfst/include
cd ../src
./configure --shared
sed 's|\( -g # -O0.*\)| -O3 -DNDEBUG #\1|' -i~ kaldi.mk
make depend -j$(nproc)
make -j$(nproc)
for f in $(find . -type f -executable | grep -F bin/); do echo $f $(file $f); done | grep 'ELF 64-bit LSB executable' | sed 's| .*||' | xargs mv -t /opt/kaldi/bin
mv $(realpath lib/*) /opt/kaldi/lib
cd /root
rm -rf /tmp/kaldi
