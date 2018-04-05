#!/usr/bin/python

import json
from operator import itemgetter
import sys
import datetime
import db
import games
import argparse
import random

class PJARGS:
    def __init__(self, cid):
        self.game = 'pipejam'
        self.db = 'prd'
        self.cid = cid
        self.numuids = None
        self.mintime = None
        self.maxtime = None
        self.user_file = None

def dumppipejam(cid):
    main(PJARGS(cid))

def main(args):
    try:
        gamename = args.game
        dbname = args.db
        cid = args.cid
        game = games.games_by_name[gamename]

        dbinfo = db.dbs_by_name[dbname]
    except Exception as e:
        print 'error: %s' % e
        sys.stderr.write("error")
        sys.exit(1)

    conn = db.connect(game, dbinfo)
    conn_ab = None
    if game.db_ab is not None:
        conn_ab = db.connect(game, dbinfo, game.db_ab)

    if args.user_file is None:
        uids = [row['uid'] for row in conn.getUidsByCid(cid)]
    else:
        uids = [x.rstrip() for x in args.user_file.readlines()]
        args.user_file.close()

    f = open("./latest_dump.jsons", "w")

    if args.numuids is None:
        total = len(uids)
    else:
        total = min(len(uids), args.numuids)
        random.shuffle(uids)
        uids = uids[:total]

    count = 0
    for uid in uids:
        count += 1
        print("%d/%d" % (count, total))

        if len(uid) == 0:
            print("empty uid, skipping")
            continue

        loads = conn.getPageloadsByUid(uid)
        if len(loads) == 0:
            #This player has no pageloads, the data is invalid
            print("%s has no pageloads, skipping" % uid)
            count -= 1
            continue

        # filter players by time
        if args.maxtime is not None or args.mintime is not None:
            firstpl = sorted(loads, key=lambda x: x["log_pl_id"])[0]
            firststarttime = firstpl["log_ts"]
            if args.maxtime is not None and firststarttime > args.maxtime:
                print("too early, skipping")
                continue
            if args.mintime is not None and firststarttime < args.mintime:
                print("too late, skipping")
                continue

        levels = conn.getLevelsByUid(uid)

        for l in levels:
            #l_count += 1
            #print("\t%d/%d" % (l_count,len(levels)))
            if l["dqid"] == None:
                sys.stderr.write("Null dqid, skipping: %s" % str(l))
                continue
            #if l["cid"] != cid:
                #sys.stderr.write("Wrong cid: %s" % l["cid"])
                #continue
            actions = conn.getActions(l["dqid"])
            questend = conn.getQuestEnd(l["dqid"])
            actions = sorted(actions, key=itemgetter("ts"))
            l["actions"] = actions
            l["questend"] = questend

        p = {}
        p["uid"] = uid
        #p["cd_id"] = condition
        p["levels"] = levels
        p["actions"] = conn.getNoQuestActionsByUid(cid, uid)
        p["pageloads"] = loads
        if conn_ab is not None:
            p["cond_id"] = conn_ab.getConditionByUid(cid, uid)
        else:
            p["cond_id"] = 0
        f.write(json.dumps(p))
        f.write("\n")
        f.flush()

    f.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Dump raw data from the database into ./latest_dump.jsons')
    parser.add_argument('game', choices=games.games_by_name.keys(), help="game name")
    parser.add_argument('cid', metavar='CID', type=int, help="category id")
    parser.add_argument('db', choices=db.dbs_by_name.keys(), help="database")
    parser.add_argument('-n', '--num', dest="numuids", type=int, required=False, default=None, help="Rather than dumping everything, dump a random subset of this many players.")
    parser.add_argument('--mnt', dest="mintime", type=int, required=False, default=None, help="Filter players whose first pageload starts before this time.")
    parser.add_argument('--mxt', dest="maxtime", type=int, required=False, default=None, help="Filter players whose first pageload starts after this time.")
    parser.add_argument('--users', dest="user_file", type=argparse.FileType('r'), default=None, help="Instead of picking players based on query, use the uids from this file, with one user per line")
    main(parser.parse_args())

