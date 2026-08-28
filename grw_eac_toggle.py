#!/usr/bin/env python3
import argparse
import hashlib
import shutil
import sys
from pathlib import Path
import tkinter as tk
from tkinter import messagebox, scrolledtext

TOGGLE_DIR = "GRW_EAC_toggle"
BACKUP_SUBDIR = "backups"
UID_FILE = "UIDs.txt"
DLL_X86 = "EasyAntiCheat_x86.dll"
DLL_X64 = "EasyAntiCheat_x64.dll"
HASH_ALGO = "sha256"

def sha256_hex(path: Path) -> str:
    h = hashlib.new(HASH_ALGO)
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def read_uids(uid_path: Path):
    uids = {}
    if not uid_path.exists():
        return uids
    for line in uid_path.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            k, v = line.split("=", 1)
            uids[k.strip()] = v.strip()
    return uids

def write_uids(uid_path: Path, data: dict):
    uid_path.parent.mkdir(parents=True, exist_ok=True)
    with uid_path.open("w", encoding="utf-8") as f:
        for k in sorted(data.keys()):
            f.write(f"{k}={data[k]}\n")

def safe_copy(src: Path, dst: Path):
    shutil.copy2(src, dst)

def restore_from_backup(backup_dir: Path, base_dir: Path):
    b_x86 = backup_dir / DLL_X86
    b_x64 = backup_dir / DLL_X64
    if b_x86.exists():
        safe_copy(b_x86, base_dir / DLL_X86)
    if b_x64.exists():
        safe_copy(b_x64, base_dir / DLL_X64)
    messagebox.showerror("Error", "DLLs were corrupted. Restored originals.")
    sys.exit(1)

def first_run(base_dir: Path, toggle_dir: Path, backup_dir: Path, uid_path: Path):
    backup_dir.mkdir(parents=True, exist_ok=True)
    dll_x86 = base_dir / DLL_X86
    dll_x64 = base_dir / DLL_X64
    dll_x86_dis = base_dir / (DLL_X86 + ".disable")
    dll_x64_dis = base_dir / (DLL_X64 + ".disable")

    if not dll_x86.exists() or not dll_x64.exists() or not dll_x86_dis.exists() or not dll_x64_dis.exists():
        messagebox.showerror("Error", "Missing required DLL or DLL.disable files.")
        sys.exit(1)

    uids = {
        "x86_enabled": sha256_hex(dll_x86),
        "x86_disabled": sha256_hex(dll_x86_dis),
        "x64_enabled": sha256_hex(dll_x64),
        "x64_disabled": sha256_hex(dll_x64_dis),
    }

    write_uids(uid_path, uids)
    safe_copy(dll_x86, backup_dir / DLL_X86)
    safe_copy(dll_x64, backup_dir / DLL_X64)

def detect_state(base_dir: Path, uids: dict):
    dll_x86 = base_dir / DLL_X86
    dll_x64 = base_dir / DLL_X64
    cur_x86 = sha256_hex(dll_x86)
    cur_x64 = sha256_hex(dll_x64)
    xe = uids.get("x86_enabled")
    xd = uids.get("x86_disabled")
    ye = uids.get("x64_enabled")
    yd = uids.get("x64_disabled")
    state_x86 = "ENABLED" if cur_x86 == xe else ("DISABLED" if cur_x86 == xd else None)
    state_x64 = "ENABLED" if cur_x64 == ye else ("DISABLED" if cur_x64 == yd else None)
    if state_x86 == state_x64:
        return state_x86
    return None

def toggle_state(base_dir: Path, backup_dir: Path, uids: dict):
    dll_x86 = base_dir / DLL_X86
    dll_x64 = base_dir / DLL_X64
    dll_x86_dis = base_dir / (DLL_X86 + ".disable")
    dll_x64_dis = base_dir / (DLL_X64 + ".disable")

    state = detect_state(base_dir, uids)
    if state is None:
        restore_from_backup(backup_dir, base_dir)

    if state == "ENABLED":
        safe_copy(dll_x86_dis, dll_x86)
        safe_copy(dll_x64_dis, dll_x64)
        return "DISABLED"
    else:
        b_x86 = backup_dir / DLL_X86
        b_x64 = backup_dir / DLL_X64
        if not b_x86.exists() or not b_x64.exists():
            restore_from_backup(backup_dir, base_dir)
        safe_copy(b_x86, dll_x86)
        safe_copy(b_x64, dll_x64)
        return "ENABLED"

class App:
    def __init__(self, root, base_dir):
        self.root = root
        self.base = base_dir
        self.toggle_dir = base_dir / TOGGLE_DIR
        self.backup_dir = self.toggle_dir / BACKUP_SUBDIR
        self.uid_path = self.toggle_dir / UID_FILE

        if not self.uid_path.exists():
            self.toggle_dir.mkdir(parents=True, exist_ok=True)
            first_run(self.base, self.toggle_dir, self.backup_dir, self.uid_path)

        self.uids = read_uids(self.uid_path)

        root.title("GRW EAC Toggle")
        root.geometry("420x300")
        root.resizable(False, False)

        self.state_label = tk.Label(root, text="", font=("Segoe UI", 16, "bold"))
        self.state_label.pack(pady=10)

        self.toggle_button = tk.Button(root, text="Toggle EAC", font=("Segoe UI", 14), command=self.on_toggle)
        self.toggle_button.pack(pady=10)

        self.log = scrolledtext.ScrolledText(root, width=50, height=10, state="disabled")
        self.log.pack(pady=10)

        self.refresh_state()

    def log_write(self, text):
        self.log.config(state="normal")
        self.log.insert(tk.END, text + "\n")
        self.log.config(state="disabled")
        self.log.see(tk.END)

    def refresh_state(self):
        state = detect_state(self.base, self.uids)
        if state is None:
            self.state_label.config(text="ERROR", fg="red")
        elif state == "ENABLED":
            self.state_label.config(text="EAC ENABLED", fg="green")
        else:
            self.state_label.config(text="EAC DISABLED", fg="red")

    def on_toggle(self):
        new_state = toggle_state(self.base, self.backup_dir, self.uids)
        self.log_write(f"Toggled to {new_state}")
        self.refresh_state()

def main():
    base = Path(__file__).resolve().parent
    root = tk.Tk()
    App(root, base)
    root.mainloop()

if __name__ == "__main__":
    main()