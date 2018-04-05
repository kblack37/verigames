import urllib, urllib2, json

API = 'https://mturk-api.verigames.org'
PW_GRANT_URL = '%s/oauth/token' % API
HITS_URL = '%s/domain/6/hits' % API

def get_token():
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
        req = urllib2.Request(PW_GRANT_URL, data_enc, headers)
        print 'Obtaining access token...'
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        resp_dict = json.loads(resp_str)
        return resp_dict.get('access_token')
    except Exception as e:
        print 'Error getting response: %s\n  ...' % e
        return None

def get_all_hits(token, next_method=None):
    headers = {
        'Authorization': 'Bearer %s' % token
    }
    try:
        req = urllib2.Request(HITS_URL, headers=headers)
        print 'Loading all hits...'
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        resp_arr = json.loads(resp_str)
        hits = []
        print '\nIndex    HITStatus       createdAt                 Title'
        for i, hit in enumerate(resp_arr):
            #print '%s\n' % json.dumps(resp_arr[i])
            print '%5d  %12s  %26s   %s' % (i, resp_arr[i].get('HITStatus'), resp_arr[i].get('createdAt'), resp_arr[i].get('Title'))
    except Exception as e:
        print 'Error getting response: %s\n  ...' % e
    print ''
    if next_method is not None:
        next_method(token, resp_arr)
    else:
        cmd_line(token)

def delete_hits_by_index(token, hit_arr):
    headers = {
        'Authorization': 'Bearer %s' % token
    }
    start_indx = raw_input('Start index of hits to delete (inclusive, -1 to abort): ')
    try:
        start_indx = int(start_indx)
    except:
        cmd_line(token)
        return
    if start_indx < 0:
        cmd_line(token)
        return
    end_indx = raw_input('End index of hits to delete (inclusive): ')
    try:
        end_indx = int(end_indx)
    except:
        cmd_line(token)
        return
    for indx in range(start_indx, end_indx + 1):
        hit_id = hit_arr[indx].get('mturkHitId')
        url = '%s/hit/%s' % (API, hit_id)
        try:
            req = urllib2.Request(url, headers=headers)
            req.get_method = lambda: 'DELETE'
            print 'Deleting hit index: %s mturkHitId: %s' % (indx, hit_id)
            resp = urllib2.urlopen(req)
            resp_str = resp.read()
            print 'DELETE method response: "%s"' % resp_str
        except Exception as e:
            print 'Error getting response: %s\n  ...' % e
    print ''
    cmd_line(token)

def create_hit(token, hit_task_id, hit_title, hit_desc, hit_payment_usd='0.01', hit_level_id=None):
    hit_url = "http://ec2-184-73-33-59.compute-1.amazonaws.com/turk/index.html?taskId=%s" % hit_task_id
    if hit_level_id is not None:
        hit_url += '&name=%s' % hit_level_id
    data = {
        "taskId": hit_task_id,
        "AutoApprovalDelayInSeconds": 60,
        "autoApprove" : True,
        "Title": hit_title,
        "Description": hit_desc,
        "Reward": {"Amount": hit_payment_usd, "CurrencyCode": "USD"},
        "LifetimeInSeconds": 2592000, # 30 days
        "MaxAssignments": 500,
        "AssignmentDurationInSeconds": 259200, # 3 days
        "url": hit_url,
        "Question": "<?xml version=\"1.0\" encoding=\"UTF-8\"?><ExternalQuestion xmlns=\"http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd\">  <ExternalURL>https://s3.amazonaws.com/csfv-mturk/external-question.html</ExternalURL>  <FrameHeight>200</FrameHeight></ExternalQuestion>"
    }
    if hit_level_id is not None:
        # For real levels require tutorial qualification
        data["QualificationRequirements"] = [{
            "QualificationTypeId": "3AL15IERTIGS4PGA8GRKYE52Q87AS6",
            "Comparator": "GreaterThanOrEqualTo",
            "IntegerValue": 1,
            "RequiredToPreview": "0"
        }]
    else:
        # For tutorials grant tutorial qual
        data["QualificationsToBeGranted"] = [{
            "QualificationTypeId": "3AL15IERTIGS4PGA8GRKYE52Q87AS6",
            "IntegerValue": 1
        }]
    headers = {
        'Authorization': 'Bearer %s' % token,
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    }
    try:
        data_enc = json.dumps(data)
        print 'data_enc: "%s"' % data_enc 
        req = urllib2.Request(HITS_URL, data_enc, headers)
        print 'Creating hit...'
        resp = urllib2.urlopen(req)
        resp_str = resp.read()
        #resp_arr = json.loads(resp_str)
        print 'Response from CREATE HIT: "%s"' % resp_str
    except Exception as e:
        print 'Error getting response: %s\n  ...' % e
    cmd_line(token)

def cmd_line(token):
    cmd = raw_input('Commands: (L)ist all hits (D)elete hits by index (C)reate hits from files\n  Enter command: ').lower()
    if cmd == 'l':
        get_all_hits(token)
    elif cmd == 'd':
        get_all_hits(token, delete_hits_by_index)
    elif cmd == 'c':
        hit_task_id = int(raw_input('Task id (enter for 101): ') or 101)
        print hit_task_id
        hit_title = raw_input('Hit Title (enter for tutorial title): ') or 'University of Washington Verification Game Tutorials Task'
        print hit_title
        hit_desc = raw_input('Hit description (enter for tutorial desc): ') or 'Play our introductory tutorials to qualify for higher paying tasks and familiarize yourself with our game mechanics.'
        print hit_desc
        hit_payment_usd = raw_input('Hit payment in USD (enter for 0.01): ') or '0.01'
        print hit_payment_usd
        hit_level_id = raw_input('Hit level id for real levels (enter for none): ')
        print hit_level_id
        if not hit_level_id:
            hit_level_id = None
        create_hit(token=token, hit_task_id=hit_task_id, hit_title=hit_title, hit_desc=hit_desc, hit_payment_usd=hit_payment_usd, hit_level_id=hit_level_id)

token = get_token()
print 'Token: %s' % token
if token is not None:
    cmd_line(token)
else:
    print 'Unspecified error getting token'