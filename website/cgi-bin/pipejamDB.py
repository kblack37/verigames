#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import pycurl
import cStringIO
import json

def getNewLevelID():
	buf = cStringIO.StringIO()
	c = pycurl.Curl()
	c.setopt(c.WRITEFUNCTION, buf.write)
	c.setopt(c.POSTFIELDS, '')
	raURL = 'http://api.pipejam.verigames.com/ra/games/1/levels/new'
	print raURL
	c.setopt(c.URL, raURL)
	c.perform()
	print buf.getvalue()
	raObj = json.loads(buf.getvalue())
	buf.close()

	return raObj['id']

def getLevelInfo(levelID):
	buf = cStringIO.StringIO()
	c = pycurl.Curl()
	c.setopt(c.WRITEFUNCTION, buf.write)
	raURL = 'http://api.pipejam.verigames.com/ra/games/1/levels/'+levelID+'/metadata'
	c.setopt(c.URL, raURL)
	c.perform()
	raObj = json.loads(buf.getvalue())
	buf.close()

	return raObj

def isLevelActive(levelID):
	buf = cStringIO.StringIO()
	c = pycurl.Curl()
	c.setopt(c.WRITEFUNCTION, buf.write)
	raURL = 'http://api.pipejam.verigames.com/ra/games/1/levels/'+levelID+'/active'
	c.setopt(c.URL, raURL)
	c.perform()
	
	raObj = json.loads(buf.getvalue())
	buf.close()
	print raObj['active']
	return raObj['active']

def setLevelPriority(levelID, priority):
	buf = cStringIO.StringIO()
	c = pycurl.Curl()
	c.setopt(c.WRITEFUNCTION, buf.write)
	c.setopt(pycurl.PUT, 1)
	raURL = 'http://api.pipejam.verigames.com/ra/games/1/levels/'+levelID+'/priority/' + str(priority) + '/set'
	c.setopt(c.URL, raURL)
	c.perform()
	raObj = json.loads(buf.getvalue())
	buf.close()
	return raObj['success']

def setLevelActiveState(levelID, newActiveState):
	buf = cStringIO.StringIO()
	c = pycurl.Curl()
	c.setopt(c.WRITEFUNCTION, buf.write)
	c.setopt(pycurl.PUT, 1)
	if newActiveState:
		raURL = 'http://api.pipejam.verigames.com/ra/games/1/levels/'+levelID+'/activate'
	else:
		raURL = 'http://api.pipejam.verigames.com/ra/games/1/levels/'+levelID+'/deactivate'
	c.setopt(c.URL, raURL)
	c.perform()
	raObj = json.loads(buf.getvalue())
	buf.close()
	return raObj['success']

