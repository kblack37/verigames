<?php

if(strpos($_GET['function'], 'POST') != false)
{
	//all functions that submit a file for saving contain 'POST' in the name
	if(empty($_GET['code']))
		exec("python dbInterface2.py " . $_GET['function'] . " " . $_GET['data_id'] . " '" . $HTTP_RAW_POST_DATA . "'", $output);
	else
		exec("python dbInterface2.py " . $_GET['function'] . " " . $_GET['data_id'] . " " . $_GET['code'] . " '" . $HTTP_RAW_POST_DATA . "'", $output);

	echo $output[0];
}
else
{
	if(empty($_GET['access_token']))
		exec("python dbInterface2.py " . $_GET['function'] . " " . $_GET['data_id'], $output);
	else
		exec("python dbInterface2.py " . $_GET['function'] . " " . $_GET['data_id'] . " " . $_GET['access_token'], $output);

	echo $output[0];
}

?>
