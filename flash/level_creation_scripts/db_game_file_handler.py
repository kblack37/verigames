import sys, os
from xml.dom.minidom import parse, parseString
import  datetime, time
import pymongo
import gridfs
import bson
from pymongo import Connection
from pymongo import database
from bson.objectid import ObjectId
from bson import json_util
import json

#description file looks like:
#<files version='0' property="ostrusted" type="game or turk or ...." >
#<file name="p_000100_00049945" constraints="100"  score="0"/>
#</files>


def addLevelToDB(url, infile, description_file):
	index = infile.rfind('/')
	infileroot = infile[index+1:]
	descriptionxml = parse(description_file)
	fileElem = descriptionxml.getElementsByTagName('files')
	version = fileElem[0].getAttribute("version")
	property = fileElem[0].getAttribute("property")
	type = fileElem[0].getAttribute("type")

	client = Connection(url, 27017)
	db = client.game3api
	description = None
	print "finding files"
	files = descriptionxml.getElementsByTagName('file')
	for file in files:
		levelObj = {"version": version, "property": property, "type": type, "current_score": "0", "serve": "1", "revision":"1", "leader": "New"}
		filename = file.getAttribute("name")
		levelObj["name"] = filename
		if filename == infileroot:
			description = file
			break
			fddfsf
	if description != None:
		levelObj["levelID"] = str(addFile(db, infile+".zip"))
		levelObj["assignmentsID"] = str(addFile(db, infile+"Assignments.zip"))
		levelObj["layoutID"] = str(addFile(db, infile+"Layout.zip"))
		
		base_collection = db.BaseLevels
		level_collection = db.ActiveLevels
		
		levelObj["target_score"] = description.getAttribute("score")
		levelObj["conflicts"] = description.getAttribute("constraints")
		levelObj["added_date"] = time.strftime("%c")
		levelObj["last_update"] = str(int(time.mktime(datetime.datetime.now().utctimetuple())))
		base_collection.save(levelObj)
		level_collection.save(levelObj)
		print 'saved file'
		
def addFile(db, fileName):
	print fileName
	fileobj = open(fileName, 'rb')
	contents = fileobj.read()
	fs = gridfs.GridFS(db)
	id = fs.put(contents)
	return id

def addDirectoryToDB(url, indir, description_file):
	#open description file, loop through entries, if you can find the entry file upload it
	descriptionxml = parse(description_file)
	files = descriptionxml.getElementsByTagName('file')
	for file in files:
		name = file.getAttribute("name")
		print 'adding ' + name
		if os.path.exists(indir + os.path.sep + name + '.zip'):
			addLevelToDB(url, indir + os.path.sep + name, description_file)
		else:
			print indir + os.path.sep + name + '.zip' + ' not found'
	
def addFilesToDB():
	if (len(sys.argv) < 5) or (len(sys.argv) > 5):
		print ('\n\nUsage: %s addFilesToDB url input_file_or_directory description_file\n\n  url : either api.paradox.verigames.com or api.paradox.verigames.org \n  input_file_or_directory: name of base json file, omitting ".zip" extension or directory of game files\n  description_file : xml file with file entry(ies) describing file(s)') % (sys.argv[0])
		quit()
	url = sys.argv[2]
	infile = sys.argv[3]
	description_file = sys.argv[4]
	
	if os.path.isdir(infile):
		addDirectoryToDB(url, infile, description_file)
	else:
		addLevelToDB(url, infile, description_file)
		
#this doesn't work for me, maybe you will have better luck, I have to use Java to delete things
def removeCurrentFiles():
	if (len(sys.argv) < 3) or (len(sys.argv) > 3):
		print ('\n\nUsage: %s removeCurrentFiles url\n\n  url : either api.paradox.verigames.com or api.paradox.verigames.org') % (sys.argv[0])
		quit()
	url = sys.argv[2]

	try:
		client = Connection(url, 27017)
		db = client.game2api
		level_collection = db.ActiveLevels
		level_collection.delete_many()
	except:
		print sys.exc_info()
		
def createDescriptionFile():
	if (len(sys.argv) < 7) or (len(sys.argv) > 7):
		print ('\n\nUsage: python db_game_file_handler.py createDescriptionFile input_path, output_file version property type(currently "game" or "turk")')
		quit()
	inputpath = sys.argv[2]
	outputfile = sys.argv[3]
	version = sys.argv[4]
	property = sys.argv[5]
	type = sys.argv[6]

	pathlen = len(inputpath)

	descriptionFile = open(outputfile,'w')
	descriptionFile.write('<files version="'+version+'" property="'+property+'" type="'+type+'" >\n')
		
	cmd = os.popen('ls %s/*Assignments.json' % inputpath) #find Assignments files in an attempt to find unique named files for each level
	for fullfilename in cmd:
		print fullfilename
		startfilenameindex = fullfilename.rfind('/')
		endfilenameindex = fullfilename.rfind('A')
		filename = fullfilename[startfilenameindex+1:endfilenameindex]
		print filename
		numWidgetsStartIndex = filename.find('_')+1
		numWidgetsEndIndex = filename.find('_', numWidgetsStartIndex)
		numWidgets = str(int(filename[numWidgetsStartIndex:numWidgetsEndIndex])) #get rid of leading zeros
		print numWidgets
		score = 0
		#conflicts get updated during game play, links are ignored currently as widgets mostly predict size of level
		descriptionFile.write('<file name="'+filename+'" constraints="'+numWidgets+'"  score="'+str(score)+'"/>\n')

	descriptionFile.write('</files>\n')
	
### Command line interface ###
if __name__ == "__main__":

	functionToCall = sys.argv[1]
	
	if functionToCall == "removeCurrentFiles":
		removeCurrentFiles()
	elif functionToCall == "addFilesToDB":
		addFilesToDB()
	elif functionToCall == "createDescriptionFile":
		createDescriptionFile()
	elif functionToCall == "downloadBestScoringFiles":
		downloadBestScoringFiles()
	else:
		print 'function not found'
		
		
