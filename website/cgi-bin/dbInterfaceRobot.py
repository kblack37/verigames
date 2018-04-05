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
import shutil

def getLevelDirectoryContents():
	fileList = ["<ul>"]
	listing = next(os.walk('/var/www/html/game/levels'))[2]
	for file1 in listing:
		fileList.append("<li><a href='/game/levels/" + str(file1) + "'>" + str(file1) + "</a></li>")

	fileList.append("<ul>")
	return ''.join(fileList)

def getFile2NonEncoded(fileID):
	try:
		#fileObj = json.loads(jsonFileObjStr)
		#fileID = fileObj['fileID']
		#filename = fileObj['filename']
		client = Connection('api.flowjam.verigames.com', 27017)
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


def saveRobotFilePOST(messageData, filename, filepath):
	try:
		with open(filepath, 'r') as file1:
			data = file1.read()
		
		client = Connection('api.flowjam.verigames.com', 27017)
		db = client.game2api
		fs = gridfs.GridFS(db)
		messageObj = json.loads(messageData)
		fileID = str(fs.put(data))
		messageObj["fileID"] = str(fileID)
		collection = db.RobotSolutions
		id = collection.insert(messageObj)
	
		return '<html><head/><body><p>File Uploaded.</p><a href="http://flowjam.verigames.com/game/robots.html">Go back to robots page</a></body></html>'

	except:
		e = sys.exc_info()
		return '<html><head/><body><p>' + str(e) + ' Upload failed.</p><a href="http://flowjam.verigames.com/game/robots.html">Go back to robots page</a></body></html>'

def getSolvedRobotLevels():
	client = Connection('api.flowjam.verigames.com', 27017)
	db = client.game2api
	fs = gridfs.GridFS(db)
	collection = db.RobotSolutions

	fileList = []
	for solution in collection.find():
		fileList.append("<li><a id='foo' href='/game/solvedlevel/" + solution['fileID'] + ".zip' onclick='createDownloadFile(\"" + solution["fileID"] + "\")'>" + solution['uploaded_file'] + "</a></li>")

	fileList.append("<ul>")
	return ''.join(fileList)


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
if sys.argv[1] == "getFileListRobot":
	print(getLevelDirectoryContents())
	print(getFile2(sys.argv[2]))
elif sys.argv[1] == "getFile2NonEncoded":
	print(getFile2NonEncoded(sys.argv[2]))
elif sys.argv[1] == "saveRobotFilePOST":
	print(saveRobotFilePOST(sys.argv[2], sys.argv[3], sys.argv[4]))
elif sys.argv[1] == "getFileSolvedRobotLevels":
	print(getSolvedRobotLevels())

elif sys.argv[1] == "test":
	print(test())

elif sys.argv[1] == "foo":
	print("bar")
else:
    print(sys.argv[1] + " not found")
