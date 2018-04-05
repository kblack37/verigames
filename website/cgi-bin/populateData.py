#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import pycurl
import cStringIO
import json
from ordereddict import OrderedDict

import sys
import pymongo
import bson
from pymongo import Connection
from pymongo import database
from bson.objectid import ObjectId

#pull a list of users who have submitted levels, look for ones who aren't in groups, create default groups for them
def populateDefaultGroups():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	collection = db.SubmittedLevels
	coll2 = db.Group_Members
	coll3 = db.Groups

	for player in collection.distinct('player'):
		groupName = ""
		playerID = ""
		exists = coll2.find({"userID":player}).count()
		if exists == 0:
			#get their name from the server
			memberData = getMemberData(player)
			groupID = str(coll3.insert({"name":memberData[u'firstName'] + " " + memberData[u'lastName'], "type":1, "status":1}))
			coll2.insert({"groupID":groupID, "userID":player, "user_name": memberData[u'firstName'] + " " + memberData[u'lastName'], "isAdmin": 0, "isOwner": 1})

#make sure all users have at least one group_member record with a user_name set for listing purposes
def populateUserNames():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	groupMemberColl = db.Group_Members
	groupMemberNamesColl = db.Group_Members
	
	for player in groupMemberColl.distinct('userID'):
		exists = groupMemberNamesColl.find({"userID": player, "user_name": {"$exists":"true"}}).count()
		if exists == 0:
			memberData = getMemberData(player)
			groupMemberColl.update({"userID":player}, {"$set": {"user_name" : memberData[u'firstName'] + " " + memberData[u'lastName']}})


			
#calculate top score per level per group, and award weighted points based on placing, then populate Scores collections
def populateScores():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.gameapi
	submittedLevelsColl = db.SubmittedLevels
	levelTotalsColl = db.LevelTotals
	leaderTotalsColl = db.LeaderTotals
	groupColl = db.Groups
	groupMemberColl = db.Group_Members
	
	currLevel = ""
	currentPoints = 10
	levelScores = dict()
	
	levelTotalsColl.remove()
	
	for level in submittedLevelsColl.find().sort("xmlID", -1):
		if level["xmlID"] != currLevel:
			if currLevel != "":
				if len(levelScores) > 0:
					#sort the scores for the current level and write them to the appropriate collections
					scoresToWrite = OrderedDict(sorted(levelScores.items(), key=lambda t: t[1], reverse=True))
					currentScore = -1
					currentGroups = []
					for group,score in scoresToWrite.items():
						if currentPoints > 2: 
							if score == currentScore:
								currentGroups.append(group)
							else:
								if currentScore > -1:
									for groupid in currentGroups:
										levelTotalsColl.insert({"xmlID":currLevel, "groupID":groupid, "score":currentScore, "points":currentPoints})
									currentPoints -= 1
									currentGroups = []
								currentGroups.append(group)
								currentScore = score					
						else:
							levelTotalsColl.insert({"xmlID":currLevel, "groupID":group, "score":score, "points":currentPoints})
							
					for groupid in currentGroups:
						levelTotalsColl.insert({"xmlID":currLevel, "groupID":groupid, "score":currentScore, "points":currentPoints})
						
					currentPoints = 10
					levelScores = dict()
			currLevel = level["xmlID"]
			
		#check that this is the first or highest score for the player's group to be counted, if so add it
		playerGroup = groupMemberColl.find_one({"userID": level["player"], "active":1})
		if playerGroup != None:
			if playerGroup["groupID"] not in levelScores or level["score"] > levelScores[playerGroup["groupID"]]:
				levelScores[playerGroup["groupID"]] = level["score"]	
	
	if currLevel != "":
		if len(levelScores) > 0:
			#sort the scores for the current level and write them to the appropriate collections
			scoresToWrite = OrderedDict(sorted(levelScores.items(), key=lambda t: t[1]))
			currentScore = -1
			currentGroups = []
			for group,score in scoresToWrite.items():
				if currentPoints > 2: 
					if score == currentScore:
						currentGroups.append(group)
					else:
						if currentScore > -1:
							for groupid in currentGroups:
								levelTotalsColl.insert({"xmlID":currLevel, "groupID":groupid, "score":currentScore, "points":currentPoints})
							currentPoints -= 1
							currentGroups = []
						currentGroups.append(group)
						currentScore = score					
				else:
					levelTotalsColl.insert({"xmlID":currLevel, "groupID":group, "score":score, "points":currentPoints})
					
			for group in currentGroups:
				levelTotalsColl.insert({"xmlID":currLevel, "groupID":group, "score":currentScore, "points":currentPoints})
			currentPoints = 10
			levelScores = dict()
	
	#now per-level high scores are populated, next calculate overalls
	
	leaderTotalsColl.remove()
	for groupObj in groupColl.find():
		groupTotal = 0
		for groupScore in levelTotalsColl.find({"groupID":str(groupObj["_id"])}):
			groupTotal += groupScore["points"]
		
		if groupTotal > 0:
			leaderTotalsColl.insert({"groupName": groupObj["name"], "groupScore": groupTotal})
	
def getMemberData(memberID):
	buf = cStringIO.StringIO()
	c = pycurl.Curl()
	c.setopt(c.WRITEFUNCTION, buf.write)
	raURL = 'http://api.flowjam.verigames.com/api/users/'+str(memberID)
	c.setopt(c.URL, raURL)
	c.perform()
	raObj = json.loads(buf.getvalue())
	buf.close()

	return raObj
	

populateDefaultGroups()
populateUserNames()
populateScores()