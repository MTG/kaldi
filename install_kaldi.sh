#!/bin/sh -ex
git clone --depth 1 https://github.com/kaldi-asr/kaldi.git /tmp/kaldi
cd /tmp/kaldi/tools
# TODO: This installs a number of packages needed for building, but should be removed again for the final image
./extras/install_mkl.sh
make -j$(nproc)
mkdir -p /opt/kaldi/bin /opt/kaldi/lib /opt/kaldi/include
cp -r openfst/bin/* sctk/bin/* sph2pipe*/sph2pipe /opt/kaldi/bin
cp -r openfst/lib/* /opt/kaldi/lib
cp -r openfst/include/* /opt/kaldi/include
rm -rf openfst/lib openfst/include
ln -s /opt/kaldi/lib openfst/lib
ln -s /opt/kaldi/include openfst/include
cd ../src
./configure --debug-level=0 --shared
# TODO: In recent kaldi, this doesn't work. By default it compiles -O1 -g. We can set NDEBUG with --debug-level=0
# sed 's|\( -g # -O0.*\)| -O3 -DNDEBUG #\1|' -i~ kaldi.mk
make depend -j$(nproc)
make -j$(nproc)
find bin/ -type f -executable -exec mv -t /opt/kaldi/bin {} +
mv $(realpath lib/*) /opt/kaldi/lib
cd /root
rm -rf /tmp/kaldi
# Clean up after intel mkl installation
# TODO: This package might change name as kaldi updates
apt-get -y remove intel-mkl-64bit-2020.0-088 && apt-get -y autoremove