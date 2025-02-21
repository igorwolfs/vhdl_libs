def gray2bin(gray):
    """Converts a Gray code integer to binary."""
    binary = gray
    mask = gray >> 1
    while mask != 0:
        binary = binary ^ mask
        mask = mask >> 1
    return binary

def bin2gray(binary):
    """Converts a binary integer to Gray code."""
    return binary ^ (binary >> 1)
