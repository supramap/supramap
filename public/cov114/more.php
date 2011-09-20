<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");

$id = $_GET['id'];

echo "<table border='1'  align=center><tr><td colspan=\"3\">$id</td></tr><tr><td>Position</td><td>Anc</td><td>Desc</td></tr>";

$select = "select id,anc_id,position,state,anc_state from transformations_sars where id='$id' order by position asc";	
		$queryx = pg_query($select);
        		   while($rowx= pg_fetch_row($queryx)){
        		    $anc = strtoupper($rowx[4]);
        		    $cur = strtoupper($rowx[3]);
        		    echo "<tr><td><a href=\"http://supramap.osu.edu/cov114/optimize.php?pos=$rowx[2]&state=p\">$rowx[2]</a></td><td><a href=\"http://supramap.med.ohio-state.edu/cov114/optimize.php?pos=$rowx[2]&state=$anc\">$anc</a></td><td><a href=\"http://supramap.med.ohio-state.edu/cov114/optimize.php?pos=$rowx[2]&state=$cur\">$cur</a></td></tr>";
        		    $changes++;
        		    }

echo "</table>";




?>
