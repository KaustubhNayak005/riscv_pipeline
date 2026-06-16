import re

filepath = r'C:\Users\nayak\Desktop\riscv32-processor\riscv_pipeline_offline\riscv_pipeline_offline.srcs\sources_1\imports\src\uart_monitor.sv'

with open(filepath, 'r') as f:
    content = f.read()

# Replace match_cmd("string")
def replace_match_cmd(m):
    cmd_str = m.group(1)
    conds = []
    for i, c in enumerate(cmd_str):
        conds.append(f'(cmd_buf[{i}] == "{c}" || cmd_buf[{i}] == "{c.upper()}")')
    return '(' + ' && '.join(conds) + ')'

content = re.sub(r'match_cmd\("([^"]+)"\)', replace_match_cmd, content)

# Replace tx_push_string("string")
def replace_tx_push_string(m):
    cmd_str = m.group(1)
    calls = []
    
    # We must properly handle \r and \n which are two chars in the text file
    i = 0
    while i < len(cmd_str):
        if cmd_str[i] == '\\' and i+1 < len(cmd_str):
            c = cmd_str[i:i+2]
            i += 2
        else:
            c = cmd_str[i]
            i += 1
        calls.append(f'tx_push("{c}");')
    
    return ' '.join(calls)

content = re.sub(r'tx_push_string\("([^"]+)"\)', replace_tx_push_string, content)

# Remove the actual functions
content = re.sub(r'function automatic void tx_push_string\(input string s\);.*?endfunction', '', content, flags=re.DOTALL)
content = re.sub(r'function automatic logic match_cmd\(input string s\);.*?endfunction', '', content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(content)

print("UART Monitor fixed successfully.")
