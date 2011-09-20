<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");

$id = $_GET['id'];


$select = "select id,align from alignment_sars where id = '$id' limit 1";	
		$query = pg_query($select);
        		   while($row = pg_fetch_row($query)){
        		    $id=$row[0];
        		    $seq=$row[1];
      }
$seq = strtoupper($seq);

echo "<b>$id</b><br>Aligned Sequence:<br><FORM ACTION=\"\">
<TEXTAREA NAME=\"seq\" COLS=80 ROWS=7>".$seq."</TEXTAREA>
</FORM><br>";
	  
$seq = str_replace("-","",$seq);
$seq = str_replace("_","",$seq);
$seq = str_replace("?","",$seq);		    
$count=0;
$total=0;
$tally=1;
$num = 1;
echo "<br>Genbank Format:<br><table><tr><td align=right>$num</td><td>";
$arr = str_split($seq, 10);
while(isset($arr[$count])){
	echo $arr[$count];
	$total=$total+10;
	$num = $total+1;
	
	if($tally==5){
		echo "</td></tr><tr><td align=right>$num</td><td>";
		$tally = 1;
	}else{
		echo "</td><td>";
		$tally++;
	}
	$count++;
}






?>
