import sys, time

start_time = None
last_time = None

def print_step(step):
    global start_time, last_time
    curr_time = time.time()
    if start_time == None:
        start_time = curr_time
    if last_time != None:
        print ' ... took %0.2fs' % (curr_time - last_time)
    last_time = curr_time
    if step == None:
        print 'done. total %0.2fs' % (curr_time - start_time)
    else:
        print step, '...'
    sys.stdout.flush()

def get_vals(js, lst):
    for key, val in js.iteritems():
        if key not in lst:
            raise RuntimeError('JSON has unrecognized key ' + key)

    ret = []
    for ls in lst:
        if not js.has_key(ls):
            raise RuntimeError('JSON missing key ' + ls)
            
        ret.append(js[ls])

    if len(ret) == 1:
        return ret[0]
    else:
        return ret
