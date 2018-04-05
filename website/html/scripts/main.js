//keeps track of the number of files to be uploaded
var count = 1;
var uploadGUID = -1;
var PHP_SCRIPT = "./scripts/controller.php"; //this should be treated as a constant
var UPLOADIFY_LOC = "./uploadify/uploadify.swf"; //this should be treated as a constant

/*
* Function that will remove any observers connected to a div that is going 
* to be removed.  This will be called when the user clicks the "remove" option
* from the file upload box.  The function will remove the observer attached 
* to the div and then remove it from the page. 
*/
function attachRemoveDivObserver(id) {
    //listen for mouseclick
    id = "#" + id;
    $(id).bind('click', function (event) {
        $(this).parent().remove();
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
console.log("Cleaning up " + all);
all = false;

    //if true is passed then the entire directory should be removed
    toCall = (all) ? "cleanup_all" : "cleanup";
	cleanup = $.ajax({
        url     : PHP_SCRIPT,
        type    : "POST",
        data    : {"function" : toCall, "guid" : uploadGUID}
    })

    cleanup.done(function (response) {
        if (!all) {
            console.log("Done");
        }
    });
}

/*
* Function that will display the progress spinner in the DOM object indicated by the passed
* id.  The id should represent a block element on the webpage.  It will embed the spinner
* as a child element in the DOM object.
*/
function showSpinner(targetId) {
    var opts, target, spinner;
    opts = {
        lines   : 12, // The number of lines to draw
        length  : 7, // The length of each line
        width   : 2, // The line thickness
        radius  : 5, // The radius of the inner circle
        color   : '#ffffff', // #rgb or #rrggbb
        speed   : 3, // Rounds per second
        trail   : 60, // Afterglow percentage
        shadow  : false, // Whether to render a shadow
        hwaccel : false, // Whether to use hardware acceleration
        top     : '0px',
        left    : '100px'
    };
    target = document.getElementById(targetId);
    spinner = new Spinner(opts).spin(target);
}


window.onload = function () {
    //obtain the unique guid for this user
    var upload = $.ajax({
        url: "./scripts/utilities.php",
        type: "POST",
        data: {'function': 'getGUID'}
    });

    //bind buttons to jQuery action listeners
    $('#uploadIt').bind('click', uploadFiles);

    //once the guid has been received, setup the uploadify object 
    upload.done(function (guid) {
        uploadGUID = guid;
        $('#file_upload').uploadify({
            'swf'            : UPLOADIFY_LOC,
            'uploader'       : './scripts/controller.php?folder=' + guid,
            'removeCompleted': false,
            'multi'          : true,
            'fileTypeExts'   : '*.zip;*.java;*.jar;*.xml',
            'fileTypeDesc'   : 'Game Source Files',
            'fileSizeLimit'  : '10MB',
            'width'          : 134,
            'auto'           : false,
            'queueID'        : 'queue',
            'queueSizeLimit' : 10,
            'onQueueComplete': unzipFiles,
            'requeueErrors'  : false
        });
    });
}
