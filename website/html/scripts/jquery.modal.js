(function($) {
    $.fn.extend({
        modal: function () {
        	var overlayWindow = $("<div id='overlay-window'></div>");
        	var uploading = $("<div class='compiling-div'>Uploading...</div><div id='upload-spin' class='spinner'></div>");
        	var unzipping = $("<div class='compiling-div'>Unzipping...</div><div id='unzip-spin' class='spinner'></div>");
        	var compiling = $("<div class='compiling-div'>Compiling...</div><div id='compile-spin' class='spinner'></div>");
        	var verifying = $("<div class='compiling-div'>Creating XML...</div><div id='verify-spin' class='spinner'></div>");
        	var result = $("<div class='compiling-div' id='upload_result'><span style='cursor:pointer'>Close</span></div>");
        	var blurWindow = $("<div id='blur-window'></div>");
        	
        	return this.each(function (){
        			overlayWindow.append(uploading);
        			overlayWindow.append(unzipping);
        			overlayWindow.append(compiling);
        			overlayWindow.append(verifying);
        			overlayWindow.append(result);
        			$("body").append(overlayWindow);
        			$("input[id=submit]").attr("disabled", "disabled");
        			adjustPosition();
        			window.onresize = adjustPosition;
	        		overlayWindow.css("opacity", .85);
	        		overlayWindow.fadeIn(300);
	        		
	        		//	event.preventDefault();
	        		$(document).keydown(handleEscape);
	        		$('#upload_result').bind('click', function () {
                        //close modal window
	        			hideWindow();
	        			
	        			//clear the uploadify queue
	        			$('#file_upload').uploadify('cancel', '*');
	        			
	        			//remove the entire folder, there was an error
	        			cleanup(true);
	        		});
	        		
        	});
        
        function adjustPosition(){
        		overlayWindow.css({
      			"top": $(window).height()/2 - $(overlayWindow).height()/2,
      			"left":$(window).width()/2 - $(overlayWindow).width()/2
        		});
        }
        
        function showModal(event) {
        	 modalWindow.fadeIn(150);
        }
        
       
		function hideSpinner(targetId) {
        	$(targetId).spin("false");
        }	
        
        function hideWindow() {
        	$(document).unbind("keydown", handleEscape);
        	var remove  = function() {
        		$(this).remove();
        	};
        	overlayWindow.fadeOut(remove);
        
        }
        
        function handleEscape(event) { 
        	if(event.keyCode == 27) { 
        		hideWindow();
        	}
        }
  	}
  });
})(jQuery);