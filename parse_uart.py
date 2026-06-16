import sys
import re

log_path = sys.argv[1]
with open(log_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

output = ""
for line in lines:
    if ">>> RUNNING BENCHMARK SIMULATION:" in line:
        output += "\n" + line.strip() + "\n"
    match = re.search(r'\[C-PROGRAM UART\] t=\d+\s+(.*)', line)
    if match:
        char = match.group(1)
        if char == '':
            output += '\n'
        else:
            output += char

print(output)
