<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");

$optimize_by = "host";

$anc_vert = 40000;
$leaf_vert = 10000;

$taxk = "cov_sars.kml";
$fw = fopen($taxk,'w+');
$pj = "sars";
 $root_nm = "node_227";
 $geom_method = "centroid";
 $method = "astext($geom_method)";
 ///$method = "centroid";


$tree = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.0\">
<Document><name>Tree</name>
<Style id=\"00a\">
  <IconStyle><scale>.45</scale>
   <Icon><href>http://supramap.osu.edu/cov114/icons/00.png</href>
   </Icon>
  </IconStyle>
  <LabelStyle>
   <scale>0</scale>
  </LabelStyle><LineStyle><width>1.5</width></LineStyle>
 </Style>
 <Style id=\"00b\">
  <IconStyle><scale>.95</scale>
   <Icon><href>http://supramap.osu.edu/cov114/icons/00.png</href>
   </Icon>
  </IconStyle>
  <LabelStyle>
  </LabelStyle><LineStyle><width>4</width></LineStyle>
 </Style>
 <StyleMap id=\"00\">
  <Pair>
   <key>normal</key>
   <styleUrl>#00a</styleUrl>
  </Pair>
  <Pair>
   <key>highlight</key>
   <styleUrl>#00b</styleUrl>
  </Pair>
 </StyleMap>



<Style id=\"01a\">
  <IconStyle><scale>.45</scale>
   <Icon><href>http://supramap.osu.edu/cov114/icons/01.png</href>
   </Icon>
  </IconStyle>
  <LabelStyle>
   <scale>0</scale>
  </LabelStyle><LineStyle><width>1.5</width></LineStyle>
 </Style>
 <Style id=\"01b\">
  <IconStyle><scale>.95</scale>
   <Icon><href>http://supramap.osu.edu/cov114/icons/01.png</href>
   </Icon>
  </IconStyle>
  <LabelStyle>
  </LabelStyle><LineStyle><width>4</width></LineStyle>
 </Style>
 <StyleMap id=\"01\">
  <Pair>
   <key>normal</key>
   <styleUrl>#01a</styleUrl>
  </Pair>
  <Pair>
   <key>highlight</key>
   <styleUrl>#01b</styleUrl>
  </Pair>
 </StyleMap>




<Style id=\"05a\">
  <IconStyle><scale>.45</scale>
   <Icon><href>http://supramap.osu.edu/cov114/icons/05.png</href>
   </Icon>
  </IconStyle>
  <LabelStyle>
   <scale>0</scale>
  </LabelStyle><LineStyle><width>1.5</width></LineStyle>
 </Style>
 <Style id=\"05b\">
  <IconStyle><scale>.95</scale>
   <Icon><href>http://supramap.osu.edu/cov114/icons/05.png</href>
   </Icon>
  </IconStyle>
  <LabelStyle>
  </LabelStyle><LineStyle><width>4</width></LineStyle>
 </Style>
 <StyleMap id=\"05\">
  <Pair>
   <key>normal</key>
   <styleUrl>#05a</styleUrl>
  </Pair>
  <Pair>
   <key>highlight</key>
   <styleUrl>#05b</styleUrl>
  </Pair>
 </StyleMap>


 <Style id=\"06a\">
   <IconStyle><scale>.45</scale>
    <Icon><href>http://supramap.osu.edu/cov114/icons/06.png</href>
    </Icon>
   </IconStyle>
   <LabelStyle>
    <scale>0</scale>
   </LabelStyle><LineStyle><width>1.5</width></LineStyle>
  </Style>
  <Style id=\"06b\">
   <IconStyle><scale>.95</scale>
    <Icon><href>http://supramap.osu.edu/cov114/icons/06.png</href>
    </Icon>
   </IconStyle>
   <LabelStyle>
   </LabelStyle><LineStyle><width>4</width></LineStyle>
  </Style>
  <StyleMap id=\"06\">
   <Pair>
    <key>normal</key>
    <styleUrl>#06a</styleUrl>
   </Pair>
   <Pair>
    <key>highlight</key>
    <styleUrl>#06b</styleUrl>
   </Pair>
 </StyleMap>

 <Style id=\"99a\">
   <IconStyle><scale>.3</scale>
    <Icon><href>http://supramap.osu.edu/cov114/icons/99.png</href>
    </Icon>
   </IconStyle>
   <LabelStyle>
    <scale>0</scale>
   </LabelStyle><LineStyle><width>1.5</width></LineStyle>
  </Style>
  <Style id=\"99b\">
   <IconStyle><scale>.95</scale>
    <Icon><href>http://supramap.osu.edu/cov114/icons/99.png</href>
    </Icon>
   </IconStyle>
   <LabelStyle>
   </LabelStyle><LineStyle><width>4</width></LineStyle>
  </Style>
  <StyleMap id=\"99\">
   <Pair>
    <key>normal</key>
    <styleUrl>#99a</styleUrl>
   </Pair>
   <Pair>
    <key>highlight</key>
    <styleUrl>#99b</styleUrl>
   </Pair>
 </StyleMap>
<Folder><name>Tree</name>";

fwrite($fw,$tree);


$coord = "select id,$method,anc_id,rank,date_of,host from $pj order by rank,id asc";
		$query = pg_query($coord);
        		   while($row = pg_fetch_row($query)){
$latlong = explode(" ",$row[1]);
$lat = explode(")",$latlong[1]);
$long = explode("(",$latlong[0]);
$lat = $lat[0];
$long = $long[1];
$alt = $row[3];
$alt = $anc_vert*$alt;
$span = 30;
$host = sprintf("%02d",$row[5]);
$rank=$row[3];
$local = "";
	if($rank==0){
			$styleurl = "<styleUrl>#$host</styleUrl>";
	}else{
		$styleurl = "<styleUrl>#99</styleUrl>";
	}

if($optimize_by=="host"){
		if($host==00){
		 	$color = "fffff34a";
		}elseif($host==01){
		 	$color = "ffc525ff";
		}elseif($host==05){
		 	$color = "ff25c1ff";
		}elseif($host==06){
		 	$color = "ff1c1ae3";
		}else{
		 	$color = "ffc9e2ff";
		}
}
		if($rank==0){
			$genbank = "<tr><td colspan=3 align=right><font size=\"+1\">Genbank Record:</font></td><td>
			<a href=\"http://www.ncbi.nlm.nih.gov/entrez/viewer.fcgi?db=nucleotide&val=$row[0]\"><i>click here</i></td><tr>";
			$descx="";
		}else{
			$genbank = "";
			$num = 0;
$coord1 = "select id,host from $pj where anc_id='$row[0]'";
		$query1 = pg_query($coord1);
        		   while($rowx = pg_fetch_row($query1)){
        		    if($num==0){
						$desc1 = $rowx[0];
						$png = sprintf("%02d",$rowx[1]);
						$desc1png = "<img src=\"http://supramap.osu.edu/cov114/icons/$png.png\" height=15 width=15>";
						$num = 1;
						$local = "<tr><td align=right><font size=\"+1\">Desc 1:</font></td><td><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$desc1&method=$method\">$desc1</a></td>";
					}else{
						$desc2 = $rowx[0];
						$png = sprintf("%02d",$rowx[1]);
						$desc2png = "<img src=\"http://supramap.osu.edu/cov114/icons/$png.png\" height=15 width=15>";
						$local .= "<td align=right><font size=\"+1\">Desc 2:</font></td><td><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$desc2&method=$method\">$desc2</a></td></tr>";
						}
					}
					$descx = "<tr><td align=left width=70></td><td align=left width=70><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$desc1&method=$method\">$desc1png</a></td><td align=left><a href=\"http://supramap.med.ohio-state.edu/cov114/fly_to.php?name=$desc2&method=$method\">$desc2png</a></td></tr>
<tr><td width=70></td><td align=left colspan=2><img src=\"http://supramap.osu.edu/cov114/icons/tree2.png\"></td></tr>";
		}
$coord1 = "select id,host from $pj where anc_id='$row[2]' and id!='$row[0]'";
		$query1 = pg_query($coord1);
        		   while($rowx = pg_fetch_row($query1)){
				    $sister = $rowx[0];
						$png = sprintf("%02d",$rowx[1]);
						$sispng = "<img src=\"http://supramap.osu.edu/cov114/icons/$png.png\" height=15 width=15>";
						$local = "<td align=right><font size=\"+1\">Sister:</font></td><td><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$sister&method=$method\">$sister</a></td></tr>".$local;
					}
$coord1 = "select id,host from $pj where id='$row[2]'";
		$query1 = pg_query($coord1);
        		   while($rowx = pg_fetch_row($query1)){
						$png = sprintf("%02d",$rowx[1]);
						$ancpng = "<img src=\"http://supramap.osu.edu/cov114/icons/$png.png\" height=15 width=15>";
					}

$local = "<table><tr><td align=right><font size=\"+1\">Anc:</font></td><td><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$row[2]&method=$method\">$row[2]</a></td>".$local."</table>";

$bgcolor = str_split($color,2);
$bgcolor = $bgcolor[3].$bgcolor[2].$bgcolor[1];
$s_lat = $lat;
$s_long = $long;
$alt_plus = $alt + 100000;
$alt_lk = $alt + 200;
if($root_nm == $row[0]){
	$tree = "<Placemark id=\"pm_$row[0]\">
	<visibility>1</visibility>
<name>$row[0]</name><Snippet maxLines=\"0\">
empty  </Snippet>
<LookAt>
<longitude>$long</longitude>
<latitude>$lat</latitude>
<altitude>$alt_lk</altitude>
<range>500</range>
<tilt>10</tilt>
<heading>0</heading>
</LookAt>
<description></description>	$styleurl<Style>
<LineStyle id=\"ls_$row[0]\">
<color>FFffffff</color>
</LineStyle>
</Style>
<MultiGeometry>
<Point id=\"$row[0]\"><altitudeMode>relativeToGround</altitudeMode>
<coordinates>$long,$lat,$alt</coordinates>
</Point>
<LineString>
    <tessellate>1</tessellate>
    <altitudeMode>absolute</altitudeMode>
    <coordinates>
$long,$lat,$alt
$long,$lat,$alt_plus
</coordinates>
</LineString></MultiGeometry>

</Placemark>";

}else{
$tree = "<Placemark id=\"pm_$row[0]\">
	<visibility>1</visibility>
<name>$row[0]</name><Snippet maxLines=\"0\">
empty  </Snippet>
<LookAt>
<longitude>$long</longitude>
<latitude>$lat</latitude>
<altitude>$alt_lk</altitude>
<range>500</range>
<tilt>10</tilt>
<heading>0</heading>
</LookAt>
<description><![CDATA[
<text>
<body bgcolor=\"#010101\">
<table width=450 border=\"0\" bgcolor=#030303>


<tr valign=center> <td align=right>
<a href=\"http://supramap.osu.edu/cov114/readme.htm\"><font size=\"+2\">View Readme</font><br>(pop-up)</a>
</td><td>
</td><td align=left><a href=\"http://supramap.osu.edu/cov114/atv.php\"><font size=\"+2\">View Flat Tree</font><br>(pop-up)</a></td></tr>


<tr valign=center> <td align=left colspan=3>

					<table width=300>
						<tr align=center><td rowspan=2>
							<img src=\"http://supramap.osu.edu/cov114/icons/$host.png\" height=80>
						</td><td rowspan=2 valign=center>
							<a href=\"http://supramap.osu.edu/cov114/optimize.php?pos=host&state=x\" ><font size=\"+2\">Host</font></a>
						</td><td rowspan=2 valign=center>
							<a href=\"http://supramap.osu.edu/cov114/optimize.php?pos=pos479&state=x\" ><font size=\"+2\">AA479</font></a>
						</td><td rowspan=2 valign=center>
							<a href=\"http://supramap.osu.edu/cov114/optimize.php?pos=pos487&state=x\" ><font size=\"+2\">AA487</font></a>
						</td></tr>
</table>


</td></tr>


<tr><td colspan=2>
<table width=280>

<tr><td colspan=2 align=left><font size=\"+2\"><b>Local tree: </b></font> <i><a href=\"http://supramap.osu.edu/cov114/isolate.php?name=$row[0]&state=on\">trim tree</a>  or <a href=\"http://supramap.med.ohio-state.edu/cov114/isolate.php?name=$row[0]&state=off\">redraw</a></i></td></tr>
<tr><th></th></tr>
<tr><td colspan=2>$local</td></tr>
<tr><th></th></tr>
<tr><td colspan=2>
<table>
$descx

<tr>
	<td align=left width=70><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$sister&method=$method\">$sispng</a></td>
	<td align=left colspan=2><font color=\"#FF0000\">$row[0]</font></td>
</tr>
<tr><td align=left colspan=3><img src=\"http://supramap.osu.edu/cov114/icons/tree.png\"></td></tr>
<tr><td align=left colspan=3><a href=\"http://supramap.osu.edu/cov114/fly_to.php?name=$row[2]&method=$method\">$ancpng</a></td></tr>

<tr><td colspan=4><br><br></td></tr><tr><td colspan=3 align=right><font size=\"+1\">
Nucleotide Sequence:</font></a></td><td align=left><a href=\"http://supramap.osu.edu/cov114/sequence.php?id=$row[0]\"><i>$row[0]</i></a>
</td></tr>
<tr><td colspan=3 align=right><font size=\"+1\">
Ancestral Sequence:</font></td><td align=left><a href=\"http://supramap.osu.edu/cov114/sequence.php?id=$row[2]\"><i>$row[2]</i></a>
</td></tr>
$genbank
</table>
</td>
</tr>

</table>

</td>
<td>

<table border=\"1\" align=\"center\"><tr><td>
<table border=\"0\" align=\"center\">

<tr><td colspan=3 align=center><b><font size=\"+2\" color=\"#FF0000\">Transformations</font></b></td></tr>
<tr><td><i>Position</td><td><i>Anc</td><td><i>Desc</i></td></tr>";
$trans = "";
$changes = 0;
$select = "select id,anc_id,position,state,anc_state from transformations_$pj where id='$row[0]' order by position asc limit 50";
		$queryx = pg_query($select);
        		   while($rowx= pg_fetch_row($queryx)){
        		    $anc = strtoupper($rowx[4]);
        		    $cur = strtoupper($rowx[3]);
        		    $trans .= "<tr><td align=right><a href=\"http://supramap.osu.edu/cov114/optimize.php?pos=$rowx[2]&state=p\">$rowx[2]</a></td><td align=center><a href=\"http://supramap.med.ohio-state.edu/cov114/optimize.php?pos=$rowx[2]&state=$anc\"><font size=\"+1\">$anc</font</a></td><td align=center><a href=\"http://supramap.med.ohio-state.edu/cov114/optimize.php?pos=$rowx[2]&state=$cur\"><font size=\"+1\">$cur</font></a></td></tr>";
        		    $changes++;
        		    }
if($trans==""){
	$trans = "<tr><td align=center colspan=3>no tranformations</td></tr>";
}
$tree .= $trans;
if($changes>49){
	$tree .= "<tr><td colspan=\"4\"><a href=\"http://supramap.osu.edu/cov114/more.php?id=$row[0]\"><i>More</i></a>";
}

$tree .= "</table></td></tr></table></td></tr>

<tr>
<td colspan=3 align=center>
	<table  bordercolor=\"#$bgcolor\" frame=\"hsides\">
				<tr><td align=center>

	<a href=\"http://medicalcenter.osu.edu/research/\">
	<img src=\"http://supramap.osu.edu/cov114/icons/osu.jpg\" height=50></a>
				</td>
				<td align=center>
	<a href=\"http://www.colorado.edu/eeb/\">
	<img src=\"http://supramap.osu.edu/cov114/icons/cu.gif\" height=40></a>
				</td>
				<td align=center>
	<a href=\"http://www.amnh.org/\">
	<img src=\"http://supramap.osu.edu/cov114/icons/amnh.gif\" height=50></a>
	</td></tr>
			</table>



</td></tr>
</table></body></text>	]]></description>
$styleurl
<Style>
<BalloonStyle>
	<textColor>$color</textColor>
	<bgColor>FFDBBFA4</bgColor>
</BalloonStyle>
<LineStyle id=\"ls_$row[0]\">
<color>$color</color>
</LineStyle>
</Style>
<MultiGeometry>
<Point id=\"$row[0]\"><altitudeMode>relativeToGround</altitudeMode>
<coordinates>$long,$lat,$alt</coordinates>
</Point>
<LineString>
    <tessellate>1</tessellate>
    <altitudeMode>absolute</altitudeMode>";

fwrite($fw,$tree);

$coord2 = "select $method,id,rank from $pj where id='$row[2]'";
		$query2 = pg_query($coord2);
        		   while($row2 = pg_fetch_row($query2)){
        		    $a_latlong = explode(" ",$row2[0]);
					$a_lat = explode(")",$a_latlong[1]);
					$a_long = explode("(",$a_latlong[0]);
					$a_lat = $a_lat[0];
					$a_long = $a_long[1];
					$new_id = $row2[1];
					$a_alt = $row2[2];
					}
$a_alt = $anc_vert*$a_alt;

			$long1 = $long;
			$long2 = $a_long;
			$value = $long1 - $long2;
			$value = abs($value);

			IF($value>180){
				IF(abs($long2)<abs($long1)){
					$long1 = 180 - abs($long1);
					IF($long2<0){
						$long1 = -180 - $long1;
						$fix = 360;
					}else{
						$long1 = 180 + $long1;
						$fix = -360;
					}
				}else{
					$long2 = 180 - abs($long2);
					IF($long1<0){
						$long2 = -180 - $long2;
						$fix = 360;
					}else{
						$long2 = 180 + $long2;
						$fix = -360;
					}
				}
			}


$long_con = ($long2 - $long1)/40;
$lat_con = ($a_lat-$lat)/40;
$linecount = 2;
$curve_count = 0;
$alt_con = ($a_alt-$alt)/40;

$last = " ".$a_long.",".$a_lat.",$a_alt\n";
$first = $s_long.",".$s_lat.",$alt\n";

$linestring = $first;

$count = 40;
$color = 100;
while($linecount<40){

	$long = $long + $long_con;
	IF($long>180){
		$long = (-360+$long) ;
		}
	IF($long<-180){
		$long = (360+$long) ;
		}
	$lat = $lat + $lat_con;
	$alt = $alt + $alt_con;

$linestring .= $long.",".$lat.",".$alt."\n";

	$linecount++;
}
$linestring .= $last;

$tree = "<coordinates>$linestring</coordinates>
</LineString></MultiGeometry>
</Placemark>";
}
fwrite($fw,$tree);
}




$tree = "</Folder><Folder><name>legends></name>
<ScreenOverlay id=\"so_host\">
<name>Icon Legend</name>
<visibility>1</visibility>
<Icon>
<href>http://supramap.osu.edu/cov114/host_legend.png</href>
</Icon>
<overlayXY x=\"0\" y=\"0\" xunits=\"fraction\" yunits=\"fraction\"/>
<screenXY x=\"0.02\" y=\"0.02\" xunits=\"fraction\" yunits=\"fraction\"/>
<rotationXY x=\"0.5\" y=\"0.5\" xunits=\"fraction\" yunits=\"fraction\"/>
<size x=\"-1\" y=\"-1\" xunits=\"pixels\" yunits=\"pixels\"/>
</ScreenOverlay>";
$tree .= 		"<ScreenOverlay id=\"so_char\">
<name>Icon Legend</name>
<visibility>0</visibility>
<Icon>
<href>http://supramap.osu.edu/cov114/char_legend.png</href>
</Icon>
<overlayXY x=\"0\" y=\"0\" xunits=\"fraction\" yunits=\"fraction\"/>
<screenXY x=\"0.02\" y=\"0.02\" xunits=\"fraction\" yunits=\"fraction\"/>
<rotationXY x=\"0.5\" y=\"0.5\" xunits=\"fraction\" yunits=\"fraction\"/>
<size x=\"-1\" y=\"-1\" xunits=\"pixels\" yunits=\"pixels\"/>
</ScreenOverlay>

<ScreenOverlay id=\"pos_479\">
<name>Icon Legend</name>
<visibility>0</visibility>
<Icon>
<href>http://supramap.osu.edu/cov114/pos_479.png</href>
</Icon>
<overlayXY x=\"0\" y=\"0\" xunits=\"fraction\" yunits=\"fraction\"/>
<screenXY x=\"0.02\" y=\"0.02\" xunits=\"fraction\" yunits=\"fraction\"/>
<rotationXY x=\"0.5\" y=\"0.5\" xunits=\"fraction\" yunits=\"fraction\"/>
<size x=\"-1\" y=\"-1\" xunits=\"pixels\" yunits=\"pixels\"/>
</ScreenOverlay>

<ScreenOverlay id=\"pos_487\">
<name>Icon Legend</name>
<visibility>0</visibility>
<Icon>
<href>http://supramap.osu.edu/cov114/pos_487.png</href>
</Icon>
<overlayXY x=\"0\" y=\"0\" xunits=\"fraction\" yunits=\"fraction\"/>
<screenXY x=\"0.02\" y=\"0.02\" xunits=\"fraction\" yunits=\"fraction\"/>
<rotationXY x=\"0.5\" y=\"0.5\" xunits=\"fraction\" yunits=\"fraction\"/>
<size x=\"-1\" y=\"-1\" xunits=\"pixels\" yunits=\"pixels\"/>
</ScreenOverlay>


</Folder>";
$tree .= "</Document></kml>";

fwrite($fw,$tree);

fclose($fw);


$zip = new ZipArchive();
$filename = "cov_sars.kmz";

if ($zip->open($filename, ZIPARCHIVE::CREATE)!==TRUE) {
    exit("cannot open <$filename>\n");
}

$zip->addFile('cov_sars.kml','cov_sars.kml');
echo "numfiles: " . $zip->numFiles . "\n";
echo "status:" . $zip->status . "\n";
$zip->close();

/////CREATE VIEW kml_ny500_janies AS SELECT distinct on (nodes_ny500_janies.id) nodes_ny500_janies.id AS id, nodes_ny500_janies.anc_id AS anc_id,astext(geometry_ny500_janies.centroid) AS centroid,astext(geometry_ny500_janies.biased) AS biased,geometry_ny500_janies.date AS date,descendants_ny500_janies.rank AS rank FROM nodes_ny500_janies,descendants_ny500_janies,geometry_ny500_janies WHERE (geometry_ny500_janies.id = nodes_ny500_janies.id and descendants_ny500_janies.desc_id = nodes_ny500_janies.id) or (geometry_ny500_janies.id = nodes_ny500_janies.id and nodes_ny500_janies.anc_id is null)s
?>
