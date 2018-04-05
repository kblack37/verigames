import games
import json
import urllib
import MySQLdb
import getpass

class DBInfo(object):
    def __init__(self, host, user):
        self.host = host
        self.user = user

dbdev = DBInfo(
    host = "dev.db.centerforgamescience.com",
    user = "cgs_gm_prd_u",
)

dbprd = DBInfo(
    host = "prd.db.centerforgamescience.com",
    user = "cgs_gm_prd_u",
)

dbreplica = DBInfo(
    host = "replica.db.centerforgamescience.com",
    user = "cgs_gm_prd_u",
)

dbs_by_name = {
    "dev" : dbdev,
    "prd" : dbprd,
    "replica" : dbreplica,
}

class _DBConnection(object):
    def __init__(self, connection):
        self.conn = connection

    def getConditionByUid(self, cid, uid):
        """Returns all the levels for the game gid and player uid"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT cond_id FROM user_conditions_ab WHERE cid=%d AND cgs_uid=\"%s\"" % (cid, uid))
        row = cursor.fetchone()
        return None if row is None else row["cond_id"]

    def getLevelsByUid(self, uid):
        """Returns all the levels for the game gid and player uid"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT qid,dqid,log_q_ts,sessionid,quest_seqid,q_detail,client_ts FROM player_quests_log WHERE uid=%s AND q_s_id=1 ORDER BY log_q_ts ASC", (uid))
        return cursor.fetchall()

    def getUidsByCid(self, cid):
        """Find a list of (unique) users who have logged levels under this cid"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT DISTINCT(uid) FROM player_quests_log WHERE cid=%d" % cid)
        return cursor.fetchall()

    def getQuestEnd(self, dqid):
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT log_q_ts,quest_seqid,q_detail FROM player_quests_log WHERE dqid=%s AND q_s_id=0", (dqid))
        return cursor.fetchone()

    def getActions(self, dqid):
        """Returns all actions associated with this dqid"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT log_id,aid,a_detail,log_ts,client_ts,ts,qaction_seqid,session_seqid FROM player_actions_log WHERE dqid=%s ORDER BY ts ASC", (dqid))
        return list(cursor.fetchall())

    def getPageloadsByUid(self, uid):
        """Find out how many times a user opened the game"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT * FROM player_pageload_log WHERE uid=%s", (uid))
        return cursor.fetchall()

    def getNoQuestActionsByUid(self, cid, uid):
        """Find all actions not associated with a level by player uid in version cid"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT aid,sessionid,a_detail,log_ts FROM player_actions_no_quest_log WHERE cid=%s AND uid=%s", (cid, uid))
        return cursor.fetchall()

    def getUidsWithQuestsBeforeTime(self, cid, unix_time_threshold):
        """Find all users that have an entry in the quests table before the given unix time."""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT DISTINCT(uid) FROM player_quests_log WHERE cid=%s AND log_q_ts <= %s", (cid, unix_time_threshold))
        return cursor.fetchall()

    def getQuests(self):
        """Return quest information, generally to be used by ptqt scripts which need them in a flat file"""
        cursor = self.conn.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT * FROM quests")
        return cursor.fetchall()

def connect(gameinfo, dbinfo, dbname=None):

    if dbname is None:
        dbname = gameinfo.db_log

    # For automated scripts, the file requires a dbpasswd.py file with a single entry of the form:
    # DBPASSWD="theactualpassword"
    # Failing to find this, the program will prompt the user for the password.
    # This is to prevent the scripts from having to put the password in a version control system.
    # Sure, it's a limitation to use one password for everything, but the scripts rarely
    # use more than one database at once and the password is always the same anyway.
    # This can easily be improved in the future if necessary.
    try:
        from dbpasswd import DBPASSWD
    except:
        print("dbpasswd.py not found, requiring manual password entry.")
        DBPASSWD = getpass.getpass('MySQL password: ')

    conn = MySQLdb.connect(
        host = dbinfo.host, 
        user = dbinfo.user,
        passwd = DBPASSWD,
        db = dbname,
    )
    return _DBConnection(conn)

