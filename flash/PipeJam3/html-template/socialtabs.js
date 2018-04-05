function loadSocialTabs()
{
	

	$('#social_overlay').html(
		'<div id="tabs" >' +
			'<a href="#leaderTab" id="leaderButton" class="popout"><img id="leaderImg" src="assets/LeaderDeselected.png" alt="Leaders" /></a>' +
			'<a href="#groupTab" id="groupButton" class="popout"><img id="groupImg" src="assets/GroupsDeselected.png" alt="Groups" /></a>' +
		'</div>' +
		'<div id="tab-content" >' +
			'<div class="popout" id="leaderTab">' +
				'<select name="leaderType" id="leaderType" onChange="loadLeader(this.value)">' +
					'<option value="overall" selected>Overall</option>' +
					'<option value="level">By Level</option>' +
					'<option value="group">By Group</option>' +
				'</select>' +
				'<select name="levelDetail" id="levelDetail" onChange="loadLeadersByLevel(this.value)" hidden >' +
				'</select>' +
				'<a href="javascript:launchCurrentLevel()" id="levelLink" hidden>Play</a>' +
				'<select name="groupDetail" id="groupDetail" onChange="loadLeadersByGroup(this.value)" hidden >' +
				'</select>' +
				'<br />' +
				'<div id="overallLeaders">' +
					'<img id="overallLoading" src="assets/ajax-loader.gif" alt="Loading..." hidden />' +
				'</div>' +
				'<div id="levelLeaders" hidden>' +
					'<select name="levelNumber" id="levelNumber" onChange="loadLeadersByLevel(this.value)">' +
					'</select><br />' +
					'<div id="levelLeaderList"></div>' +
					'<img id="levelLoading" src="assets/ajax-loader.gif" alt="Loading..." hidden />' +
				'</div>' +
				'<div id="groupLeaders" hidden>' +					
					'<select name="groupNumber" id="groupNumber" onChange="loadLeadersByGroup(this.value)">' +
					'</select>' +
					'<div id="groupLeaderList"></div>' +
					'<img id="groupLoading" src="assets/ajax-loader.gif" alt="Loading..." hidden />' +
				'</div>' +
			'</div>' +
			'<div class="popout" id="groupTab">' +
				'<div id="nogroup">' +
					'<p><a href="javascript:joinGroup()">Join a group</a></p>' +
					'<p><a href="javascript:findGroup()">Find a group</a></p>' +
					'<p><a href="javascript:createGroup()">Create a group</a></p>' +
				'</div>' +
				'<div id="hasgroup">' +
				'</div>' +
				'<p><a href="javascript:viewMessages()"><div id="groupMsg"></div></p>' +
			'</div>' +
		'</div>');
	

	
	jQuery(function($) {

		$('a.popout').click(function() {
			var $target = $($(this).attr('href')),
				$other = $target.siblings('.active'),
				animIn = function () {
					
					if($other.length > 0)
						$other.hide();
					
					$target.addClass('active').show().css({
						'padding-left': 200,
						'opacity': 0
					}).animate({
						'padding-left': 0,
						'opacity': 1
					}, 500);
					
					if($target.attr("id") == 'leaderTab')
						$("#leaderImg").attr("src","assets/LeaderSelected.png");
					else if($target.attr("id") == 'groupTab')
						$("#groupImg").attr("src","assets/GroupsSelected.png");
					
					$('#PipeJam3').css({'visibility':'hidden'});
					$('#pauseImg').show();
				};
				
			var hideDiv = function() {
					$('#PipeJam3').css({'visibility':'visible'});
					if($target.attr("id") == 'leaderTab')
						$("#leaderImg").attr("src","assets/LeaderDeselected.png");
					else if($target.attr("id") == 'groupTab')
						$("#groupImg").attr("src","assets/GroupsDeselected.png");
					$('#pauseImg').delay(800).hide();
					$target.hide();
				};
			if (!$target.hasClass('active') && $other.length > 0) {
					$other.removeClass('active').animate({
						'padding-left': 200,
						'opacity': 0
					}, 500, animIn);
					if($other.attr("id") == 'leaderTab')
					{
						$("#groupImg").attr("src","assets/GroupsSelected.png");
						$("#leaderImg").attr("src","assets/LeaderDeselected.png");
					}
					else if($other.attr("id") == 'groupTab')
					{
						$("#leaderImg").attr("src","assets/LeaderSelected.png");
						$("#groupImg").attr("src","assets/GroupsDeselected.png");
					}
			} else if (!$target.hasClass('active')) {
				animIn();
			} else {
				$target.removeClass('active').animate({
					'padding-left': 200,
						'opacity': 0
				}, 500, hideDiv);

			}
			
			return false; //prevents scrolling
		});

	});
	
	loadOverallLeaders();
	loadAllLevels();
	loadAllGroups();
}


function unpause()
{
	var $expanded = $(".active");
	var hideDiv = function() {
					$('#PipeJam3').css({'visibility':'visible'});
					$('#pauseImg').delay(800).hide();
					$expanded.hide();
				};
	
	
	$expanded.removeClass('active').animate({
						'padding-left': 200,
						'opacity': 0
					}, 500, hideDiv);
	
	if($expanded.attr("id") == 'leaderTab')
		$("#leaderImg").attr("src","assets/LeaderDeselected.png");
	else if($expanded.attr("id") == 'groupTab')
		$("#groupImg").attr("src","assets/GroupsDeselected.png");
}
function loadAllLevels()
{
	$.ajax({
		url: 'http://54.226.188.147/cgi-bin/interop.php',
		data: {'function': 'levelList', 'data_id': ''},
		dataType: 'jsonp',
		jsonp: 'jsonp_callback',
		beforeSend: function() {
			$('#levelLoading').show();
		},
		complete: function(){
			$('#levelLoading').hide();
		},
		success: function(data) {
			var obj = data.Levels;
			var tempOption;
			
			for (var i = 0; i < obj.length; i++)
			{
				tempOption = new Option(obj[i].LevelName, obj[i].LevelNumber);
				$(tempOption).html(obj[i].LevelName);
				$("#levelNumber").append(tempOption);
			}
			
		},
		error: function(response, status, error) {
			//log something?
			
		}
	});
}

function loadAllGroups()
{
	$.ajax({
		url: 'http://54.226.188.147/cgi-bin/interop.php',
		data: {'function': 'groupList', 'data_id': ''},
		dataType: 'jsonp',
		jsonp: 'jsonp_callback',
		beforeSend: function() {
			$('#groupLoading').show();
		},
		complete: function(){
			$('#groupLoading').hide();
		},
		success: function(data) {
			var obj = data.Groups;
			var tempOption;
			
			for (var i = 0; i < obj.length; i++)
			{
				tempOption = new Option(obj[i].GroupName, obj[i].GroupID);
				$(tempOption).html(obj[i].GroupName);
				$("#groupNumber").append(tempOption);
			}
			
		},
		error: function(response, status, error) {
			//log something?
			
		}
	});
}

function loadOverallLeaders()
{

	$.ajax({
		url: 'http://54.226.188.147/cgi-bin/interop.php',
		data: {'function': 'overallLeaders', 'data_id': ''},
		dataType: 'jsonp',
		jsonp: 'jsonp_callback',
		beforeSend: function() {
			$('#overallLoading').show();
		},
		complete: function(){
			$('#overallLoading').hide();
		},
		success: function(data) {
			var obj = data.Leaders;
			var leaderHTML = "<div style='float: left; padding-left:5px;'>Group Name</div><div style='float: right; padding-right: 5px;'>Total</div>" + 
						  "<ul style='list-style-type: none;'>";
			
			for (var i = 0; i < obj.length; i++)
			{
				leaderHTML += "<li style='clear:both'><div style='float: left; padding-left:5px;'>" + obj[i].GroupName + "</div><div style='float: right; padding-right: 5px;'>" + obj[i].GroupScore + "</div></li>";
			}
			
			leaderHTML += "</ul>";
			
			$('#overallLeaders').html(leaderHTML);
		},
		error: function(response, status, error) {
			//log something?
			
		}
	});
}
function getPlayerName(playerID)
{
	$.ajax({
		url: 'http://api.flowjam.verigames.com/api/users/' + playerID,
		dataType: 'json',
		success: function(data) {
			var obj = data;
			var retVal = obj.firstName + ' ' + obj.lastName;
			return retVal;
		},
		error: function(response, status, error) {
			return "Mr. Guy";
		}
	});
	
	return "foo";
}

function loadLeadersByLevel(levelID)
{
	$.ajax({
		url: 'http://54.226.188.147/cgi-bin/interop.php',
		data: {'function': 'topForLevel', 'data_id': levelID},
		dataType: 'jsonp',
		jsonp: 'jsonp_callback',
		beforeSend: function() {
			$('#levelLeaderList').html("");
			$('#overallLoading').show();
		},
		complete: function(){
			$('#overallLoading').hide();
		},
		success: function(data) {
			var obj = data.Scores;
			var leaderHTML = "<div style='float: left; padding-left:5px;'>Group Name</div><div style='float: right; padding-right: 5px;'>Score (Points)</div>" + 
						  "<ul style='list-style-type: none;'>";
			
			var groupName;
			for (var i = 0; i < obj.length; i++)
			{
				groupName = obj[i].GroupName;
				
				leaderHTML += "<li style='clear:both'><div style='float: left; padding-left:5px;'>" + groupName + "</div><div style='float: right; padding-right: 5px;'>" + obj[i].Points + " (" + obj[i].Score +")</div></li>";
			}
			
			leaderHTML += "</ul>";
			
			$('#levelLeaderList').html(leaderHTML);
		},
		error: function(response, status, error) {
			//log something?
			
		}
	});
}
	
function loadLeadersByGroup(groupID)
{
	$.ajax({
		url: 'http://54.226.188.147/cgi-bin/interop.php',
		data: {'function': 'groupScores', 'data_id': groupID},
		dataType: 'jsonp',
		jsonp: 'jsonp_callback',
		beforeSend: function() {
			$('#groupLeaderList').html("");
			$('#groupLoading').show();
		},
		complete: function(){
			$('#groupLoading').hide();
		},
		success: function(data) {
			var obj = data.Scores;
			var leaderHTML = "<div style='float: left; padding-left:5px;'>Level Name</div><div style='float: right; padding-right: 5px;'>Score (Points)</div>" + 
						  "<ul style='list-style-type: none;'>";
			
			for (var i = 0; i < obj.length; i++)
			{
				
				leaderHTML += "<li style='clear:both'><div style='float: left; padding-left:5px;'>" + obj[i].LevelName + "</div><div style='float: right; padding-right: 5px;'>" + obj[i].Points + " (" + obj[i].Score +")</div></li>";
			}
			
			leaderHTML += "</ul>";
			
			$('#groupLeaderList').html(leaderHTML);
		},
		error: function(response, status, error) {
			//log something?
			
		}
	});
}
	
function loadLeader(leaderType)
{
	switch(leaderType)
	{
		case "overall":
			$("#overallLeaders").show();
			$("#levelLeaders").hide();
			$("#groupLeaders").hide();
			break;
		case "level":
			$("#overallLeaders").hide();
			$("#levelLeaders").show();
			$("#groupLeaders").hide();
			loadLeadersByLevel($("#levelNumber").val());
			break;
		case "group":
			$("#overallLeaders").hide();
			$("#levelLeaders").hide();
			$("#groupLeaders").show();
			loadLeadersByGroup($("#groupNumber").val());
			break;
	}
}
