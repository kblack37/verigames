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
def get_playdata(unix_timestamp_sec, dbname):
    try:
        gamename = 'pipejam'
        game = games.games_by_name[gamename]

        dbinfo = db.dbs_by_name[dbname]
        #print "SELECT log_pl_id,uid,referrer_host,log_ts FROM player_pageload_log WHERE log_ts>%s ORDER BY log_ts DESC" % unix_timestamp_sec
        dbconn = db.connect(game, dbinfo)
        cursor = dbconn.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT q.uid, q.qid, MIN(q.log_q_ts) FROM player_pageload_log AS p INNER JOIN player_quests_log AS q ON p.uid=q.uid WHERE q.cid=21 AND q.uid!='cgs_vg_51cb6fc7ddfe66b65d000021' AND q.uid!='cgs_vg_51e5b3460240288229000026' AND q.uid!='cgs_vg_555b7cd234359e8c18e3e644' AND q.uid!='cgs_vg_51ed82f638bbaae624000047' AND p.referrer_host='paradox.verigames.com' AND q.log_q_ts>%s AND q_s_id=1 GROUP BY q.dqid ORDER BY q.log_q_ts;" % unix_timestamp_sec)
        return cursor.fetchall()
    except Exception as e:
        print '{"error": "%s"}' % e
        logging.debug("error: %s" % e)
        sys.stderr.write("error")
        sys.exit(1)
try:
    print 'Content-Type: application/json\n\n'
    form = cgi.FieldStorage()
    unix_ts = form.getvalue("unix_ts") or 0
    dbname = form.getvalue("db") or 'prd'
    all_pl = get_playdata(unix_ts, dbname)
    json.dump(all_pl, sys.stdout)

except Exception as e:
    print '{"error": "%s"}' % e
    logging.debug("error: %s" % e)
    sys.stderr.write("error")
    sys.exit(1)