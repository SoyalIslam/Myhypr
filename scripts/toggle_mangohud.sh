#!/usr/bin/env python3
import socket
import re
import subprocess

def toggle_mangohud():
    try:
        with open("/proc/net/unix", "r") as f:
            data = f.read()
    except Exception:
        data = ""

    # Find all abstract unix sockets created by MangoHud
    sockets = re.findall(r"@mangohud-[0-9]+|@mangohud\b", data)
    toggled = 0

    for sock in set(sockets):
        # In abstract namespace, leading '@' corresponds to null byte '\0'
        abstract_addr = "\0" + sock[1:]
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.settimeout(0.5)
            s.connect(abstract_addr)
            s.sendall(b":hud;")
            s.close()
            toggled += 1
        except Exception:
            pass

    if toggled > 0:
        subprocess.run(
            ["notify-send", "-t", "1200", "-u", "low", "-a", "MangoHud", "MangoHud", "Overlay Toggled"],
            check=False
        )
    else:
        subprocess.run(
            ["notify-send", "-t", "2000", "-u", "low", "-a", "MangoHud", "MangoHud", "No running game detected"],
            check=False
        )

if __name__ == "__main__":
    toggle_mangohud()
