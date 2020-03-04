#!/bin/bash

# install the amrplusplus tools not in any system
git clone https://github.com/cdeanj/snpfinder
cd snpfinder
make
cd ..
git clone https://github.com/cdeanj/rarefactionanalyzer
cd rarefactionanalyzer
make
cd ..
git clone https://github.com/cdeanj/resistomeanalyzer
cd resistomeanalyzer
make
cd ..

# install c-sstar
git clone https://github.com/chrisgulvik/c-SSTAR

# install pointfinder
git clone https://bitbucket.org/genomicepidemiology/pointfinder.git --recursive
