<?php
/* All global paths, should be included with all php files that reference
 * scripts. These may need to change if the site moves but they should all
 * be relative paths.  
 */
 
define('JAVA_PATH','../java/');
define('SCRIPT_PATH', '../scripts/');
define('UPLOADS_DIRECTORY', '../uploads/');
define('JDK_7_PATH', '../../../jdk1.7.0/bin/java');
define('FILE_KEY', 'Filedata');
define('DIRECTORY', realpath("../uploads/"));
define('INFERENCE_LOC', "inference.jaif");
define('WORLD_XML_LOC', "World.xml");
define('VERIGAMES_JAR', "../java/verigames.jar");
define('MAP_JAR', "../java/map.jar");
define('TYPECHECKER_LOC', 'typecheckers/');

//file locations
define('UPDATED_XML', 'updatedXML.xml');
define('DTD_FILE', 'world.dtd');
define('JAIF_FILE', 'inference.jaif');
define('UPDATED_JAIF', 'updatedInference.jaif');

//log names
define('COMPILE_OUTPUT', "compile_output.txt");
define('XML_ERROR', "xml_error.txt");
define('XML_LOG', "xml_creation_log.txt");
define('JAIF_PARSE_ERROR', 'jaif_parse_error.txt');
define('XML_VALIDATION_ERROR', 'xml_validation_error.txt');
define('ANNOTATE_ERROR', 'annotate_error.txt');

//other constants
define('MAX_SIZE', 10485760);
?>