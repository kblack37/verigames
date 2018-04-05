$(document).ready(function() {

    /*
     * Attach mouseover listeners, highlights the divs when the 
     * mouse is hovering over them. 
     */
    $(".buttons").mouseover(function (event) {
        $(this).css("background-color", "#515151");
    });
    
    $(".buttons").mouseout(function (event) {
        $(this).css("background-color", "#313131");
    });


    /* 
     *  Attach the listeners to the button divs
     */
    $("#home").bind('click', function (event) {
        window.location = './index.php';
    });

    $("#play").bind('click', function (event) {
        window.open('./webgame.php?sample=sample.zip');
    });

    $("#about").bind('click', function (event) {
        window.location = './about.php';
    });    

    $("#help").bind('click', function (event) {
        window.location = './help.php';
    });
});