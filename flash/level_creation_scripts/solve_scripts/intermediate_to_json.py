import os, json, sys
import time
					
def convertFile(intermediate_result, original_wcnf_file):

	# Get mapping of sat var ids (1->n) to original constraint vars (var:12452, etc) from comment in wcnf
	keys = []
	assignments = []
	result = {}
	with open(original_wcnf_file) as sat_in:
		for input_line in sat_in:
			input_line = input_line.strip()
			if input_line[:7] == 'c keys ':
				keys = input_line[7:].strip().split(' ')
			break
			
	with open(intermediate_result) as sat_in:
		for input_line in sat_in:
			assignments = input_line[7:].strip().split(' ')
		for sat_value_str in assignments:
			sat_value = int(sat_value_str)
			sat_id = abs(sat_value)
			if sat_id == sat_value: # if positive, set assignment to 1 = type:1
				result[keys[sat_id-1]] = 'type:1'
			else:
				result[keys[sat_id-1]] = 'type:0'
				
	return result
					
def outputResultFile(resultDict, output_file):
	with open(output_file, 'w') as asg_out:
		asg_out.write(json.dumps(resultDict))
		
if __name__ == "__main__":	

	if len(sys.argv) != 4:
		print "Takes an intermediate result produced by maxsatz, combines it with the key map from the original file, and outputs a json file with type values."
		print"\nUsage: python intermediate_to_json.py intermediate_result original_wcnf_file output_file"
		quit()
		
	intermediate_result = sys.argv[1]
	original_wcnf_file = sys.argv[2]
	output_file = sys.argv[3]
	
	resultDict = convertFile(intermediate_result, original_wcnf_file)
	
	outputResultFile(resultDict, output_file)
	