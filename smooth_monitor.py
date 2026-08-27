#!/usr/bin/env python3
# ==============================================================================
#  ⚡ VSTHunterKernel Smooth Live Log Monitor ⚡
#  Author: Valentin Stars (vstbio.t.me)
# ==============================================================================

import os
import sys
import time
import re

LOG_FILE = "/run/media/valentin_stars/linux/build.log"
TOTAL_UNITS = 4050

# Colors
C_RESET = "\033[0m"
C_BOLD = "\033[1m"
C_RED = "\033[1;31m"
C_GREEN = "\033[1;32m"
C_YELLOW = "\033[1;33m"
C_BLUE = "\033[1;34m"
C_MAGENTA = "\033[1;35m"
C_CYAN = "\033[1;36m"
C_GRAY = "\033[0;90m"

def print_banner():
    os.system("clear" if os.name == "posix" else "cls")
    print(f"{C_CYAN}======================================================================{C_RESET}")
    print(f"{C_BOLD}{C_GREEN}        ⚡ VSTHunterKernel Smooth Live Log Monitor ⚡{C_RESET}")
    print(f"  {C_YELLOW}Log Source:{C_RESET} {LOG_FILE}")
    print(f"  {C_YELLOW}Author:{C_RESET} Valentin Stars (vstbio.t.me)")
    print(f"{C_CYAN}======================================================================{C_RESET}\n")

def get_progress_bar(current, total, width=30):
    percent = min(100, int((current / total) * 100))
    filled = int(width * current // total)
    filled = min(width, max(0, filled))
    bar = "█" * filled + "░" * (width - filled)
    return f"[{C_GREEN}{bar}{C_RESET}] {C_BOLD}{percent:3d}%{C_RESET} ({current}/{total})"

def format_log_line(line):
    line = line.strip()
    if not line:
        return ""
    
    # Errors & Warnings
    if "error:" in line.lower() or "ошибка" in line.lower() or "failed" in line.lower():
        return f"{C_RED}{C_BOLD}[ERR]  {line}{C_RESET}"
    if "warning:" in line.lower() or "предупреждение" in line.lower():
        return f"{C_YELLOW}[WARN] {line}{C_RESET}"
    
    # Kernel actions
    if line.startswith("CC"):
        return f"{C_CYAN}[BUILD]{C_RESET} {C_BOLD}CC{C_RESET}      {line[2:].strip()}"
    if line.startswith("LD"):
        return f"{C_GREEN}[LINK] {C_RESET} {C_BOLD}LD{C_RESET}      {line[2:].strip()}"
    if line.startswith("AR"):
        return f"{C_MAGENTA}[PACK] {C_RESET} {C_BOLD}AR{C_RESET}      {line[2:].strip()}"
    if line.startswith("AS"):
        return f"{C_BLUE}[ASM]  {C_RESET} {C_BOLD}AS{C_RESET}      {line[2:].strip()}"
    if line.startswith("OBJCOPY"):
        return f"{C_GREEN}{C_BOLD}[IMAGE] OBJCOPY {line[7:].strip()}{C_RESET}"
    if line.startswith("GEN") or line.startswith("CHK"):
        return f"{C_GRAY}[GEN]  {line}{C_RESET}"
    if line.startswith("==="):
        return f"{C_YELLOW}{C_BOLD}{line}{C_RESET}"
    
    return f"{C_GRAY}       {line}{C_RESET}"

def main():
    print_banner()
    
    if not os.path.exists(LOG_FILE):
        print(f"{C_YELLOW}[*] Waiting for {LOG_FILE} to be created...{C_RESET}")
        while not os.path.exists(LOG_FILE):
            time.sleep(0.5)

    print(f"{C_GREEN}[✔] Log file found! Starting live stream...{C_RESET}\n")

    start_time = time.time()
    line_count = 0

    with open(LOG_FILE, "r", encoding="utf-8", errors="replace") as f:
        while True:
            line = f.readline()
            if line:
                line_count += 1
                formatted = format_log_line(line)
                if formatted:
                    elapsed = int(time.time() - start_time)
                    mins, secs = divmod(elapsed, 60)
                    time_str = f"{mins:02d}:{secs:02d}"
                    progress = get_progress_bar(line_count, TOTAL_UNITS)
                    
                    # Print progress header on status lines, or regular scroll
                    print(f"{C_GRAY}[{time_str}]{C_RESET} {progress} | {formatted}")
                    sys.stdout.flush()

                if "ALL DONE" in line or "Kernel Image Compiled Successfully!" in line:
                    if "ALL DONE" in line:
                        print(f"\n{C_GREEN}{C_BOLD}======================================================================{C_RESET}")
                        print(f"{C_GREEN}{C_BOLD}  🎉 BUILD FINISHED SUCCESSFULLY! 🎉{C_RESET}")
                        print(f"{C_GREEN}{C_BOLD}======================================================================{C_RESET}")
                        break
            else:
                time.sleep(0.2)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{C_YELLOW}[*] Live monitor stopped.{C_RESET}")
        sys.exit(0)
