#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket  
import sys

def runrun(pa, pb, pc):
    address = ('localhost', 30001)  
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
    s.connect(address)  
  
    data = '"' + pa + '" "' + pb + '" "' + pc  +'"\n'  #must \n with daemon with \n needed
    print 'send', data

    #s.send(data)
    while data:
        n = s.send(data)    
        data = data[n:]
    #s.flush()
    print 'send done'

    ret = s.recv(512)
    print 'recv', ret

    s.close()
    

if __name__ == "__main__":
    usage = '''./latgen-faster-mapped-daemon-api.py  "ark:$dir/netout.1.ar" "ark:|gzip -c > $dir/lat.JOB.gz" '''

    if len(sys.argv) != 4:
        print usage
        exit()

    runrun(sys.argv[1], sys.argv[2], sys.argv[3])
        
  
