import argparse
from PIL import Image


def convert_pixel(pixel, depth):
    """Convert pixel (R,G,B) to desired color depth hex"""
    if depth == 1:
        gray = sum(pixel) / 3
        return '1' if gray > 127 else '0'
    elif depth == 4:
        gray = int(sum(pixel) / 3 * 15 / 255)
        return f"{gray:01X}"
    elif depth == 8:
        gray = int(sum(pixel) / 3)
        return f"{gray:02X}"
    elif depth == 16:
        r, g, b = pixel
        rgb565 = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
        return f"{rgb565:04X}"
    elif depth == 24:
        return f"{pixel[0]:02X}{pixel[1]:02X}{pixel[2]:02X}"
    else:
        raise ValueError("Unsupported color depth")


def image_to_vhdl(image_path, depth, output_file):
    image = Image.open(image_path).convert("RGB")
    pixels = list(image.getdata())

    with open(output_file, "w") as f:
        f.write(f"-- BRAM initialization for {image_path}\n")
        f.write(f"constant image_data : array (0 to {len(pixels) - 1}) of std_logic_vector({depth - 1} downto 0) := (\n")

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
    parser.add_argument("-i", "--image", help="Path to input image")
    parser.add_argument("-d", "--depth", type=int, choices=[1, 4, 8, 16, 24], help="Color depth in bits")
    parser.add_argument("-o", "--output", default="image_bram.vhd", help="Output VHDL file")

    args = parser.parse_args()
    image_to_vhdl(args.image, args.depth, args.output)

