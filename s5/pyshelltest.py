#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket  
import sys
import os
import subprocess


ret = subprocess.Popen("./sod-api.sh /home/dgk/sodwp/T0_1.wav fff", stdout=subprocess.PIPE, shell=True).stdout.read()
print '\n'
print ret 
        
  
