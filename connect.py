#!/usr/bin/env python3

import paramiko
import socket
import time

key = paramiko.rsakey.RSAKey.generate(2048)

while True:

    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(('localhost', 2222))

        transport = paramiko.Transport(sock)
        transport.connect()
        
        transport.auth_publickey('testuser', key)
        
        print('it worked!')
    except paramiko.ssh_exception.AuthenticationException:
        print('nope')
    except Exception as e:
        print(e)

    time.sleep(5)
