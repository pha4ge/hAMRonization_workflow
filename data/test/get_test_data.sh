#!/bin/bash
# stop on errors
set -o errexit

wget -O SAMN02599008.tar.gz  https://osf.io/ghpcn/download 
tar xvf SAMN02599008.tar.gz 
