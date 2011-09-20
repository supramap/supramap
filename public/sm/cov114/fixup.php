<?php
 	$conn_var = "host=localhost port=5432 dbname=trees user=postgres password=password";
	$conn = pg_connect($conn_var)
			or die("Not Connected");






/////AA optimize
$count=0;
while($count<50){
	$select = "select id,anc_id from sars where pos479 is null and anc_id in (select id from sars where pos479 is not null)";
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){
				$id = $row[0];
				$anc_id = $row[1];
			   $select2="select pos479 from sars WHERE id='$anc_id'";
					$query2 = pg_query($select2);
	      		 	   while($row2 = pg_fetch_row($query2)){				
							$update = "UPDATE alignment_sars SET pos479='$row2[0]' WHERE id='$id' ;";
							pg_exec($conn,$update);
						}
					}
				$count++;
				}


/*

/////HOST
$count=0;
while($count<50){
	$select = "select id,anc_id from h5n1_677 where host is null and anc_id in (select id from h5n1_677 where host is not null)";
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){
				$id = $row[0];
				$anc_id = $row[1];
			   $select2="select host from h5n1_677 WHERE id='$anc_id'";
					$query2 = pg_query($select2);
	      		 	   while($row2 = pg_fetch_row($query2)){				
							$update = "UPDATE alignment_h5n1_677 SET host='$row2[0]' WHERE id='$id' ;";
							pg_exec($conn,$update);
						}
					}
				$count++;
				}


/*
/////RANK			
			
$id = "x";			
$root_name = "node_1353";
$check = "";
$check = array();
while(!($id == $root_name)){
	$coord = "select anc_id,max(rank) from nodes_h5n1_677 WHERE rank>-1 GROUP BY anc_id HAVING count(distinct id)=2";	
		$query = pg_query($coord);
        		   while($row = pg_fetch_row($query)){
				    IF(isset($check[$row[0]])){}else{
					$id = $row[0];
					$rank = $row[1]+1;			          
					$update = "UPDATE nodes_h5n1_677 SET rank=$rank WHERE id='$id' ;";
					pg_exec($conn,$update);
					$check = array_merge($check,array($row[0] => $id));
					}
				}
			}


//////DATE
			
$id = "x";			
$root_name = "node_1353";
$check = "";
$check = array();
$rank = 0;
while($rank<38){
	$select = "select anc_id,max(rank) from nodes_h5n1_677 WHERE rank<=$rank GROUP BY anc_id HAVING count(distinct id)=2";			
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){	
			   $id = $row[0];		
			   $select2="select min(date_of) from h5n1_677 WHERE anc_id='$id'";
			$query2 = pg_query($select2);
	       	   while($row2 = pg_fetch_row($query2)){
	       	    
			$update = "UPDATE geometry_h5n1_677 SET date_of = '$row2[0]' WHERE id='$id' ;";
			pg_exec($conn,$update);	
		}
		}
	$rank++;

}




/////BIASED	

/*
		
$id = "x";			
$root_name = "node_1353";
$check = "";
$check = array();
$rank = 0;
while($rank<38){
	$select = "select anc_id,max(rank) from nodes_h5n1_677 WHERE rank<=$rank GROUP BY anc_id HAVING count(distinct id)=2";
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){
			   $id = $row[0];
			   $first = 1;
			   $select2="select astext(biased),date_of from h5n1_677 WHERE anc_id='$id' order by date_of asc";
			$query2 = pg_query($select2);
	       	   while($row2 = pg_fetch_row($query2)){
	       	    $coords = explode("(",$row2[0]);
	       	    $coords = $coords[1];
	       	    $coords = explode(")",$coords);
	       	    $coords = $coords[0];
	       	    $coords = explode(" ",$coords);
				if($first == 1){
					$first = 2;
					$lat = $coords[1];
					$long = $coords[0];
					$date = $row2[1];
				}else{
					$a_lat = $coords[1];
					$a_long = $coords[0];
					$a_date = $row2[1];
				}
				}
			if(!($date==$a_date)){
			$update = "UPDATE geometry_h5n1_677 SET biased = geometryfromtext('POINT($long $lat)',4326) WHERE id='$id' ;";
			pg_exec($conn,$update);					
			}else{
			 
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
		$long_con = ($long2 + $long1)/2;	
		$lat_con = ($a_lat + $lat)/2;					   
		
	IF($long_con>180){
		$long_con = (-360+$long) ;
		}
	IF($long_con<-180){
		$long_con = (360+$long) ;
		}	   
			$update = "UPDATE geometry_h5n1_677 SET biased = geometryfromtext('POINT($long_con $lat_con)',4326) WHERE id='$id' ;";
			pg_exec($conn,$update);	
			   
			   }	
	}
	$rank++;
}			
			









/*


	

/*

/////H274Y
$count=0;
while($count<50){
	$select = "select id,anc_id from h5n1_677 where h274y is null and anc_id in (select id from h5n1_677 where h274y is not null)";
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){
				$id = $row[0];
				$anc_id = $row[1];
			   $select2="select h274y from h5n1_677 WHERE id='$anc_id'";
					$query2 = pg_query($select2);
	      		 	   while($row2 = pg_fetch_row($query2)){				
							$update = "UPDATE alignment_h5n1_677 SET h274y='$row2[0]' WHERE id='$id' ;";
							pg_exec($conn,$update);
						}
					}
				$count++;
				}
			
			
			

////ALIGNMENT
$id = "x";			
$root_name = "node_1353";
$check = "";
$check = array();
$rank = 0;
while($rank<38){
 $less = $rank - 1;
	$select = "select anc_id,max(rank) from nodes_h5n1_677 WHERE rank<=$rank and anc_id not in (select anc_id from nodes_h5n1_677 WHERE rank<=$less GROUP BY anc_id HAVING count(distinct id)=2) GROUP BY anc_id HAVING count(distinct id)=2";
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){
			   $id = $row[0];
			   $first = 1;
			   $select2="select id,align from h5n1_677 WHERE anc_id='$id'";
			$query2 = pg_query($select2);
	       	   while($row2 = pg_fetch_row($query2)){
				if($first == 1){
					$first = 2;
					$alignment = $row2[1];
					$name = $row2[0];
					$select3="select position,anc_state from transformations_h5n1_677 WHERE id='$name'";
						$query3 = pg_query($select3);
			       	   while($row3 = pg_fetch_row($query3)){
							   $select4="select overlay('$alignment' placing '$row3[1]' from $row3[0] for 1)";
								$query4 = pg_query($select4);
					       	   while($row4 = pg_fetch_row($query4)){
								   $alignment = $row4[0];
								   }						   	
						   }				
				}else{
					$name = $row2[0];
					   $select3="select position,anc_state from transformations_h5n1_677 WHERE id='$name'";
						$query3 = pg_query($select3);
			       	   while($row3 = pg_fetch_row($query3)){
							   $select4="select overlay('$alignment' placing '$row3[1]' from $row3[0] for 1)";
								$query4 = pg_query($select4);
					       	   while($row4 = pg_fetch_row($query4)){
								   $alignment = $row4[0];
								   }						   	
						   }			
					}
				}
	$update = "UPDATE alignment_h5n1_677 SET align='$alignment' WHERE id='$id' ;";
			pg_exec($conn,$update);	
			}	
			$rank++;
	}
	
/////CENTROID

$id = "x";			
$root_name = "node_227";
$check = "";
$check = array();
$rank = 0;
while($rank<30){
	$select = "select anc_id,max(rank) from nodes_sars WHERE rank<=$rank GROUP BY anc_id HAVING count(distinct id)=2";
		$query = pg_query($select);
       	   while($row = pg_fetch_row($query)){
			   $id = $row[0];
			   $first = 1;
			   $select2="select latitude,longitude from sars WHERE anc_id='$id'";
			$query2 = pg_query($select2);
	       	   while($row2 = pg_fetch_row($query2)){
				if($first == 1){
					$first = 2;
					$lat = $row2[0];
					$long = $row2[1];
				}else{
					$a_lat = $row2[0];
					$a_long = $row2[1];
				}
				}
			
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
		$long_con = ($long2 + $long1)/2;	
		$lat_con = ($a_lat + $lat)/2;					   
		
	IF($long_con>180){
		$long_con = (-360+$long) ;
		}
	IF($long_con<-180){
		$long_con = (360+$long) ;
		}	   
			$update = "UPDATE geometry_sars SET latitude='$lat_con',longitude='$long_con',centroid = geometryfromtext('POINT($long_con $lat_con)',4326) WHERE id='$id' ;";
			pg_exec($conn,$update);	
			   
			   }	
	
	$rank++;
}		
	*/
?>
