# -*- coding: utf-8 -*-

import sys
import argparse
import os
from downloader import kauf_collection

def main(args):
    """
    Download a David Kaufman Manuscript
    """

    parser = argparse.ArgumentParser()
    parser.add_argument("ms", help="Please specificy which manuscript: MS A 50, MS A 77, MS A 380, MS A 384, MS A 388, MS A 422, MS A 422")
    parser.add_argument("s", help="Please indicate a side of the folio")
    args = parser.parse_args()

    if not os.path.exists('plates/' + str(args.ms)):
        os.mkdir('plates/' + str(args.ms))
    
    kauf_collection(args.ms, args.s)

if __name__ == '__main__':
    main(sys.argv[1:])