Standard tasks:
(Read the files for more detail)

Create a level from a wcnf, cnf, or json file:

	From wcnf or cnf, run makeConstraintFile.py to create a json file.
	
	From a json file created by Mike's team
		run cnstr/process_constraint_json.py foo, where foo is the root name of the json file
	
	From a level file (constraint of the type "c1 <= v1")
		run ... (not finished...)

	From DIMACS cnf, run makeConstraintFromDIMACS.py to create a json file. Then, run cnstr/process_constraint_json.py on the result to create the level files.

Add a level to the database:

	There's a python script at  level_creation_scripts/AddLevelToDB.py that has pymongo, gridfs and bson as dependencies. You can install them yourself, use the versions on the staging server, or find my packages here:

	PipeJam\website\cgi-bin\thirdparty\

	The python script should do most things, but for me it doesn't successfully remove files from the db, so I have a java jar to do that. (In a newer version of pymongo, collection.remove has been depreciated, and there's a delete_many call. It might work better.)

	The steps are:

	1) Create and zip game files.
		
		To create them, see above.
		To zip them, see below section: "Zip game files, individually".

	2) Remove old files
		python db_game_file_handler.py removeCurrentFiles api.paradox.verigames.org

		you can of course change the .org to .com for production. As I mentioned, this doesn't work for me, probably a permissions issue.

		There is a jar file at level_creation_scripts/RemoveActiveLevels.jar.txt. Remove the .txt extension, and then run it thusly:

		java -jar RemoveActiveLevels.jar api.paradox.verigames.org true

		If you want just to list files, leave off the last parameter. Again, you can use .com.

		If you get desperate, my long-in-the-tooth Swiss-army knife Java files are at PipeJam\website\html\java\MongoAndRAClient. 
		The code is ever in flux, but mostly you want to look at the main method in MongoTestBed.java. You should be able to figure it out.

	3) Prepare a description file

		python db_game_file_handler.py createDescriptionFile input_dir, outputfile version property type

		input dir : the game file dir
		outputfile : the name of the xml output file
		version : 14, 15, 16 etc...
		property : ostrusted, interned, etc
		type: 'game' or 'turk'

		These are identical for both production and turk, except for the first line which contains the type, so I often just change it by hand.

	4) Upload files

		python db_game_file_handler.py addFilesToDB api.paradox.verigames.org zipped_game_files_dir description_file_path

Download and combine played assignment files:

	
Zip game files, individually:
	
	zipall.py

		Zips a directory of files into individual zip files. Unix only. Usually I upload the json files to a server 
		(upload the zipped collection is far faster, then unzip them) and then run the script, zip the output together, 
		and then copy them back down, as I don't have a Windows equivalent.

		python zipall.py input_directory

		The output directory is the same as the input_directory.
	
Autosolve levels:

	Check the readme in the solve_scripts directory.
	



