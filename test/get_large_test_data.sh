#!/bin/bash
# stop on errors
set -o errexit

wget -O SAMN02599008.tar.gz  https://osf.io/6ma8p/download
tar xvf SAMN02599008.tar.gz 

wget -O SAMEA6634591.tar.gz  https://osf.io/4tqxc/download
tar xvf SAMEA6634591.tar.gz
