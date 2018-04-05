 //keeps track of the number of files to be uploaded
var count = 1;
var uploadGUID = -1;
var PHP_SCRIPT = "./scripts/controller.php"; //this should be treated as a constant
var UPLOADIFY_LOC = "./uploadify/uploadify.swf"; //this should be treated as a constant


/*
* Function that will upload the selected user files to the server.  It will call the uploadify
* object and ask it to upload all files in its queue.  Once uploadify has indicated that it has
* completed it will start the file verification process. If there was an error uploading the files
* an error will be displayed. 
*/
function uploadFiles() {
    if ($('#queue').find('.fileName').length !== 0) {
        $(this).modal();
        showSpinner('upload-spin');

        //upload files via uploadify object
        if (uploadGUID !== -1) {
            $('#file_upload').uploadify('upload', '*');
        }
console.log("done uploading files");
    }
}

/*
* Function that will make an Ajax call to unzip the files uploaded by the user.  The function
* does not make any attempt to verify whether the user uploaded .zip files.  It will simply 
* attempt to unzip them and if no .zip file was uploaded then there will be no changed made 
* to the uploaded files. If the unzipping process was successful or if no zip files were 
* uploaded, it will call the compileFiles() method to validate the uploaded files. 
*/
function unzipFiles(event) {
    $('#upload-spin').html("<img style='opacity:1.0' width='25' height='25' " +
        "src='./resources/success.png'/>");
    showSpinner("unzip-spin");
    //make an Ajax request to unzip any uploaded zip files
    var request = $.ajax({
        url     : PHP_SCRIPT,
        type    : "POST",
        data    : {"function" : "unzip", "guid" : uploadGUID}
    });

    //wait for Ajax request to complete, if successful move on to the next stage
    request.done(function (response) {
        if (response === "SUCCESS") {
		console.log("success unzipping files");
		if(document.forms[0].isXML.checked.toString() == 'false')
		{
            		$('#unzip-spin').html("<img style='opacity:1.0' width='25' height='25' " +
                		"src='./resources/success.png'/>");
            		compileFiles();
		}
		else
		{
			createGameFilesFromXML();
		}
        }
    });
}
