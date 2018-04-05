
//stores the CodeMirror object
var codeMirror;


/*
 * Plugin for JQueryUI that gives the distinct look and feel of the buttons for 
 * results.php. 
 */
(function ($) {
    //plugin buttonset vertical
    $.fn.buttonsetv = function () {
        $(':radio, :checkbox', this).wrap('<div style="margin: 1px"/>');
        $(this).buttonset();

        $('label:first', this).removeClass('ui-corner-left').addClass('ui-corner-top');
        $('label:last', this).removeClass('ui-corner-right').addClass('ui-corner-bottom');

        var max_width = 0;

        $('label', this).each(function (index) {
            var w = $(this).width();
            if (w > max_width) {
                max_width = w;
            }
        });

        $('label', this).each(function (index) {
            $(this).width(max_width);
        });
	};
})(jQuery);


/* 
 *  Function called when the user clicks on a file button on the results.php
 *  site.  When the button is clicked it will retrieve the annotated code from
 *  the users folder on the server and display the contents in the textarea. 
 *  Takes a single parameter that is passed implicitly by JQuery when the button
 *  is clicked. 
 */
function radioClicks(event) {
    var id, filename, file_path, queryString, code;

    //display selected file name in the textarea text editor
    filename = $(this).text();
    $("#file_name").text(filename);

    //split up the query string
    queryString = ((location.search.substr(1)).split("?"));
    queryString = queryString[0].split("&");

    //obtain file path for which to retrieve the contents for
    file_path = $(this).attr('for');
    id = "path=" + file_path;

    $("#text_area").html("Retrieving Contents");

    //retrieve the contents of the file representing by the clicked button
    code = $.ajax({
        url     : "./scripts/utilities.php",
        type    : 'POST',
        data    : { 'function' : 'retrieveContents', 'path' : file_path }
    });

    //when the Ajax request is done, replace the CodeMirror editor contents
    //with the returned Ajax response
    code.done(function (response) {
        //change contents of the codeMirror object to the new contents
        codeMirror.setValue(response);
    });
}


/* 
 * Function called when the user clicks on the "Download" button in results.php.  It
 * will zip the annotated java files and download them to the users computer.  
 */
function downloadFiles() {
    var id, zip;

    //split up query string and run an ajax request to zip the results
    id = location.search.substr(1).split("?")[0].split("&")[0].substr(3);
    zip = $.ajax({
        url     : "./scripts/utilities.php",
        type    : "POST",
        data    : { "function" : "zip", "id" : id }
    });

    //if successful, change the location of the browser to download the file
    zip.done(function (response) {
        if (response === "SUCCESS") {
            window.location = "./uploads/" + id + "/results.zip";
        }
    });
}


$(document).ready(function () {
    //setup bindings
    $('#download_button').bind('click', downloadFiles);
    $('#selectable').selectable({
        selected: function (event, ui) {
            alert($(this).find('.ui-selected').attr('id'));
        }
    });

    //split query string into individual parameters
    var queryString = ((location.search.substr(1)).split("?"));
    queryString = queryString[0];

    //run the spinner while the annotate script is running
    $("#radio").html(function () {
        var opts, target, spinner, message;
        opts = {
            lines   : 12, // The number of lines to draw
            length  : 7, // The length of each line
            width   : 2, // The line thickness
            radius  : 6, // The radius of the inner circle
            color   : '#2659E5', // #rgb or #rrggbb
            speed   : 2, // Rounds per second
            trail   : 60, // Afterglow percentage
            shadow  : false, // Whether to render a shadow
            hwaccel : false // Whether to use hardware acceleration
		};
        target = document.getElementById('message');
        spinner = new Spinner(opts).spin(target);
        message = document.createElement("div");
        message.id = "message";
        message.innerHTML = "Retrieving Files, Please Wait...";
        $("#radio").append(message);

    //run the annotate.php script to annotate the .java code files   
    }).load("./scripts/annotate.php", queryString,
        function (response) {
            $("#radio").buttonsetv();
            $('label').click(radioClicks);
        }
        );

    //initialize CodeMirror object for code highlighting and line numbering
    codeMirror = CodeMirror.fromTextArea(document.getElementById('text_area'), {
        lineNumbers     : true,
        matchBrackets   : true,
        mode            : "text/x-java"
    });
});
