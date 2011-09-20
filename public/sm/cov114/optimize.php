<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");
			
$pos = $_GET['pos'];
$state = $_GET['state'];

$main_file = "http://supramap.osu.edu/cov114/cov_sars.kmz";
   $unique = date('i_s');
 	$taxk = "network_update/$unique.kml";
 	
 	
$fw = fopen($taxk,'w+');

$update = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.1\">
<NetworkLinkControl>
";
	
    
					
if($pos=="host"){
	$coord = "select id,host from alignment_sars order by id";	
    	$query = pg_query($coord);
	       while($row = pg_fetch_row($query)){
	     $host = $row[1];
		 if($host==0){
		 	$color = "fffff34a";
		}elseif($host==1){
		 	$color = "ffc525ff";
		}elseif($host==5){
		 	$color = "ff25c1ff";
		}elseif($host==6){
		 	$color = "ff1c1ae3";
		}else{
		 	$color = "ffc9e2ff";
		}
	        
	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>$color</color>
							</LineStyle>
					</Change>
				</Update>";
			}
				$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_host\">
							  <visibility>1</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_char\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_479\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_487\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>";
		
}elseif($state == "p"){									
	$coord = "select id from transformations_sars where position=$pos";	
    	$query = pg_query($coord);
	       while($row = pg_fetch_row($query)){
	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffc525ff</color>
							</LineStyle>
					</Change>
				</Update>";
					}
					
	$coord = "select id from sars where anc_id!='' and id not in (select id from transformations_sars where position=$pos)";	
		$query = pg_query($coord);
	         while($row = pg_fetch_row($query)){
			$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffffffff</color>
							</LineStyle>
					</Change>
				</Update>";
					}	
				$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_host\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_char\">
							  <visibility>1</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_479\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_487\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>";
				
}elseif($pos=="pos479"){
	$coord = "select id,pos479,rank,astext(centroid) from sars order by id";	
    	$query = pg_query($coord);
	       while($row = pg_fetch_row($query)){
	     $pos479 = strtoupper($row[1]);
	     
		 if($pos479=="K"){


	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>fffff34a</color>
							</LineStyle>
					</Change>
				</Update>";
			}elseif($pos479=="N"){


	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffffffff</color>
							</LineStyle>
					</Change>
				</Update>";
			}elseif($pos479=="R"){


	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffc525ff</color>
							</LineStyle>
					</Change>
				</Update>";
			}elseif($pos479=="S"){
			$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ff25c1ff</color>
							</LineStyle>
					</Change>
				</Update>";				
			}
			}
				$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_host\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_char\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_479\">
							  <visibility>1</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_487\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>";		
				
				
				
}elseif($pos=="pos487"){
	$coord = "select id,pos487,rank,astext(centroid) from sars order by id";	
    	$query = pg_query($coord);
	       while($row = pg_fetch_row($query)){
	     $pos487 = strtoupper($row[1]);
	     
		 if($pos487=="T"){


	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffffffff</color>
							</LineStyle>
					</Change>
				</Update>";
			}elseif($pos487=="S"){


	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>fffff34a</color>
							</LineStyle>
					</Change>
				</Update>";
			}elseif($pos487=="I"){


	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffc525ff</color>
							</LineStyle>
					</Change>
				</Update>";
			}elseif($pos487=="V"){
			$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ff25c1ff</color>
							</LineStyle>
					</Change>
				</Update>";				
			}
			}
				$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_host\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_char\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_479\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_487\">
							  <visibility>1</visibility>
							</ScreenOverlay>
					</Change>
				</Update>";		
				
				
				
}else{									
	$coord = "select id from sars where substring(align from $pos for 1) ilike '$state'";	
    	$query = pg_query($coord);
	       while($row = pg_fetch_row($query)){
	        $update .= " 
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffc525ff</color>
							</LineStyle>
					</Change>
				</Update>";
					}
					
	$coord = "select id from sars where anc_id!='' and id not in (select id from sars where substring(align from $pos for 1) ilike '$state')";	
		$query = pg_query($coord);
	         while($row = pg_fetch_row($query)){
			$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<LineStyle targetId=\"ls_$row[0]\">
							  <color>ffffffff</color>
							</LineStyle>
					</Change>
				</Update>";
					}
				$update .= "
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_host\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"so_char\">
							  <visibility>1</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_479\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>
				<Update>
					<targetHref>$main_file</targetHref>
					<Change>
							<ScreenOverlay targetId=\"pos_487\">
							  <visibility>0</visibility>
							</ScreenOverlay>
					</Change>
				</Update>";	
				
}













								
$update .="
</NetworkLinkControl>
</kml>";
			
			
fwrite($fw,$update);

header("Content-Type: application/vnd.google-earth.kml+xml"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Pragma: no-cache");



echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.1\">
<NetworkLink>
  <name>Update.kml</name>
  <Link>
    <href>http://supramap.osu.edu/cov114/$taxk</href></Link>
</NetworkLink>
</kml>";
?>
