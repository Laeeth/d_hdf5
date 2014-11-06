#!/bin/bash

cat C/H5pubconf.h | sed -e 's/#define \([A-Z0-9_]*\) \(.*\)/enum \1 = \2;/'

