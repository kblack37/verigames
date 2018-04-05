#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import sys
import pymongo
import gridfs
import bson
import  datetime, time
import random
from pymongo import Connection
from pymongo import database
from bson.objectid import ObjectId
from bson import json_util
import json
import base64
import requests
import os
from os import listdir
from os.path import isfile, join

#to at least slightly encrypt the access token
key = "23dsnweRt"
def encode(key, clear):
    enc = []
    for i in range(len(clear)):
        key_c = key[i % len(key)]
        enc_c = chr((ord(clear[i]) + ord(key_c)) % 256)
        enc.append(enc_c)
    return base64.urlsafe_b64encode("".join(enc))

def decode(key, enc):
    dec = []
    enc = base64.urlsafe_b64decode(enc)
    for i in range(len(enc)):
        key_c = key[i % len(key)]
        dec_c = chr((256 + ord(enc[i]) - ord(key_c)) % 256)
        dec.append(dec_c)
    return "".join(dec)

def getHighScoresForLevel2(levelID):
    try:
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api 
        collection = db.GameSolvedLevels
        concatList = {}
        count = 0
        for level in collection.find({"levelID":levelID}):
            count = count + 1
            if level['playerID'] in concatList:
                if int(concatList[level['playerID']][0]) < int(level['current_score']):
                    concatList[level['playerID']][0] = level['current_score']
                    concatList[level['playerID']][2] = level['assignmentsID']
                concatList[level['playerID']][4] = concatList[level['playerID']][4] + 1
                concatList[level['playerID']][3] = concatList[level['playerID']][3] + int(level['current_score']) - int(level['prev_score'])
            else:
                concatList[level['playerID']] = [level['current_score'], level['playerID'], level['assignmentsID'],  int(str(level['current_score']))-int(str(level['prev_score'])), 1 ]
        item = json.dumps(concatList, default=json_util.default)
        return item
    except:
        return sys.exc_info()


#pass url to api.paradox.verigames.org for GETS
def passURL2(url, code):
    code  = decode(key,code)

    resp = requests.get('http://api.paradox.verigames.org' + url, headers = {'Authorization': 'Bearer ' + code})
    if "api/user" in url:
        respJSON = json.dumps(resp.json())
        respObj = json.loads(respJSON)
        #remove unused info
        responseDict = {'id': respObj['id'], 'username': respObj['username']}
        responseString = json.dumps(responseDict)
    else:
        responseString = json.dumps(resp.json())
    try:
        if len(responseString) != 0:
            return responseString
        else:
            return 'success'
    except:
        return sys.exc_info()


#raw result, only available through script on server
def getPlayerInfo(id):
    try:
        code  = 'ua6hePVdI2' #comment this code in to use, leave comment to turn off ability to use this randomly
        resp = requests.get('http://api.paradox.verigames.org/api/users/' + id, headers = {'Authorization': 'Bearer ' + code})
        responseString = json.dumps(resp.json())
        if len(responseString) != 0:
            return responseString
        else:
            return 'success'
    except:
        return sys.exc_info()

def setPlayerActivityInfo(info, postdata):
    try:
        playerInfo = json.loads(postdata)
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api
        collection = db.PlayerActivity
        if "completed_boards" in playerInfo:
            collection.update({"playerID":playerInfo["playerID"]}, {"$set": {"cummulative_score": playerInfo["cummulative_score"], "submitted_boards": playerInfo["submitted_boards"], "completed_boards": playerInfo["completed_boards"]}}, True)
        else:
            collection.update({"playerID":playerInfo["playerID"]}, {"$set": {"cummulative_score": playerInfo["cummulative_score"], "submitted_boards": playerInfo["submitted_boards"]}}, True)

        return 'success'
    except:
        return sys.exc_info()

def getPlayerActivityInfo(id):
    try:
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api
        collection = db.PlayerActivity
        for info in collection.find({"playerID":id}):
            item = json.dumps(info, default=json_util.default)
            return item

        return '{"playerID" : "' + id + '" , "submitted_boards" : "0" , "cummulative_score" : "0"}'

    except:
        return sys.exc_info()

#since POSTs come in different content types, these need to be separated
def getAccessToken(url, postdata):
    #add client secret
    try:
        data = json.loads(postdata)
        data['client_secret'] = "3D89WG3WJHEW789WERQH34234"
        postdata = json.dumps(data)
        resp = requests.post('http://oauth.verigames.org/oauth2' + url, data=postdata, headers = {'content-type': 'application/json'})

        respJSON = json.dumps(resp.json())
        
        respObj = json.loads(respJSON)
        #remove unused info
        accessString = encode(key, respObj['access_token'])
        responseDict = {'response': accessString}
        responseString = json.dumps(responseDict)

        if len(responseString ) != 0:
            return responseString 
        else:
            return 'success'
    except Exception, e:
        return e


def jsonPOST(url, code, postdata):
    code = decode(key,code)

    resp = requests.post('http://api.paradox.verigames.org' + url, data=postdata, headers = {'content-type': 'application/json', 'Authorization': 'Bearer ' + code})
    responseString = json.dumps(resp.json())

    if len(responseString ) != 0:
        return responseString 
    else:
        return 'success'


def getPlayerIDPOST(url, postdata):
    postdata = decode(key,postdata)

    resp = requests.post('http://oauth.verigames.org/oauth2' + url, data={'token':postdata})
    responseString = json.dumps(resp.json())

    if len(responseString ) != 0:
        return responseString 
    else:
        return 'success'

def getActiveLevels2():
    try:
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api
        collection = db.ActiveLevels
        concatList = []
        count = 0
        for level in collection.find():
            count = count + 1
            concatList.append(level)

        item = json.dumps(concatList, default=json_util.default)
        return  item
    except:
        return sys.exc_info()


def getFile2(fileID):
    client = Connection('api.paradox.verigames.org', 27017)
    db = client.game3api
    fs = gridfs.GridFS(db)
    f = fs.get(ObjectId(fileID)).read()
    encoded = base64.b64encode(f)
    return encoded

def getFile2NonEncoded(fileID):
    try:
        #fileObj = json.loads(jsonFileObjStr)
        #fileID = fileObj['fileID']
        #filename = fileObj['filename']
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api
        fs = gridfs.GridFS(db)
        f = fs.get(ObjectId(fileID)).read()

        with open("/tmp/"+fileID+".zip", 'w') as file1:
            file1.write(f)
            file1.flush()
            os.fsync(file1)

        return "success"
    except:
        e = sys.exc_info()
        return '<html><head/><body><p>' + str(e) + ' Download failed.</p><a href="http://flowjam.verigames.org/game/robots.html">Go back to robots page</a></body></html>'


def submitLevel2(messageData, fileContents):
    try:
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api
        fs = gridfs.GridFS(db)
        messageObj = json.loads(messageData)
        if messageObj.get('id', 0) != 0:
            del messageObj['id']
        if messageObj.get('_id', 0) != 0:
            del messageObj['_id']
        if messageObj.get('$oid', 0) != 0:
            del messageObj['$oid']

        decoded = base64.b64decode(fileContents)
        newAssignmentsID = str(fs.put(decoded))
        previousAssignmentsID = messageObj["assignmentsID"]
        messageObj["assignmentsID"] = str(newAssignmentsID)
        collection = db.GameSolvedLevels
        id = collection.insert(messageObj)
        #mark served level as updated if score is higher than current
        collection = db.ActiveLevels
        levelID = messageObj["levelID"]
        for level in collection.find({"assignmentsID":previousAssignmentsID}):
            if int(str(level["current_score"])) < int(messageObj["current_score"]):
                currentsec = str(int(time.mktime(datetime.datetime.now().utctimetuple())))
                collection.update({"levelID":levelID}, {"$set": {"last_update": currentsec, "target_score": messageObj["current_score"], "revision": messageObj["revision"], "leader": messageObj["username"], "maxScore": messageObj["max_score"]}})
        return '{"solvedID":"' + str(id) + '"}'
    except:
        return sys.exc_info()

from zipfile import ZipFile
from StringIO import StringIO

def getAssignmentsJsonById(assignmentsID, _domain='org'):
    try:
        client = Connection('api.paradox.verigames.%s' % _domain, 27017)
        db = client.game3api
        fs = gridfs.GridFS(db)
        f = fs.get(ObjectId(assignmentsID))
        zipfile = ZipFile(StringIO(f.read()))
        fcontents = zipfile.open('assignments').read()
        return json.loads(fcontents)
    except:
        return None

def getTopSolutions(_version='15', _property='ostrusted', _domain='org'):
    client = Connection('api.paradox.verigames.%s' % _domain, 27017)
    db = client.game3api
    collection = db.GameSolvedLevels
    cur = collection.find({'property':_property, 'version':_version})
    subs = {}
    for sub in cur:
        this_obj = {}
        for f in ['submitted_date','assignmentsID','layoutID','username','conflicts','last_update','current_score','target_score','maxScore','name']:
            this_obj[f] = sub.get(f)
        nm = this_obj.get('name')
        if subs.get(nm) is None:
            subs[nm] = []
        subs[nm].append(this_obj)
    # sort from top scores to bottom
    asg_obj = {}
    for level_name in subs:
        asg_obj[level_name] = {'top_10_submissions': []}
        subs[level_name] = sorted(subs[level_name], key=lambda ss:int(ss.get('current_score', 0)), reverse=True)
        # gather assignments for top 10 scores for each level
        var_keys = []
        for sub in subs[level_name][:10]:
            assignmentsObj = getAssignmentsJsonById(sub.get('assignmentsID'), _domain)
            if assignmentsObj is None:
                continue
            these_assignments = assignmentsObj.get('assignments', {})
            if len(var_keys) == 0:
                for var_key in these_assignments:
                    var_keys.append(var_key)
            var_values = ''
            for var_key in var_keys:
                var_value_obj = these_assignments.get(var_key, {}).get('type_value')
                if var_value_obj == 'type:0':
                    var_values += '0'
                elif var_value_obj == 'type:1':
                    var_values += '1'
                else:
                    var_values += 'X'
            sub['assignments'] = var_values
            asg_obj[level_name]['top_10_submissions'].append(sub)
        asg_obj[level_name]['vars'] = var_keys
    return json.dumps(asg_obj)

def submitLevel2File(messageData, fileName):
    try:
        with open('tempfiles/'+fileName, 'r') as content_file:
            content = content_file.read()
            content_file.close()
            os.remove('tempfiles/'+fileName)
            return submitLevel2(messageData, content)
    except:
        os.remove('tempfiles/'+fileName)
        return sys.exc_info()
def test():
    client = Connection('api.paradox.verigames.org', 27017)
    db = client.gameapi

    return "food"

### begin mTurk  
def _getSubmissionsByTurkToken(turkToken):
    try:
        client = Connection('api.paradox.verigames.org', 27017)
        db = client.game3api 
        collection = db.GameSolvedLevels
        found_submissions = []
        for level in collection.find({'turkToken':turkToken}):
            last_update_time = int(level.get('submitted_date', 0))
            now_time = int(time.mktime(datetime.datetime.now().utctimetuple()))
            sec_ago = now_time - last_update_time
            found_submissions.append({
                'last_update_sec_ago': sec_ago,
                'prev_score': level.get('prev_score'),
                'current_score': level.get('current_score'),
                'max_score': level.get('max_score')
            })
        return sorted(found_submissions, key=lambda sub: int(sub.get('last_update_sec_ago', 0)), reverse=True)
    except:
        return []

def _getLatestImprovementsByTurkToken(turkToken):
    try:
        time_sorted_submissions = _getSubmissionsByTurkToken(turkToken)
        time_sorted_improvements = []
        current_score = -1
        for sub in time_sorted_submissions:
            sub_score = int(sub.get('current_score', -1))
            if sub_score > current_score:
                time_sorted_improvements.append(sub)
                current_score = sub_score
        return time_sorted_improvements
    except:
        return []

import urllib, urllib2, json, rsa, datetime, binascii, random
from threading import Thread
time_zero = datetime.datetime(2015, 6, 1)
TURK_API = 'https://mturk-api.verigames.org'
TURK_WORKER_TOKEN_URL = '%s/workerToken' % TURK_API
TURK_PW_GRANT_URL = '%s/oauth/token' % TURK_API
TURK_HITS_URL = '%s/domain/6/hits' % TURK_API
TURK_SET_CONF_CODE_URL = '%s/generateToken/code' % TURK_API
def get_crypo_key():
    with open('turk.pem') as privatefile:
        keydata = privatefile.read()
    return rsa.PrivateKey.load_pkcs1(keydata)

def tzero_sec(this_t=None):
    if this_t is None:
        this_t = datetime.datetime.utcnow()
    tdiff = this_t - time_zero
    return (tdiff.days * 24 * 3600 + tdiff.seconds)

def mTurkTaskBegin(data):
    data_dict = json.loads(data)
    key = get_crypo_key()
    info = {}
    info['workerToken'] = data_dict.get('workerToken', '')
    info['taskStart'] = tzero_sec()
    encrypted_msg = rsa.encrypt(json.dumps(info), key)
    return binascii.hexlify(encrypted_msg)

def mTurkTaskComplete(msg):
    key = get_crypo_key()
    decoded_msg = rsa.decrypt(binascii.unhexlify(msg), key)
    data_dict = json.loads(decoded_msg)
    worker_token = data_dict.get('workerToken', '')
    # Check for previously awarded token
    client = Connection('api.paradox.verigames.org', 27017)
    db = client.game3api
    collection = db.MturkTokensAwarded
    prev_task_completes = collection.find({"taskToken":worker_token})
    for prev in prev_task_completes:
        # if already awarded, return old code
        if prev.get("code") is not None:
            return prev["code"]
    task_start = data_dict.get('taskStart', 0)
    sec_since_start = tzero_sec() - task_start
    if sec_since_start < 120: # must have worked for at least 2 min
        return 0
    token = get_turk_access_token()
    new_code = hex(random.randint(0,2**40))[2:-1] # random (up to) 10 digit hex
    data = {
        'token': worker_token,
        'code': new_code
    }
    headers = {
        'Authorization': 'Bearer %s' % token,
        'Access-Control-Allow-Origin': '*'
    }
    data_enc = urllib.urlencode(data)
    try:
        req = urllib2.Request(TURK_SET_CONF_CODE_URL, data_enc, headers)
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        # If any improvements in the last 5 minutes, also award a bonus
        latest_improvements = _getLatestImprovementsByTurkToken(worker_token)
        found_improvement = False
        improv_5min_keys = {}
        bonus_val = 0.0
        for imp in latest_improvements:
            if imp.get('last_update_sec_ago') is not None:
                found_improvement = True
                five_min_key = '%s' % (imp.get('last_update_sec_ago')/300)*300 # round to 5 minute periods
                if improv_5min_keys.get(five_min_key) is None:
                    bonus_val += 0.25
                    improv_5min_keys[five_min_key] = True
        bonus_val = min(bonus_val, 1.25) # limit bonus to $1.25
        if found_improvement:
            # Record a bonus to be paid once the user submits this assignment
            bonus_str = '%s' % bonus_val
            collection.update({"taskToken":worker_token}, {"$set": {"code":new_code, "bonus":bonus_str}}, True)
        else:
            # Save code to avoid rewarding players multiple times
            collection.update({"taskToken":worker_token}, {"$set": {"code":new_code}}, True)
        return new_code
    except Exception as e:
        return 'mTurkTaskComplete Error: %s' % e

def _mTurkAwardUnrewardedBonuses(remove_if_unsuccessful=False):
    client = Connection('api.paradox.verigames.org', 27017)
    db = client.game3api
    collection = db.MturkTokensAwarded
    unrewarded_entries = collection.find({"bonusAwarded":None, "bonus":{"$ne":None}})
    output = '['
    for entry in unrewarded_entries:
        resp = None
        if entry.get('taskToken') is not None and entry.get('bonus') is not None:
            success, resp = _mTurkSendBonus(turkToken=entry.get('taskToken'),amt=entry.get('bonus'))
            if success or remove_if_unsuccessful:
                collection.update({"taskToken":entry.get('taskToken')}, {"$set": {"bonusAwarded":entry.get('bonus')}}, True)
                resp = 'Updated "bonusAwarded":"%s"' % entry.get('bonus')
        output += '{taskToken: %s code: %s bonus: %s, response: "%s"},' % (entry.get('taskToken'), entry.get('code'), entry.get('bonus'), resp)
    output += ']'
    return output

#deprecated
def _mTurkApproveAssignment(turkToken, token=None):
    if token is None:
        token = get_turk_access_token()
        TURK_API
    task_info = _getTaskInfoByWorkerToken(turkToken, token)
    assignment_id = task_info.get('assignmentId')
    if assignment_id is None:
        return 'Error null assignment_id'
    data = {
        'status': 'APPROVE',
        'reason': 'Success'
    }
    headers = {
        'Authorization': 'Bearer %s' % token,
        'Access-Control-Allow-Origin': '*'
    }
    data_enc = json.dumps(data)
    try:
        url = '%s/assignment/%s' % (TURK_API, assignment_id)
        req = urllib2.Request(url, data_enc, headers)
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        return resp_str
    except Exception as e:
        return e

def _mTurkSendBonus(turkToken, token=None, amt='0.50'):
    if token is None:
        token = get_turk_access_token()
    task_info = _getTaskInfoByWorkerToken(turkToken, token)
    assignment_id = task_info.get('assignmentId')
    worker_id = task_info.get('workerId')
    if assignment_id is None or worker_id is None:
        return 'Error: assignment_id: %s worker_id:%s' % (assignment_id, worker_id)
    data = {
        'WorkerId': worker_id,
        'BonusAmount': {'Amount': amt, 'CurrencyCode': 'USD'},
        'Reason': 'Conflicts solved.'
    }
    headers = {
        'Authorization': 'Bearer %s' % token,
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    }
    data_enc = json.dumps(data)
    try:
        req = urllib2.Request('%s/assignment/%s/bonus' % (TURK_API, assignment_id), data_enc, headers)
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        return (True, resp_str)
    except Exception as e:
        return (False, e.read())

def get_turk_access_token():
    data = {
        'grant_type': 'refresh_token',
        'refresh_token': '45P4TjNciiPqShyR5LK0w5rF8YapNY'
    }
    headers = {
        'Authorization': 'Basic MTpkZW1vLXNlY3JldA==',
        'Access-Control-Allow-Origin': '*'
    }
    data_enc = urllib.urlencode(data)
    try:
        req = urllib2.Request(TURK_PW_GRANT_URL, data_enc, headers)
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        resp_dict = json.loads(resp_str)
        return resp_dict.get('access_token')
    except Exception as e:
        return e

def _getTaskInfoByWorkerToken(turkToken, token=None):
    if token is None:
        token = get_turk_access_token()
    data = {
        'token': turkToken
    }
    headers = {
        'Authorization': 'Bearer %s' % token,
        'Access-Control-Allow-Origin': '*'
    }
    data_enc = urllib.urlencode(data)
    try:
        req = urllib2.Request('%s?%s' % (TURK_WORKER_TOKEN_URL, data_enc), headers=headers)
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        resp_dict = json.loads(resp_str)
        return resp_dict
    except Exception as e:
        return e
### end mTurk



if sys.argv[1] == "passURL2":
    print(passURL2(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "getAccessToken":
    print(getAccessToken(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "reportData":
    print(getAccessToken(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "getPlayerIDPOST":
    print(getPlayerIDPOST(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "jsonPOST":
    print(jsonPOST(sys.argv[2], sys.argv[3], sys.argv[4]))
elif sys.argv[1] == "getHighScoresForLevel2":
    print(getHighScoresForLevel2(sys.argv[2]))
elif sys.argv[1] == "getActiveLevels2":
    print(getActiveLevels2())
elif sys.argv[1] == "getFile2":
    print(getFile2(sys.argv[2]))
elif sys.argv[1] == "getFile2NonEncoded":
    print(getFile2NonEncoded(sys.argv[2]))
elif sys.argv[1] == "submitLevelPOST2File":
    print(submitLevel2File(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "submitLevelPOST2":
    print(submitLevel2(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "getPlayerInfo":
    print(getPlayerInfo(sys.argv[2]))
elif sys.argv[1] == "setPlayerActivityInfoPOST":
    print(setPlayerActivityInfo(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "getPlayerActivityInfo":
    print(getPlayerActivityInfo(sys.argv[2]))
### begin mTurk
elif sys.argv[1] == "mTurkTaskBegin":
    print(mTurkTaskBegin(sys.argv[2]))
elif sys.argv[1] == "mTurkTaskComplete":
    print(mTurkTaskComplete(sys.argv[2]))
elif sys.argv[1] == "_getLatestImprovementsByTurkToken":
    print(_getLatestImprovementsByTurkToken(sys.argv[2]))
elif sys.argv[1] == "_mTurkAwardUnrewardedBonuses":
    if len(sys.argv) >= 3:
        print(_mTurkAwardUnrewardedBonuses(True))
    else:
        print(_mTurkAwardUnrewardedBonuses())
## end mTurk
elif sys.argv[1] == "getTopSolutions":
    print(getTopSolutions(sys.argv[2], sys.argv[3], 'org'))
elif sys.argv[1] == "getTopProductionSolutions":
    print(getTopSolutions(sys.argv[2], sys.argv[3], 'com'))
elif sys.argv[1] == "test":
    print(test())

elif sys.argv[1] == "foo":
    print("bar")
else:
    print(sys.argv[1] + " not found")
