<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");
			
$name = $_GET['name'];

	$method = $_GET['method'];   
	
	$unique = date('i_s');
 	$taxk = "network_update/$unique.kml";


$main_file = "http://supramap.osu.edu/cov114/cov_sars.kmz";



if(file_exists($taxk))
{
	unlink($taxk);
}

$fw = fopen($taxk,'w+');

$update = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.1\">
";
fwrite($fw,$update);
$anc_vert = 40000;	
$coord = "select astext(centroid),rank from sars where id='$name' limit 1";	
		$query = pg_query($coord);
        		   while($row = pg_fetch_row($query)){ 
				    
$latlong = explode(" ",$row[0]);
$lat = explode(")",$latlong[1]);
$long = explode("(",$latlong[0]);
$lat = $lat[0];
$long = $long[1];
$alt = $row[1];
$alt = $anc_vert*$alt;
$alt_lk = $alt + 200;

					 
$update = "					
<Document>
<LookAt >
<longitude>$long</longitude>
<latitude>$lat</latitude>
<altitude>$alt_lk</altitude>
<range>45000</range>
<heading>45</heading>
<tilt>30</tilt>
</LookAt> 
</Document>
";
fwrite($fw,$update);
}
								
$update ="

</kml>";
			
			
fwrite($fw,$update);
fclose($fw);


header("Content-Type: application/vnd.google-earth.kml+xml"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Pragma: no-cache");

print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.1\">
<NetworkLink>
  <name>update</name>
  <flyToView>1</flyToView>
  <Link>
    <href>http://supramap.osu.edu/cov114/$taxk</href>
	</Link>
</NetworkLink>
</kml>");
?>
