<?php
    include("./scripts/common_include.php");
?>
		<link rel="stylesheet" href="./scripts/code_mirror/lib/codemirror.css"/>
		<link type="text/css" href="./styles/results.css" rel="Stylesheet"/>
		<script type="text/javascript" src="./scripts/results.js"></script>
		<link type="text/css" href="./jqueryUI/css/smoothness/jquery-ui-1.8.20.custom.css" rel="Stylesheet" />
		<script type="text/javascript" src="./scripts/code_mirror/lib/codemirror.js"></script>
		<script type="text/javascript" src="./scripts/code_mirror/lib/util/runmode.js"></script>
		<script type="text/javascript" src="./scripts/code_mirror/mode/clike/clike.js"></script>
		<title>PipeJam Results</title>
<?php
    include("./scripts/header.php");
?>

<div id="content">
 <h3> Results </h3>
	<div id="results">
		<form>
			<div id="radio">
			
			</div>
		</form>
	</div>
	<div id="code_view">
		<div id="header">
			<div id="download">
				<button id="download_button">Download</button>
			</div>
			<div id="file_name">
			</div>
		</div>
		<div id="code">
		  <!--  <div id="line_num">
		    </div>-->
			<pre id="text_area" rows="" cols="" readonly="true">
			</pre>
		</div>
	</div>
	<div id="clear_footer">
	</div>
</div>
<?php
    include("./scripts/footer.php");
?>
		