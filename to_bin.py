def convert(txt_filename, mif_filename, bitWidth):

    def to_signed_binary(num, bit_width):
        if num >= 0:
            return bin(num)[2:].zfill(bit_width)
        else:
            # Calculate two's complement
            magnitude_binary = bin(abs(num))[2:].zfill(bit_width)
            inverted_bits = ''.join(['1' if bit == '0' else '0' for bit in magnitude_binary])
            two_complement_int = int(inverted_bits, 2) + 1
            return bin(two_complement_int)[2:].zfill(bit_width)


    #PROGRAM ENTRY

    #  MATLAB has rough time converting decimal numbers into signed binary strings of custom bit width thats not 8, 16, 32, 64.
    #  This program reads a .txt file of whole number decimals, each row ending in a '\n' character.
    #  It then converts each whole number from that .txt file to signed binary string representation in a .mif file.
    #  Each row in the .mif ends with '\n' for the rom.vhd to parse correctly

    BIT_WIDTH = bitWidth
    TEXT_FILE = txt_filename
    MIF_FILE = mif_filename

    #populate list of decimal_strings from MATLAB
    with open(TEXT_FILE, 'r') as f:
        list_ofStringDecimals = f.readlines()

    #strip "/n" character from each decimal string item
    list_ofStringDecimals = [item.strip() for item in list_ofStringDecimals] 

    #convert each decimal_str item to decimal_int
    list_ofIntDecimals = [int(item) for item in list_ofStringDecimals] 

    #convert each decimal_int to binary_str
    list_ofStringBinary = [to_signed_binary(item, BIT_WIDTH) for item in list_ofIntDecimals] 

    #write each binary string item to file without trailing \n character
    with open(MIF_FILE, "w") as f:
        f.write('\n'.join(list_ofStringBinary))


