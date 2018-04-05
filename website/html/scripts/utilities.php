<?php
include('./globals.php');

if (isset($_REQUEST["function"])) {
    $function = $_REQUEST["function"];
    $id = $_REQUEST["id"];

    if (!strcmp($function, "zip")) {
        $result = zipFiles($id);
    } else if (!strcmp($function, "displayError")) {
        $file = $_REQUEST["file"];
        $result = displayError($id, $file);
    } else if (!strcmp($function, "retrieveContents")) {
        $path = $_REQUEST["path"];
        $result = retrieveContents($path);
    } else if (!strcmp($function, "getGUID")) {
        $result = getGUID();
    } else if (!strcmp($function, "uploadXML")) {
        $xml = $_REQUEST["xml"];
        $result = uploadXML($xml, $id);
    }
   
    //print error if unsuccessful
    if (!$result) 
        print("Error executing: ". $function);
    
} else {
    print("Must pass both a function and an id");
}



function zipFiles($id) {
    chdir(UPLOADS_DIRECTORY . $id);
    exec('zip -v results.zip `find ./inference-output/*.java ' .
            './inference-output/*/*.java` >> zip_output.txt');

    exec('zip -v results.zip `find -wholename ./inference-output/*.java`');

    if (file_exists("results.zip")) {
        print("SUCCESS");
        return TRUE;
    } else {
        return False;
    }
}

function getGUID() { 
    print(uniqid());
    return True;
}

function retrieveContents($path) {
    if (file_exists($path)){
    	$contents = file_get_contents($path);
    	
    	if (!$contents) {
    	   return FALSE;
    	}
    	
    	print($contents);
    }
    return True;
}

function uploadXML($xml, $id) {
    $file = '../uploads/' . $id . '/' . UPDATED_XML;
    if (!file_put_contents($file, $xml)) {
        return FALSE;
    }

    return TRUE;
}

function displayError($id, $file) {
    $path =  UPLOADS_DIRECTORY . $id;	
    $file_path = $path . '/' . $file;
    print($file_path);
    $handle = fopen($file_path, 'r');
    
    //error opening file
    if (!$handle) {
        return FALSE;
    }
 
    while ($line = fgets($handle)) {
        print($line."</br>");
    }
    
    fclose($handle);
    return TRUE;
}
?>