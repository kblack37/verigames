
/*
* Function that will attempt to compile the files uploaded by the user.  It will make an
* Ajax call to the server and wait for the response before continuing.  If the server indicates
* that all files were successfully compiled, it will call the createXML() function to continue
* the user upload process. If there was a failure compiling, the function will display a link
* to the file containing the compiling error. 
*/
function compileFiles() {
    showSpinner("compile-spin");
console.log("compile files");
    var request = $.ajax({
        url   : PHP_SCRIPT,
        type  : "POST",
        data  : {"function" : "compile", "guid" : uploadGUID}
    });

    //wait for Ajax request to complete.  If successful, continue, otherwise display an error
    request.done(function (response) {
        if (response === "SUCCESS") {
            $('#compile-spin').html("<img style='opacity:1.0' width='25' height='25'" +
                " src='./resources/success.png'/>");
            createXML();
        } else {
            $('#compile-spin').html("<a style='color:red' target='_blank' " +
                " href='scripts/utilities.php" +
                "?function=displayError&file=compile_output.txt&id=" + uploadGUID + "\'>Error</a>");
        }
    });
}


/*
* Function called as the last stage of the user upload process. It will remove all the 
* unnecessary files that were a part of the verification process. For instance, the .class files
* created during the compilation process are no longer needed and will be removed.  Once the cleanup
* is complete this function will call playGame() that will redirect the user to the game. There 
* is an optional argument.  If passed True, it will remove all of the user's files.  If not passed
* or False is passed it will only remove the unncessary files. 
*/
function cleanup(all) {
    var toCall, cleanup;

    //if not passed, default to false
    all = typeof all !== 'undefined' ? all : false;

    //if true is passed then the entire directory should be removed
    toCall = (all) ? "cleanup_all" : "cleanup";
	cleanup = $.ajax({
        url     : PHP_SCRIPT,
        type    : "POST",
        data    : {"function" : toCall, "guid" : uploadGUID}
    })

    cleanup.done(function (response) {
        if (!all) {
            createGraphFiles();
        }
    });
}
