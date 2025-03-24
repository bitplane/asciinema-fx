#!/usr/bin/env python3
import os, pty, sys, time, select

cmd = sys.argv[1:]

master_fd, slave_fd = pty.openpty()
pid = os.fork()

if pid == 0:
    os.setsid()
    os.dup2(slave_fd, 0)
    os.dup2(slave_fd, 1)
    os.dup2(slave_fd, 2)
    os.execvp(cmd[0], cmd)

os.close(slave_fd)

def forward_output(timeout=0.01):
    try:
        r, _, _ = select.select([master_fd], [], [], timeout)
        if r:
            data = os.read(master_fd, 1024)
            if data:
                os.write(1, data)
    except OSError:
        pass

def feed_lines():
    input_lines = sys.stdin.read().splitlines()

    for line in input_lines:
        forward_output()

        if line.strip() == "":
            # Blank line = 1s pause ONLY, no newline sent, no prompt shown
            time.sleep(1.0)
            continue

        for c in line:
            os.write(master_fd, c.encode())
            time.sleep(0.05)
            forward_output()

        os.write(master_fd, b'\n')
        time.sleep(0.05)

    # Drain final output
    while True:
        try:
            pid_ret, _ = os.waitpid(pid, os.WNOHANG)
            if pid_ret == pid:
                break
        except ChildProcessError:
            break
        forward_output()
        time.sleep(0.05)

    os.close(master_fd)

feed_lines()
