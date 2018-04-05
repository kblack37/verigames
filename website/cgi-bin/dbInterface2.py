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

def getPlayedTutorials2(playerID):
	client = Connection('api.paradox.verigames.org', 27017)
	db = client.gameapi
	collection = db.CompletedTutorials
	concatList = []
	for level in collection.find({"playerID":playerID}):
		concatList.append(level)

	item = json.dumps(concatList, default=json_util.default)
	return item
	
def reportPlayedTutorial2(messageData):
	client = Connection('api.paradox.verigames.org', 27017)
	db = client.gameapi
	collection = db.CompletedTutorials
	messageObj = json.loads(messageData)
	del messageObj.id
	del messageObj._id

	collection.insert(messageObj)
	return '///success'

def reportPlayerRating2(messageData):
	client = Connection('api.paradox.verigames.org', 27017)
	db = client.gameapi
	collection = db.CompletedLevels
	messageObj = json.loads(messageData)
	collection.insert(messageObj)
	return 'success'

def getHighScoresForLevel2(levelID):
	try:
		client = Connection('api.paradox.verigames.org', 27017)
		db = client.game2api
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
	resp = requests.get('http://api.paradox.verigames.org' + url, headers = {'Authorization': 'Bearer ' + code})
	responseString = json.dumps(resp.json())
	try:
		if len(responseString) != 0:
			return responseString
		else:
			return 'success'
	except:
		return sys.exc_info()


#since POSTs come in different content types, these need to be separated
def getTokenPOST(url, postdata):
	#add client secret
	data = json.loads(postdata)
	data['client_secret'] = "3D89WG3WJHEW789WERQH34234"
	postdata = json.dumps(data)
	resp = requests.post('http://oauth.verigames.org/oauth2' + url, data=postdata, headers = {'content-type': 'application/json'})
	responseString = json.dumps(resp.json())

	if len(responseString ) != 0:
		return responseString 
	else:
		return 'success'

def jsonPOST(url, code, postdata):
	#add client secret
	resp = requests.post('http://api.paradox.verigames.org' + url, data=postdata, headers = {'content-type': 'application/json', 'Authorization': 'Bearer ' + code})
	responseString = json.dumps(resp.json())

	if len(responseString ) != 0:
		return responseString 
	else:
		return 'success'


def getPlayerIDPOST(url, postdata):
	resp = requests.post('http://oauth.verigames.org/oauth2' + url, data={'token':postdata})
	responseString = json.dumps(resp.json())

	if len(responseString ) != 0:
		return responseString 
	else:
		return 'success'

def getActiveLevels2():
	try:

		client = Connection('api.paradox.verigames.org', 27017)
		db = client.game2api
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
	db = client.game2api
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
		db = client.game2api
		fs = gridfs.GridFS(db)
		f = fs.get(ObjectId(fileID)).read()

		with open("/tmp/"+fileID+".zip", 'w') as file1:
			file1.write(f)
			file1.flush()
			os.fsync(file1)

		return "success"
	except:
		e = sys.exc_info()
		return '<html><head/><body><p>' + str(e) + ' Download failed.</p><a href="http://flowjam.verigames.com/game/robots.html">Go back to robots page</a></body></html>'


def submitLevel2(messageData, fileContents):
	try:
		client = Connection('api.paradox.verigames.org', 27017)
		db = client.game2api
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
				collection.update({"levelID":levelID}, {"$set": {"last_update": currentsec, "target_score": messageObj["current_score"], "revision": messageObj["revision"], "leader": messageObj["username"]}})
		return '{"solvedID":"' + str(id) + '"}'
	except:
		return sys.exc_info()



def test():
	client = Connection('api.paradox.verigames.org', 27017)
	db = client.gameapi

	return "food"
	
if sys.argv[1] == "findPlayedTutorials2":
	print(getPlayedTutorials2(sys.argv[2]))
elif sys.argv[1] == "reportPlayedTutorial2":
	print(reportPlayedTutorial2(sys.argv[2]))
elif sys.argv[1] == "reportPlayerRating2":
	print(reportPlayerRating2(sys.argv[2]))
elif sys.argv[1] == "passURL2":
	print(passURL2(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "getTokenPOST":
	print(getTokenPOST(sys.argv[2], sys.argv[3]))
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
elif sys.argv[1] == "submitLevelPOST2":
	print(submitLevel2(sys.argv[2], sys.argv[3]))


elif sys.argv[1] == "test":
	print(test())

elif sys.argv[1] == "foo":
	print("bar")
else:
    print(sys.argv[1] + " not found")
