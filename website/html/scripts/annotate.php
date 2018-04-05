<?php

//import global paths
include('./globals.php');

$id = $_GET["id"];	
$checker = $_GET["checker"];

//switch the script from infer to check
$checker = str_replace("infer", "check", $checker);

$path = realpath(UPLOADS_DIRECTORY) . '/' . $id;
//if xml file creation is successful, run annotator
if (createUpdatedXML($id, $checker, $path)) {
    annotateAndCheck($checker, $path);
}

//print results to webapge
displayFiles($path, $id);
    
/*
 * Function that will create an updated inference file based on the results of the game. It accepts
 * two arguments, the path to the location of the java files and the path to where the script files
 * are located. If there is an error during the parsing process a file will be created in the directory
 * entitled jaif_parse_error.txt with the error results. Likewise, during the annotation process, if
 * an error is encountered than a file called annotate_error.txt will be created with the errors
 * encountered.
 */
function createUpdatedXML($id, $checker) {
    $path = realpath(UPLOADS_DIRECTORY) . '/'.$id;
    
    //move world.dtd to corresponding guid folder
    $moveWorld = "cp " . DTD_FILE . " " . $path . '/' . DTD_FILE . " 2> " .
		$path . '/' . XML_VALIDATION_ERROR;
    exec($moveWorld);
    
    //create updated jaif file
    $annotate = JDK_7_PATH . ' -cp ' . 
        JAVA_PATH . 'verigames.jar verigames.utilities.JAIFParser ' . 
        $path . '/' . UPDATED_XML . ' ' . $path . '/' . JAIF_FILE . ' ' .
        $path . '/' . UPDATED_JAIF . ' 2> ' . $path . '/' .  JAIF_PARSE_ERROR;
    exec($annotate);
        
    //return true if file was created sucessfully and ./inference-output doesn't exist.  If it does
    //then annotation has already occurred, no need to do it again. 
    if (file_exists($path . '/' . UPDATED_JAIF) &&  !file_exists($path . "/inference-output")) 
        return TRUE;
    else
        return FALSE;
}

/*
 * Function that accepts a parameter indicating which script should be run to annotate the Java files. 
 * It will then parse the Java file and annotate the file based on the results of the game.  Any errors
 * produced by the process will be placed in the file annotate_error.txt. The file will contain both 
 * output from stderr and stdout. If the file is not empty this does not necessarily indicate an error.
 */
function annotateAndCheck($checker, $path) {
    $output = $path . '/inference-output';
    $input =  $path . '/' . UPDATED_JAIF;
    $to_execute = JDK_7_PATH . ' -Xbootclasspath/p:' . JAVA_PATH . 'verigames.jar annotator.Main -d ' .
        $output . ' ' . $input . ' `find ' . $path . ' -name "*.java"` > ' .
        $path . '/' . ANNOTATE_ERROR . ' 2>&1';
    exec($to_execute);	
}

/*
 * Function that will print the html to display for each of the .java files in the current
 * directory. This is function is required for the results on the results.php page to display.
 * It accepts the path to the upload directory and the guid of the specific folder to display
 * the results for. 
 */
function displayFiles($path, $id) {
    $files = shell_exec("find ". $path .'/inference-output/ -name *.java');
    $files = explode("\n", $files);
    $full_path = ('/uploads/'.$id.'/inference-output/');

    foreach ($files as $file) {
        if (strlen($file) != 0) {
            $file_array = explode("/", $file);
            $last = count($file_array) - 1;
            print("<input type=\"radio\" id=".$file." name=\"radio\"/><label ".
                    "for=" . $file . ">" . $file_array[$last] . "</label>");
		}
	}
}
?>
