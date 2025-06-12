import argparse
from PIL import Image

TTY_PALETTE = [
    (0, 0, 0), (128, 0, 0), (0, 128, 0), (128, 128, 0),
    (0, 0, 128), (128, 0, 128), (0, 128, 128), (192, 192, 192),
    (128, 128, 128), (255, 0, 0), (0, 255, 0), (255, 255, 0),
    (0, 0, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255)
]

def closest_palette_index(pixel, palette):
    r, g, b = pixel
    return min(
        range(len(palette)),
        key=lambda i: (r - palette[i][0]) ** 2 + (g - palette[i][1]) ** 2 + (b - palette[i][2]) ** 2
    )

def convert_pixel(pixel, depth):
    """Convert pixel (R,G,B) to supported color depth hex"""
    r, g, b = pixel

    if depth == 1:
        gray = sum(pixel) / 3
        return '1' if gray > 127 else '0'

    elif depth == 4:
        # Default: grayscale
        gray = int(sum(pixel) / 3 * 15 / 255)
        return f"{gray:01X}"

    elif depth == 14:  # special code for "4-bit tty"
        index = closest_palette_index(pixel, TTY_PALETTE)
        return f"{index:01X}"

    elif depth == 8:
        r3 = r >> 5  # 3 bits
        g3 = g >> 5  # 3 bits
        b2 = b >> 6  # 2 bits
        rgb332 = (r3 << 5) | (g3 << 2) | b2
        return f"{rgb332:02X}"

    elif depth == 12:
        r4 = r >> 4
        g4 = g >> 4
        b4 = b >> 4
        rgb444 = (r4 << 8) | (g4 << 4) | b4
        return f"{rgb444:03X}"

    else:
        raise ValueError("Unsupported color depth")

def image_to_vhdl(image_path, depth, output_file):
    image = Image.open(image_path).convert("RGB")
    pixels = list(image.getdata())

    # Adjust depth value for 4-bit tty
    vhdl_depth = 4 if depth in [1, 4, 14] else depth

    with open(output_file, "w") as f:
        f.write(f"-- BRAM initialization for {image_path}\n")
        f.write(f"constant image_data : array (0 to {len(pixels) - 1}) of std_logic_vector({vhdl_depth - 1} downto 0) := (\n")

        for i, px in enumerate(pixels):
            hex_val = convert_pixel(px, depth)
            f.write(f"    x\"{hex_val}\"")
            if i < len(pixels) - 1:
                f.write(",")
            if (i + 1) % 8 == 0:
                f.write("\n")

        f.write("\n);\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert image to VHDL BRAM constant")
    parser.add_argument("-i", "--image", required=True, help="Path to input image")
    parser.add_argument("-d", "--depth", type=int, required=True,
                        choices=[1, 4, 8, 12, 14],
                        help="Color depth: 1=mono, 4=grayscale, 14=TTY 4-bit color, 8=RGB332, 12=RGB444")
    parser.add_argument("-o", "--output", default="image_bram.vhd", help="Output VHDL file")

    args = parser.parse_args()
    image_to_vhdl(args.image, args.depth, args.output)
