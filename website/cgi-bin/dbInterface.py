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

def getOverallLeaders():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.LeaderTotals
	concatList = []
	for leader in collection.find().sort("groupScore", -1):
		concatList.append('{ "GroupName" : "')
		concatList.append(leader[u'groupName'].encode('ascii', 'replace'))
		concatList.append('", "GroupScore" : ')
		concatList.append(str(leader["groupScore"]))
		concatList.append('},')
	return '{ Leaders: [' + ''.join(concatList).strip(',') + '] }'

def getLevelList():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.Level
	concatList = []
	for level in collection.find():
		concatList.append('{ "LevelName" : "')
		concatList.append(str(level["name"]))
		concatList.append('", "LevelNumber" : ')
		concatList.append('"' + str(level["xmlID"]) + '"')
		concatList.append('},')
	return '{ Levels: [' + ''.join(concatList).strip(',') + '] }'

def getGroupList():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.Groups
	concatList = []
	for group in collection.find({"status":1}):
		concatList.append('{ "GroupName" : "')
		concatList.append(group[u'name'].encode('ascii', 'replace'))
		concatList.append('", "GroupID" : ')
		concatList.append('"' + str(group["_id"]) + '"')
		concatList.append('},')
	return '{ Groups: [' + ''.join(concatList).strip(',') + '] }'
	
def getTopScoresForLevel(levelID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.LevelTotals
	groupColl = db.Groups
	concatList = []
	for level in collection.find({"xmlID":str(levelID)}).sort("score", -1):
		groupName = ""
		group = groupColl.find_one({"_id":ObjectId(level["groupID"])})
		if group != None:
			groupName = group["name"].encode('ascii', 'replace')
		else:
			groupName = "New Player"
		concatList.append('{ "GroupName" : "')
		concatList.append(groupName)
		concatList.append('", "Points" : ')
		concatList.append(str(level["points"]))
		concatList.append(', "Score" : ')
		concatList.append(str(level["score"]))
		concatList.append('},')
	return '{ Scores: [' + ''.join(concatList).strip(',') + '] }'

def getPlayerGroup(playerID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupMemberColl = db.Group_Members
	groupColl = db.Groups
	concatList = []
	currentMemberRecord = groupMemberColl.find_one({"userID":playerID})
	currentGroup = groupColl.find_one({"_id":ObjectId(currentMemberRecord["groupID"])})
	concatList.append('{ "GroupName" : "')
	concatList.append(currentGroup["name"].encode('ascii', 'replace'))
	concatList.append('", "Type" : ')
	concatList.append(str(currentGroup["type"]))
	concatList.append(', "ID" : "')
	concatList.append(str(currentGroup["_id"]))
	concatList.append('", "Admin" : ')
	concatList.append(str(currentMemberRecord["isAdmin"]))
	concatList.append(', "Members": [')
	comma = ""
	for member in groupMemberColl.find({"groupID":ObjectId(currentGroup["_id"]), "userID": {"$ne": playerID}}):
		concatList.append(comma)
		concatList.append('{ "MemberName" : "')
		concatList.append(member["user_name"].encode('ascii', 'replace'))
		concatList.append('", "Admin" : ')
		concatList.append(str(member["isAdmin"]))
		concatList.append(', "ID": "')
		concatList.append(str(member["userID"]))
		concatList.append('" }')
		comma = ","
	concatList.append('] }')
	return '{ PlayerGroup: [' + ''.join(concatList).strip(',') + '] }'
	
def getMessagesForPlayer(playerID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	messagesColl = db.Messages
	groupMemberColl = db.Group_Members
	concatList = []
	for message in messagesColl.find({"userID":playerID}).sort("date",-1):
		senderName = "New player"
		groupMember = groupMemberColl.find_one({"userID":message["senderID"]})
		if groupMember != None:
			senderName = groupMember["user_name"].encode('ascii', 'replace')
	
		concatList.append('{ "Title" : "')
		concatList.append(message["title"].encode('ascii', 'replace'))
		concatList.append('", "Content" : "')
		concatList.append(message["content"].encode('ascii', 'replace'))
		concatList.append('", "Sender" : "')
		concatList.append(senderName)
		concatList.append('", "IsRead" : ')
		concatList.append(message["isRead"])
		concatList.append('},')
	return '{ Messages: [' + ''.join(concatList).strip(',') + '] }'

def removeFromCurrentGroup(userID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupColl = db.Groups
	groupMembersColl = db.Group_Members
	userName = ""
	currentGroupMem = groupMembersColl.find_one({"userID":userID})
	if currentGroupMem != None:
		#check if it is their default group, if so then that will need to be deactivated
		currentGroup = groupColl.find_one({"_id":ObjectId(currentGroupMem["groupID"])})
		if currentGroup != None and currentGroup['type'] == 1:
			groupColl.update({"_id":ObjectId(currentGroupMem["groupID"])}, {"$set": {"status": 0}})
		userName = currentGroupMem['user_name']
		groupMembersColl.remove({"userID":groupID})
	return userName
	
def createGroup(groupData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupColl = db.Groups
	groupMembersColl = db.Group_Members
	groupObj = json.loads(groupData)
	removeFromCurrentGroup(groupObj[u'user_id'])
	groupID = str(groupColl.insert({"name":groupObj[u'group_name'], "type":groupObj[u'group_type'], "status":1}))
	groupMembersColl.insert({"active": 1, "groupID": groupID, "isAdmin": 1, "isOwner": 1, "userID": groupObj[u'user_id'], "user_name": groupObj[u'user_name']})
	return '{ GroupID: ' + groupID + '}'
	
def joinGroup(joinData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupMembersColl = db.Group_Members
	memberObj = json.loads(joinData)
	removeFromCurrentGroup(memberObj[u'user_id'])
	groupMembersColl.insert({"active": 1, "groupID": memberObj[u'group_id'], "isAdmin": 1, "isOwner": 1, "userID": memberObj[u'user_id'], "user_name": memberObj[u'user_name']})
	return '{ true }'

def changeMembership(membershipData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupMembersColl = db.Group_Members
	memberObj = json.loads(membershipData)
	groupMembersColl.update({"groupID": memberObj[u'group_id'], "userID": memberObj[u'user_id']}, {"$set": {"isAdmin": memberObj[u'admin'], "isOwner": memberObj[u'owner']}})
	return '{ true }'

def acceptInvite(messageID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupMembersColl = db.Group_Members
	messagesColl = db.Messages
	invite = messagesColl.find_one({"_id":ObjectId(messageID)})
	if invite != None:
		if invite['isInvite'] == 1: #deactivate old group, join new one
			userName = removeFromCurrentGroup(invite["toID"])
			groupMembersColl.insert({"active": 1, "groupID": invite['groupID'], "isAdmin": invite['makeAdmin'], "isOwner": 0, "userID": invite["toID"], "user_name": userName})
			messagesColl.remove({"_id":ObjectId(messageID)})
	return '{ true }'

#TODO: check that this user hasn't submitted a message in the previous X seconds, to prevent spamming?
def sendGroupMessage(messageData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupMembersColl = db.Group_Members
	messagesColl = db.Messages
	messageObj = json.loads(messageData)
	if messageObj[u'toID'] != -1:
		messagesColl.insert({"fromID": messageObj[u'fromID'], "toID": messageObj[u'toID'], "groupID": messageObj[u'groupID'], "body": messageObj[u'body'], "isInvite": messageObj[u'invite'], "isRead": 0, "makeAdmin": messageObj[u'makeAdmin'], "sentDate": time.time()})
	else:
		for member in groupMembersColl.find({"groupID":messageObj[u'groupID']}):
			messagesColl.insert({"fromID": messageObj[u'fromID'], "toID": member["userID"], "body": messageObj[u'body'], "isInvite": 0, "isRead": 0, "sentDate": time.time()})

def updateGroupMessage(updateData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	messagesColl = db.Messages
	updateObj = json.loads(updateData)
	if updateObj[u'type'] == 0:
		messagesColl.update({"_id": ObjectID(updateObj[u'id'])}, {"$set": {"isRead": 1}})
	elif updateObj[u'type'] == 1:
		messagesColl.remove({"_id": ObjectID(updateObj[u'id'])})
	
def getScoresForGroup(groupID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	levelTotalColl = db.LevelTotals
	levelColl = db.Level
	concatList = []
	for level in levelTotalColl.find({"groupID":groupID}).sort("score",-1):
		levelName = ""
		levelData = levelColl.find_one({"xmlID":level["xmlID"]})
		if levelData != None:
			levelName = levelData["name"]
		else:
			levelName = "Retired level"
		concatList.append('{ "LevelName" : "')
		concatList.append(levelName)
		concatList.append('", "Points" : ')
		concatList.append(str(level["points"]))
		concatList.append(', "Score" : ')
		concatList.append(str(level["score"]))
		concatList.append('},')
	return '{ Scores: [' + ''.join(concatList).strip(',') + '] }'

def findJoinableGroup(groupName):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.Groups
	concatList = []
	#group types: 0- public, 1- default personal, 2- private visible, 3- private invite-only
	findClause = {"$or": [ { "type": 0}, {"type": 2} ]}
	if groupName != "all":
		findClause = {"$or": [ { "type": 0}, {"type": 2} ], "name": {"$regex": groupName, "$options": "i"}}
		
	for group in collection.find(findClause):
		concatList.append('{ "GroupName" : "')
		concatList.append(group[u'name'].encode('ascii', 'replace'))
		concatList.append('", "GroupID" : ')
		concatList.append('"' + str(group["_id"]) + '"')
		concatList.append(', "Type" : ')
		concatList.append('"' + str(group["type"]) + '"')
		concatList.append('},')
	return '{ Groups: [' + ''.join(concatList).strip(',') + '] }'

def getPlayedTutorials(playerID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.CompletedTutorials
	concatList = []
	for level in collection.find({"playerID":playerID}):
		item = json.dumps(level, default=json_util.default)
		concatList.append(item)
		concatList.append(',')
	return '///[' + ''.join(concatList).strip(',') + ']'
	
def reportPlayedTutorial(messageData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.CompletedTutorials
	messageObj = json.loads(messageData)
	collection.insert(messageObj)
	return '///success'

def deleteSavedLevel(id):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SavedLevels
	collection.remove({"_id":ObjectId(id)})
	return '///success'

def getSavedLevels(playerID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SavedLevels
	concatList = []
	for level in collection.find({"player":playerID}):
		#print level
		item = json.dumps(level, default=json_util.default)
		concatList.append(item)
		concatList.append(',')
	return '///[' + ''.join(concatList).strip(',') + ']'

def getActiveLevels():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.Level
	concatList = []
	count = 1
	#limit number returned to 30
	currentcount = 0
	randomstartcount = random.randint(0,30)
	maxcount = 30 + randomstartcount
	for level in collection.find({ "submitted": { "$ne": "v6test" }, "version" : "v6test"}):
		count += 1
		if count > randomstartcount:
			item = json.dumps(level, default=json_util.default)
			concatList.append(item)
			concatList.append(',')
			if count > maxcount:
				break
	return '///[' + ''.join(concatList).strip(',') + ']'

def getCompletedLevels(playerID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.CompletedLevels
	concatList = []
	for level in collection.find({"playerID":playerID}):
		item = json.dumps(level, default=json_util.default)
		concatList.append(item)
		concatList.append(',')
	return '///[' + ''.join(concatList).strip(',') + ']'

def reportPlayerRating(messageData):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.CompletedLevels
	messageObj = json.loads(messageData)
	collection.insert(messageObj)
	return 'success'

def getFile(fileID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	fs = gridfs.GridFS(db)
	f = fs.get(ObjectId(fileID)).read()
	encoded = base64.b64encode(f)
	return encoded

def getSavedLayouts(xmlID):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SubmittedLayouts
	concatList = []
	for level in collection.find({"xmlID":xmlID}):
		item = json.dumps(level, default=json_util.default)
		concatList.append(item)
		concatList.append(',')
	return '///[' + ''.join(concatList).strip(',') + ']'

def saveLayout(messageData, fileContents):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SubmittedLayouts
	fs = gridfs.GridFS(db)
	messageObj = json.loads(messageData)
	decoded = base64.b64decode(fileContents)
	test = fs.put(decoded)
	messageObj[0]["layoutID"] = str(test)
	collection.insert(messageObj)
	return 'success' #no '/' as this path contains a non-json callback

def saveLevel(messageData, fileContents):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SavedLevels
	fs = gridfs.GridFS(db)
	messageObj = json.loads(messageData)
	decoded = base64.b64decode(fileContents)
	test = fs.put(decoded)
	messageObj["constraintsID"] = str(test)
	collection.insert(messageObj)
	return '///success'

def submitLevel(messageData, fileContents):
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SubmittedLevels
	fs = gridfs.GridFS(db)
	messageObj = json.loads(messageData)
	decoded = base64.b64decode(fileContents)
	test = fs.put(decoded)
	messageObj["constraintsID"] = str(test)
	id = collection.insert(messageObj)

	#mark served level as completed
	collection = db.Level
	xmlID = messageObj["xmlID"]
	collection.update({"xmlID":xmlID}, {"$set": {"submitted": "v6test"}})
	return 'success'

#pass url to localhost:3000
def passURL(url):
	resp = requests.get('http://localhost:3000' + url)
	responseString = resp.json()
	if len(responseString ) != 0:
		return responseString
	else:
		return 'success'

def passURLPOST(url, postdata):
	resp = requests.post('http://localhost:3000' + url, data=postdata, headers = {'content-type': 'application/json'})
	responseString = resp.json()

	if len(responseString ) != 0:
		return responseString 
	else:
		return 'success'

def test():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi

	#mark served level as completed
	collection = db.Level
	xmlID = "52f3cb1ba8e0d6c8940ca999"
	obj = collection.find_one({"xmlID":xmlID})
	collection.update({"xmlID":xmlID}, {"$set": {"submitted": "v6test"}})

	return "food"
	
#CERTAINLY NO REASON TO INCLUDE A SWITCH FUNCTION IN PYTHON
if sys.argv[1] == "overallLeaders":
    print(getOverallLeaders())
elif sys.argv[1] == "levelList":
	print(getLevelList())
elif sys.argv[1] == "groupList":
	print(getGroupList())
elif sys.argv[1] == "topForLevel":
	print(getTopScoresForLevel(sys.argv[2]))
elif sys.argv[1] == "groupScores":
	print(getScoresForGroup(sys.argv[2]))
elif sys.argv[1] == "getPlayerGroup":
	print(getPlayerGroup(sys.argv[2]))
elif sys.argv[1] == "playerMessages":
	print(getMessagesForPlayer(sys.argv[2]))
elif sys.argv[1] == "removeFromGroup":
	print(removeFromCurrentGroup(sys.argv[2]))
elif sys.argv[1] == "createGroup":
	print(createGroup(sys.argv[2]))
elif sys.argv[1] == "joinGroup":
	print(joinGroup(sys.argv[2]))
elif sys.argv[1] == "changeMembership":
	print(changeMembership(sys.argv[2]))
elif sys.argv[1] == "acceptInvite":
	print(acceptInvite(sys.argv[2]))
elif sys.argv[1] == "sendGroupMessage":
	print(sendGroupMessage(sys.argv[2]))	
elif sys.argv[1] == "updateGroupMessage":
	print(updateGroupMessage(sys.argv[2]))	
elif sys.argv[1] == "findJoinableGroup":
	print(findJoinableGroup(sys.argv[2]))
elif sys.argv[1] == "findPlayedTutorials":
	print(getPlayedTutorials(sys.argv[2]))
elif sys.argv[1] == "reportPlayedTutorial":
	print(reportPlayedTutorial(sys.argv[2]))
elif sys.argv[1] == "deleteSavedLevel":
	print(deleteSavedLevel(sys.argv[2]))
elif sys.argv[1] == "getSavedLevels":
	print(getSavedLevels(sys.argv[2]))
elif sys.argv[1] == "getActiveLevels":
	print(getActiveLevels())
elif sys.argv[1] == "getCompletedLevels":
	print(getCompletedLevels(sys.argv[2]))
elif sys.argv[1] == "reportPlayerRating":
	print(reportPlayerRating(sys.argv[2]))
elif sys.argv[1] == "getFile":
	print(getFile(sys.argv[2]))
elif sys.argv[1] == "getSavedLayouts":
	print(getSavedLayouts(sys.argv[2]))
elif sys.argv[1] == "saveLayoutPOST":
	print(saveLayout(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "saveLevelPOST":
	print(saveLevel(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "submitLevelPOST":
	print(submitLevel(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "passURL":
	print(passURL(sys.argv[2]))
elif sys.argv[1] == "passURLPOST":
	print(passURLPOST(sys.argv[2], sys.argv[3]))
elif sys.argv[1] == "getFileList":
	print(getLevelDirectoryContents())

elif sys.argv[1] == "test":
	print(test())

elif sys.argv[1] == "foo":
	print("bar")
else:
    print(sys.argv[1] + " not found")
