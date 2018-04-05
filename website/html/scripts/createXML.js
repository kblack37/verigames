/*
* 
*/

/*
* Function that creates the necessary XML for use with the game.  It will make an Ajax request
* to the server with the user's unique guid file.  It will then wait for a response from the
* server before continuing to the next step fo the user upload process.  If the response from
* the server indicates the successful creation of the XML the function will call the cleanup
* function. */
function createXML() {
    var typeChecker, request;
    showSpinner("verify-spin");
    typeChecker = $('option:selected').val();
	console.log("typechecker is " + typeChecker + " " + document.location.pathname);
	console.log("isXML " + document.forms.isXML.value);

    //make ajax request to create XML file
    request = $.ajax({
        url     : PHP_SCRIPT,
        type    : "POST",
        data    : {"function" : "xml", "guid" : uploadGUID, "script" : typeChecker}
    });

	//wait for ajax request to complete before continuing
    request.done(function (response) {
        if (response === "SUCCESS") {
 		console.log("create XML success");
	     	createGameFiles();
        } else {
		console.log("create XML fail " + response);

            $('#verify-spin').html("<a style='color:red' target='_blank' " +
                "href='scripts/utilities.php" +
                "?function=displayError&file=" + response + "&id=" + uploadGUID + "\'>Error</a>");
        }
    });
}


function createGameFiles() {
 
	console.log("creating game files");
	typeChecker = $('option:selected').val();

    //make ajax request to create game files
    request = $.ajax({
        url     : PHP_SCRIPT,
        type    : "POST",
        data    : {"function" : "game", "guid" : uploadGUID, "script" : typeChecker}
    });

	//wait for ajax request to complete before continuing
    request.done(function (response) {
        if (response === "SUCCESS") {
		console.log("create game files success");

            $('#verify-spin').html("<img width='25' height='25' src='./resources/success.png'/>");
            cleanup();
		$("#resultdir").val(uploadGUID);
		$("#postFiles").submit();
        } else {
            $('#verify-spin').html("<a style='color:red' target='_blank' " +
                "href='scripts/utilities.php" +
                "?function=displayError&file=" + response + "&id=" + uploadGUID + "\'>Error</a>");
        }
    });
}

function createGameFilesFromXML() {
 
	console.log("creating game files from xml");
	typeChecker = $('option:selected').val();

    //make ajax request to create game files
    request = $.ajax({
        url     : PHP_SCRIPT,
        type    : "POST",
        data    : {"function" : "gameFromXML", "guid" : uploadGUID, "script" : typeChecker}
    });

	//wait for ajax request to complete before continuing
    request.done(function (response) {
        if (response === "SUCCESS") {
		console.log("create game files success");

            $('#verify-spin').html("<img width='25' height='25' src='./resources/success.png'/>");
            cleanup();
		$("#resultdir").val(uploadGUID);
		$("#postFiles").submit();
        } else {
            $('#verify-spin').html("<a style='color:red' target='_blank' " +
                "href='scripts/utilities.php" +
                "?function=displayError&file=" + response + "&id=" + uploadGUID + "\'>Error</a>");
        }
    });
}

