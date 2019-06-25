#!/bin/bash
export MODULE_PATH=$1

cd $MODULE_PATH
mkdir -p archive
cd archive

#install pip requirements
pip install -r $2 --target .

#copy source to archive directory
cp -a $3 .
