#!/usr/bin/env python

from docopt import docopt
import urllib2
from bs4 import BeautifulSoup
import sys

def makeurl(url, data):
    return "http://" + url + "/?page=torrents&filter=0&" + "&".join(data)

usage = """Usage:
  searchnyaa.py [-s] <search>

 -s --sukebei  Search sukebei instead of standard nyaa
"""

args = docopt(usage, version="0.1")

data = []

if args['--sukebei']:
    url = "sukebei.nyaa.se"
else:
    url = "www.nyaa.se"
    data.append("cats=1_37")

try:
    search = args['<search>']
    data.append("term=" + search)
    searchurl = makeurl(url, data)
    resp = urllib2.urlopen(searchurl).read()
except IndexError:
    print("Something went wrong while fetching data.")
    sys.exit(1)

soup = BeautifulSoup(resp)

for row in soup.find_all(True,"tlistrow"):
    name = row.select(".tlistname")[0].text
    link = row.find("a", title="Download").get("href")
    print(name + u"\t" + link)
