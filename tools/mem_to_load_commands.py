#!/usr/bin/env python3
"""
Host-side UART monitor / program loader for the RISC-V pipeline Phase 4.

This script converts a .mem file into:
1. A raw command stream (--format raw) — one "LOAD <N> <HEX>" per line.
2. A UART-ready binary stream (--format uart) — each line emitted as
   ASCII bytes that can be piped directly to a serial port.
3. An interactive loader (--format interactive) — uses pySerial to
   connect to the FPGA board's UART monitor and load a program.

Usage:
  # Generate raw command stream
  python mem_to_load_commands.py program.mem -f raw -o commands.txt

  # Generate binary UART stream (pipe to serial port)
  python mem_to_load_commands.py program.mem -f uart -o /dev/ttyUSB0

  # Interactive loader (requires pyserial)
  python mem_to_load_commands.py program.mem -f interactive --port COM3

  # Interactive loader with reset→load→run flow
  python mem_to_load_commands.py program.mem -f interactive --port COM3 --baud 115200
"""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path


def parse_mem_file(path: Path) -> list[int]:
    words: list[int] = []
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.split("//", 1)[0].strip()
        if not line:
            continue
        words.append(int(line, 16))
    return words


def format_raw(words: list[int]) -> str:
    lines = [
        f"LOAD {index:04d} {word:08x}"
        for index, word in enumerate(words)
    ]
    return "\n".join(lines) + ("\n" if lines else "")


def format_uart_binary(words: list[int]) -> bytes:
    """Emit UART-ready byte stream: each 'load N DATA\n' as raw ASCII bytes."""
    parts: list[bytes] = []
    for index, word in enumerate(words):
        line = f"load {index:04d} {word:08x}\n"
        parts.append(line.encode("ascii"))
    return b"".join(parts)


def interactive_loader(words: list[int], port: str, baud: int) -> None:
    """Connect to the FPGA UART monitor, reset, load program, and run."""
    try:
        import serial  # type: ignore[import-untyped]
    except ImportError:
        sys.exit(
            "pyserial is required for interactive mode.\n"
            "Install it with: pip install pyserial"
        )

    ser = serial.Serial(port, baud, timeout=2)
    print(f"Connected to {port} at {baud} baud")

    # Drain any existing data
    time.sleep(0.5)
    ser.reset_input_buffer()

    # Reset the CPU
    print("Sending 'reset'...")
    ser.write(b"reset\n")
    time.sleep(0.2)
    response = ser.read(ser.in_waiting or 1)
    if response:
        print(f"  <-- {response.decode('ascii', errors='replace').strip()}")

    # Load each program word
    total = len(words)
    for index, word in enumerate(words):
        cmd = f"load {index:04d} {word:08x}\n"
        ser.write(cmd.encode("ascii"))
        if (index + 1) % 16 == 0 or index == total - 1:
            print(f"  Loaded {index + 1}/{total} words...")
        time.sleep(0.001)

    # Run the program
    print("Sending 'run'...")
    ser.write(b"run\n")
    time.sleep(0.2)
    response = ser.read(ser.in_waiting or 1)
    if response:
        print(f"  <-- {response.decode('ascii', errors='replace').strip()}")

    print("Program loaded and running. Monitoring UART output (Ctrl+C to stop)...")
    try:
        while True:
            data = ser.read(ser.in_waiting or 1)
            if data:
                sys.stdout.buffer.write(data)
                sys.stdout.buffer.flush()
            else:
                time.sleep(0.001)
    except KeyboardInterrupt:
        print("\nStopped.")
    finally:
        ser.close()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="RISC-V pipeline UART monitor host loader."
    )
    parser.add_argument("mem_file", type=Path, help="Input .mem file")
    parser.add_argument(
        "-f", "--format",
        choices=["raw", "uart", "interactive"],
        default="raw",
        help="Output format: raw (text), uart (binary), interactive (serial port).",
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        help="Output file for raw/uart formats. Defaults to stdout.",
    )
    parser.add_argument(
        "--port",
        default="COM3",
        help="Serial port for interactive mode (default: COM3).",
    )
    parser.add_argument(
        "--baud",
        type=int,
        default=115200,
        help="Baud rate for interactive mode (default: 115200).",
    )
    args = parser.parse_args()

    words = parse_mem_file(args.mem_file)
    if not words:
        print("Warning: empty .mem file", file=sys.stderr)

    if args.format == "interactive":
        interactive_loader(words, args.port, args.baud)
    elif args.format == "uart":
        data = format_uart_binary(words)
        if args.output:
            args.output.write_bytes(data)
        else:
            sys.stdout.buffer.write(data)
    else:
        text = format_raw(words)
        if args.output:
            args.output.write_text(text, encoding="utf-8")
        else:
            print(text, end="")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
