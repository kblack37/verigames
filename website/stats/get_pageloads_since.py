#!/usr/bin/python

import db
import games
import MySQLdb
import cgi
import simplejson as json
import sys
from dbpasswd import DBPASSWD

import logging

logging.basicConfig(filename='pageload.log',level=logging.DEBUG)

# 12/4/2013 10am PST = 1386180000
def get_pageloads(unix_timestamp_sec):
    try:
        gamename = 'pipejam'
        dbname = "prd"
        cid = 20
        game = games.games_by_name[gamename]

        dbinfo = db.dbs_by_name[dbname]
        #print "SELECT log_pl_id,uid,referrer_host,log_ts FROM player_pageload_log WHERE log_ts>%s ORDER BY log_ts DESC" % unix_timestamp_sec
        dbconn = db.connect(game, dbinfo)
        cursor = dbconn.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT log_pl_id,uid,referrer_host,log_ts FROM player_pageload_log WHERE log_ts>%s ORDER BY log_ts DESC" % unix_timestamp_sec)
        return cursor.fetchall()
    except Exception as e:
        print '{"error": "%s"}' % e
        logging.debug("error: %s" % e)
        sys.stderr.write("error")
        sys.exit(1)
try:
    print 'Content-Type: application/json\n\n'
    form = cgi.FieldStorage()
    unix_ts = form.getvalue("unix_ts") or 1386180000
    all_pl = get_pageloads(unix_ts)
    json.dump(all_pl, sys.stdout)

except Exception as e:
    print '{"error": "%s"}' % e
    logging.debug("error: %s" % e)
    sys.stderr.write("error")
    sys.exit(1)