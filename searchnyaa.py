#!/usr/bin/env python2

from __future__ import print_function
from docopt import docopt
import urllib2
import urllib
import socket
from bs4 import BeautifulSoup
import sys
import codecs

sys.stdout = codecs.getwriter('utf8')(sys.stdout)

def makeurl(url, data):
    return "http://" + url + "/?page=torrents&filter=0&" + "&".join(data)

usage = """Usage:
  searchnyaa.py [options] <search>

 -m --manga    Search for manga
 -s --sukebei  Search sukebei instead of standard nyaa
"""

args = docopt(usage, version="0.1")

nyaa_cats = {
    "All categories" : "0_0",
    "Anime" : "1_0",
    "Anime - Anime Music Video" : "1_32",
    "Anime - English-translated Anime" : "1_37",
    "Anime - Non-English-translated Anime" : "1_38",
    "Anime - Raw Anime" : "1_11",
    "Audio" : "3_0",
    "Audio - Lossless Audio" : "3_14",
    "Audio - Lossy Audio" : "3_15",
    "Literature" : "2_0",
    "Literature - English-translated Literature" : "2_12",
    "Literature - Non-English-translated Literature" : "2_39",
    "Literature - Raw Literature" : "2_13",
    "Live Action" : "5_0",
    "Live Action - English-translated Live Action" : "5_19",
    "Live Action - Live Action Promotional Video" : "5_22",
    "Live Action - Non-English-translated Live Action" : "5_21",
    "Live Action - Raw Live Action" : "5_20",
    "Pictures" : "4_0",
    "Pictures - Graphics" : "4_18",
    "Pictures - Photos" : "4_17",
    "Software" : "6_0",
    "Software - Applications" : "6_23",
    "Software - Games" : "6_24",
}

sukebei_cats = {
    "All categories" : "0_0",
    "Art" : "7_0",
    "Art - Anime" : "7_25",
    "Art - Doujinshi" : "7_33",
    "Art - Games" : "7_27",
    "Art - Manga" : "7_26",
    "Art - Pictures" : "7_28",
    "Real Life" : "8_0",
    "Real Life - Photobooks & Pictures" : "8_31",
    "Real Life - Videos" : "8_30",
}

data = []

def print_error(*objs):
    print("Error:", *objs, file=sys.stderr)

if args['--sukebei']:
    url = "sukebei.nyaa.se"
    if args['--manga']:
        data.append("cats=" + sukebei_cats["Art - Manga"])
else:
    url = "www.nyaa.se"
    if args['--manga']:
        data.append("cats=" + nyaa_cats["Literature"])
    else:
        data.append("cats=" + nyaa_cats["Anime - English-translated Anime"])

try:
    search = args['<search>']
    data.append("term=" + urllib.quote(search))
    searchurl = makeurl(url, data)
    resp = urllib2.urlopen(searchurl, timeout = 5).read()
except IndexError:
    print_error("Something went wrong while fetching data.")
    sys.exit(1)
except urllib2.URLError, e:
    if isinstance(e.reason, socket.timeout):
        print_error("Connection timed out.")
        sys.exit(1)
    else:
        raise

soup = BeautifulSoup(resp, "lxml")

for row in soup.find_all(True,"tlistrow"):
    name = row.select(".tlistname")[0].text
    link = row.find("a", title="Download").get("href")
    print(name + u"\thttp:" + link)
