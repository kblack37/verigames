#!/usr/bin/python

from dumpraw import dumppipejam
from processdump import process
import argparse
import os

def main(args):
    dumppipejam(args.cid)
    process('latest_dump')
    os.rename('new_latest_dump.json', 'player_levels.json')
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Dump raw data, process, and output ./player_levels.json')
    parser.add_argument('cid', metavar='CID', type=int, help="category id")
    main(parser.parse_args())

