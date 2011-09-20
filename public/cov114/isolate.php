<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");
			
$name = $_GET['name'];
$state = $_GET['state'];
$root = "node_227";

$main_file = "http://supramap.osu.edu/cov114/cov_sars.kmz";

   $unique = date('i_s');
 	$taxk = "network_update/$unique.kml";
$fw = fopen($taxk,'w+');

$update = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.1\">
<NetworkLinkControl>
";

fwrite($fw,$update);


if($state=="off"){
 	$coord = "select id from sars";	
		$query = pg_query($coord);
	         while($row = pg_fetch_row($query)){
	        $update = "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<Placemark targetId=\"pm_$row[0]\">
							  	<visibility>1</visibility>
							</Placemark>
					</Change>
				</Update>";
		fwrite($fw,$update);
				}
 }else{
	$coord = "select id,anc_id,rank from sars where id='$name' limit 1";	
		$query = pg_query($coord);
	         while($row = pg_fetch_row($query)){
	           $id = $row[1];
				 $rank = $row[2];	
				}
		$list = "'$name'";
		$count = 0;
		while($count<$rank){
				$count++;
				$select = "select id from sars where anc_id in ($list) and id not in ($list)";
					$quer = pg_query($select);
			         while($row = pg_fetch_row($quer)){	
						$list .= ",'$row[0]'";
					  }		
		}	
		$select = "select id from sars where id in ($list)";
			$quer = pg_query($select);
	         while($row = pg_fetch_row($quer)){	
			$update = "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<Placemark targetId=\"pm_$row[0]\">
							  	<visibility>1</visibility>
							</Placemark>
					</Change>
				</Update>";
		fwrite($fw,$update);
		}
		$select = "select id from sars where id not in ($list)";
					$quer = pg_query($select);
			         while($ro = pg_fetch_row($quer)){				           
			$update = "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<Placemark targetId=\"pm_$ro[0]\">
							  	<visibility>0</visibility>
							</Placemark>
					</Change>
				</Update>";
		fwrite($fw,$update);
					}				
}						
    			
$update ="
</NetworkLinkControl>
</kml>";				
fwrite($fw,$update);
fclose($fw);

header("Content-Type: application/vnd.google-earth.kml+xml"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Pragma: no-cache");

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.1\">
<NetworkLink>
  <name>Update</name>
  <Link>
    <href>http://supramap.osu.edu/cov114/$taxk</href></Link>
</NetworkLink>
</kml>";
?>
