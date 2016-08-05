#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket  
import sys

def runrun(pa, pb):
    address = ('localhost', 30001)  
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
    s.connect(address)  
  
    data = '"' + pa + '"' + ' ' + '"' + pb + '"\n'  #must \n with daemon with \n needed
    print 'send', data

    #s.send(data)
    while data:
        n = s.send(data)    
        data = data[n:]
    #s.flush()
    print 'send done'

    #ret = s.recv(512)
    #print 'recv', ret
    s.send("")
    s.close()
    

if __name__ == "__main__":
    usage = '''./latgen-faster-mapped-daemon-api.py  "ark:$dir/netout.1.ar" "ark:|gzip -c > $dir/lat.JOB.gz" '''

    if len(sys.argv) != 3:
        print usage
        exit()

    runrun(sys.argv[1], sys.argv[2])
        
  
