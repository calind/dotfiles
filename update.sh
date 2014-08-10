#!/bin/bash
git submodule foreach git pull origin master
git submodule foreach git submodule update --recursive
if [ -d vim/bundle/vimproc.vim ] ; then
    ( cd vim/bundle/vimproc.vim; \
        make clean; \
        make )
fi
