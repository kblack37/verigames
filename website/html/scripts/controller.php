<?php

//import globals
include('./globals.php');

/*
 * Parses the information sent from the ajax request.  If a request for a particular function 
 * is passed then that function will be executed on the folder with the passed guid identifier.
 * If no argument for a function was passed then it is assumed that a file upload operation is
 * being performed and will attempt to move any files sent to the server. 
 */
if (isset($_REQUEST["function"])) {
    $function = $_REQUEST["function"];
    $guid = $_REQUEST["guid"];
    $script = FALSE;
    if (isset($_REQUEST["script"]))
        $script = $_REQUEST["script"];
    //check for particular function
    if (!strcmp($function, "unzip")) {
        $result = unzipFiles($guid);
    } else if (!strcmp($function, "compile")) {
        $result = checkFileValidity($guid);
    } else if (!strcmp($function, "xml") && $script) {
        $result = createXML($guid, $script);
    } else if (!strcmp($function, "cleanup")) {
        cleanup($guid, FALSE);
        $result = 1;
    } else if (!strcmp($function, "game") && $script) {
        $result = createGameFiles($guid, $script);
    }else if (!strcmp($function, "gameFromXML") && $script) {
        $result = createGameFilesFromXML($guid, $script);
    }else if (!strcmp($function, "cleanup_all")) {
       cleanup($guid, false);
       $result = "all_removed";
    }

    //respond with success or the location of the error file
    if ($result == 1)
        print("SUCCESS");
    else { 
        print($result);
    }
} else {  
    $result = moveFiles();
    if (!$result)
        print("Error moving files");
}

/*
* Function that will move the file passed to the server from the client and move 
* it into their corresponding folder specified by the query string id parameter. 
* if the folder doesn't already exist it will create a new folder with the same name
* as their unique guid. If there were no errors transferring the files the function
* will return true, false otherwise. 
*/
function moveFiles() {
    $response = TRUE;
    $tempFile = $_FILES['Filedata']['tmp_name'];

    $targetPath = UPLOADS_DIRECTORY.$_REQUEST['folder']."/";
    $targetFile =  $targetPath . $_FILES['Filedata']['name'];
    if (!file_exists($targetPath)) {
        if (!mkdir($targetPath)) {
            $response = FALSE;
        }
        chmod($targetPath, 0777);
    }

    if (!move_uploaded_file($tempFile,$targetFile)) {
        $response = FALSE;
    }

    return $response;
}


/*
* Function that will unzip the .zip file the user uploaded. Function will call the unix
* unzip utility and output all the files to the users unique folder determined by the 
* $id parameter passed.  The $id parameter should be a unique guid.  The function will
* print the status of the unzipping ot the user in the format of an html table row. 
*/
function unzipFiles($id) {
    $path = UPLOADS_DIRECTORY . "/" . $id . "/";
    if (file_exists($path)) {
        $handle = popen('unzip -o `find ' . $path . ' -name "*.zip"` -d ' . $path, 'r');
        pclose($handle);
        return TRUE;
    } else {
        return "File or directory does not exist!";
	}
}


/*
* Function to confirm if the .java files uploaded are valid and will compile.  It
* will run the javac Java compiler on each of the .java files uploaded by the user. 
* All the javac error output is saved in a file called output.txt in the users folder.
* If the folder is empty after the compile process then they compiled successfully, otherwise
* the compile process failed and it will display the error output to the user. Accepts
* a parameter $id, that represents the users unique folder guid. 
*/
function checkFileValidity($id){
    $path = UPLOADS_DIRECTORY."/".$id;

    system('javac -Xlint:none -classpath .:' . VERIGAMES_JAR . ' `find ' .
                $path . ' -name "*.java"` 2> ' . $path . '/'. COMPILE_OUTPUT);

    //display compile status
    return checkErrorOutput($path, COMPILE_OUTPUT);
}

/*
* Function creates the xml file that will be used with the flash game files.  It depends on the
* verigames.sh script file.  It will copy over the World.xml and the inference.jaif file created
* by the verigames.sh file.  It will return a 1 if the file was created successfully, otherwise
* it will return a 0. 
*/
function createXML($id, $script) {
    	$path = UPLOADS_DIRECTORY . "/" . $id;

    	$command = 'sh ' . getcwd() . "/typecheckers/" . $script . ' `find ' . $path . ' -name "*.java"` > ' .
                $path . '/' . XML_LOG .' 2>&1';
    	exec($command);

	//copy world.xml file to $path
	exec('cp ' . SCRIPT_PATH .'World.xml '  . $path . '/World.xml');
	exec('cp ' . SCRIPT_PATH .'inference.jaif '  . $path . '/inference.jaif');



	return 1;
}

/*
* Function creates the xml file that will be used with the flash game files.  It depends on the
* verigames.sh script file.  It will copy over the World.xml and the inference.jaif file created
* by the verigames.sh file.  It will return a 1 if the file was created successfully, otherwise
* it will return a 0. 
*/
function createGameFiles($id, $script) {
	if (
		file_exists($path . INFERENCE_LOC) && 
		file_exists($path . WORLD_XML_LOC)) 
	{
		//break world into separate levels
		//get level ID from database
		//loop over all newly created worlds (containing only one level each) and
		//measure them, creating a file with that info
		//all this stuff below
		//then store in RA and database
		//then show rename and activate screen, and do that

		$path = UPLOADS_DIRECTORY . $id;
		$gamefilepath = UPLOADS_DIRECTORY . $id . '/gamefiles';

    		//Create the game files
		exec('mkdir ' . $gamefilepath);

     		$command = 'python ' . SCRIPT_PATH . 'controller.py ' . $path . '/World.xml ' . $gamefilepath . ' ' . $script;
		exec($command);

		return 1;
	}

     return 1;
}

/*
* Function creates the xml file that will be used with the flash game files.  It depends on the
* verigames.sh script file.  It will copy over the World.xml and the inference.jaif file created
* by the verigames.sh file.  It will return a 1 if the file was created successfully, otherwise
* it will return a 0. 
*/
function createGameFilesFromXML($id, $script) {
	
	//break world into separate levels
	//get level ID from database
	//loop over all newly created worlds (containing only one level each) and
	//measure them, creating a file with that info
	//all this stuff below
	//then store in RA and database
	//then show rename and activate screen, and do that

	$path = UPLOADS_DIRECTORY . $id;
	$gamefilepath = UPLOADS_DIRECTORY . $id . '/gamefiles';

	//rename xml file as World.xml to make work within system
	$command = 'cp ' . $path . '/*.xml '. $path . '/World.xml';
   	exec($command);


    	//Create the game files
	exec('mkdir ' . $gamefilepath);

     	$command = 'python ' . SCRIPT_PATH . 'controller.py ' . $path . '/World.xml ' . $gamefilepath . ' ' . $script;
	exec($command);

	return 1;
}


/*
* Function zips all needed game files and removes others. 
*/
function zipGameFiles($id) {

	//zip all the files listed in the mapfile
     	//$command = 'python zipFiles.py ' . $id;
   	//exec($command);

	return 1;
}

/*
* Uploads game files to database, and sets level object parameters 
*/
function uploadGameFiles($id) {

	chdir(UPLOADS_DIRECTORY . "/" . $id);

	$command = 'java -jar ../java/uploadToDatabase.jar World';
   	exec($command);

	return 1;
}



/*
* Helper function that will check the size of the passed $filename at the passed $path location. 
* If the size is 0 it will print out a Success message as a table row and return a 1.  Otherwise 
* it will print the error messages that are contained in the file and return a 0.  The function
* assumes that the $filename passed is the result of the stderr output from a system command. The 
* table row will have a first column data that is obtained from $statusType. 
*/
function checkErrorOutput($path, $filename) {
    $file_path = $path . "/" . $filename;
    if (filesize($file_path) == 0) {
        return 1;
    } else {
        return $filename;
    }
}



/*
* Deletes all .class files and the output.txt file once confirmation of the files
* validity.  If the files did not compile properly than it will delete the entire
* folder on the server since the uploaded files cannot be used.  If a .zip file 
* was uploaded it will also remove the .zip files once they ahve been successfully
* extracted. 
*/
function cleanup($id, $deleteAll) {
    $path = UPLOADS_DIRECTORY . "/" . $id;
    $deleteString = "";
    
    if ($deleteAll) {
        $deleteString = "-r " . $path;
    } else {
        $deleteClass = '`find ' . $path . ' -name "*.class"` ';
        $deleteString = $deleteText . $deleteClass;
    }
    exec("rm " . $deleteString);
}
?>
