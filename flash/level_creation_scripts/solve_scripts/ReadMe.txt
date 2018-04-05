Tasks:

Create wcnf files:

	Use json_to_wcnf.py

		python json_to_wcnf.py input_path output_path
		
			input_path - directory that contains created game level files, specifically the base json file.
			output_path - directory for the created wcnf files.
		
Autosolve wcnf files:

	For a directory, use autosolve_wcnfs.py
	
		python autosolve_wcnfs.py input_path output_assignment_file output_solver_results_path
		
			input_path - directory that contains wcnf files.
			output_assignment_file - the resultant assignments.
			output_path - directory that stores solver results for the individual solved files.
			
	For an individual file, use:
		maxsatz/maxsatz.exe  [-s] input_instance [-i dirpath]
			-s: treat input instance is string, else as a file.
			-i: output intermediate results to specified directory, else don't output results.
			
		If you are using an intermediate result file, (i.e. you don't want to wait forever for final results):
			
			python intermediate_to_json.py intermediate_to_json.py intermediate_result original_wcnf_file output_file
			
Combine solutions:

	Autosolved files from above differ in format from the Assignments files produced by the game,
	thus the script allows two input folder paths. Also, if you have a partial result, you need to 
	convert that first.
	
	Use combineAssignmentFiles.py
	
	python combineAssignmentFiles.py input_path output_assignment_file output_solver_results_path
		
			input_path - directory that contains wcnf files.
			output_assignment_file - the resultant assignments.
			output_path - directory that stores solver results for the individual solved files.