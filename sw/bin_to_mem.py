import sys

def main():
    if len(sys.argv) != 3:
        print("Usage: python bin_to_mem.py <in.bin> <out.mem>")
        sys.exit(1)
    
    with open(sys.argv[1], "rb") as f_in, open(sys.argv[2], "w") as f_out:
        while True:
            chunk = f_in.read(4)
            if not chunk:
                break
            # Pad to 4 bytes if necessary
            chunk = chunk.ljust(4, b'\x00')
            # Little endian decoding
            val = int.from_bytes(chunk, byteorder='little')
            f_out.write(f"{val:08x}\n")

if __name__ == "__main__":
    main()
