#!/bin/bash
# stop on errors
set -o errexit

wget -O SAMN02599008.tar.gz  https://osf.io/6ma8p/download
tar xvf SAMN02599008.tar.gz 
