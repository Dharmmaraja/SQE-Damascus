# -*- coding: utf-8 -*-

import urllib3
import csv
import re
import logging
import datetime
import os
from config import nli_url, kauf_url

def pull_down(f, plate, res):
    """
    Download the iiif image to local machine
    """
    nli = nli_url()

    http = urllib3.PoolManager()

    logging.basicConfig(
        filename="image_downloader.log",
        level=logging.DEBUG,
        format="%(asctime)s:%(levelname)s:%(message)s",
    )

    # As of 18-08-2019, the colour image profile is still incorrect
    url = str(nli) + str(f) + "/full/pct:" + str(res) + "/0/default.jpg"

    if os.path.exists(os.path.join("plates", "P" + str(plate), str(f))):
        print("File {} exists locally".format(f))
    else:
        print("Downloading {} …".format(f))
        img = http.request("GET", url, preload_content=False)
        with open(os.path.join("plates", "P" + str(plate), str(f)), "wb") as out:
            while True:
                data = img.read(1500)
                if not data:
                    break
                out.write(data)
            print("{} is saved …".format(f))

def kauf_collection(ms, s):
    """
    Download the Kaufmann A 50 Mishnah Manuscript
    """
    kauf = kauf_url()

    http = urllib3.PoolManager()

    logging.basicConfig(
        filename="image_downloader.log",
        level=logging.DEBUG,
        format="%(asctime)s:%(levelname)s:%(message)s",
    )

    page_beg = 000
    page_end = 287

    while page_beg < page_end:
        folio = "{0:0=3d}".format(page_beg)

        url = str(kauf) + str(ms) + "-50pc/" + str(ms) + "-" + str(folio) + str(s) + "-large.jpg"
        img = http.request("GET", url, preload_content=False)
        with open(os.path.join("plates/ms50", str(page_beg) + str(s) + ".jpg"), 'wb') as out:
            while True:
                data = img.read(1500)
                if not data:
                    break
                out.write(data)
            print("{} is saved".format(url))
        page_beg += 1