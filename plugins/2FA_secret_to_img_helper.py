#!/bin/python3
# Dependencies: qrcode, pillow
# Transform a 2FA string to a QR code.
# usage: python3 ./<this>.py $imgBaseName $oauthStr
import qrcode
import sys

if __name__ == '__main__':
    imgBaseName = sys.argv[1]
    oauthStr = sys.argv[2]

    if not oauthStr:
        print('WARN: oauthStr is empty!')
    img = qrcode.make(oauthStr)
    img.save(f"{imgBaseName}.png")