#!/usr/bin/env python3

import paramiko
import socket
import sys
import json
import multiprocessing
from multiprocessing.pool import ThreadPool

key = paramiko.rsakey.RSAKey.generate(2048)

socket.setdefaulttimeout(10)

def connect_to_host(ip, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect((ip, port))
        transport = paramiko.Transport(sock)
    except Exception as e:
        sock.close()
        return 'could_not_connect', str(e)

    try:
        transport.connect()
        r = transport.auth_publickey('root', key)
        if r:
            return 'requires_more_authentication', str(r)
        return 'key_accepted', None
    except paramiko.ssh_exception.BadAuthenticationType as e:
        return 'bad_authentication_type', str(e.allowed_types)
    except paramiko.ssh_exception.AuthenticationException:
        return 'key_rejected', None
    except Exception as e:
        return 'could_not_connect', str(e)
    finally:
        transport.close()
        sock.close()


def process_host(host):
    ip = host['ip']

    res, msg = connect_to_host(ip, 22)

    host['connection_result'] = res
    host['connection_details'] = msg

    with curr.get_lock():
        curr.value += 1
        print(f"[{curr.value}/{total}] Scanned {ip}: {res}, {msg}", file=sys.stderr)

    return host

def worker_setup(c, t):
    global curr, total
    curr, total = c, t


def main():
    filename = sys.argv[1]
    file = open(filename)
    hosts = json.load(file)
    total = len(hosts)
    print(f'Loaded {total} hosts', file=sys.stderr)

    curr = multiprocessing.Value('i', 0)
    pool = ThreadPool(initializer=worker_setup, initargs=[curr, total], processes=64) # connect to 64 hosts at a time
    results = pool.map(process_host, hosts)

    print(json.dumps(results, indent=4))


if __name__ == '__main__':
    main()
