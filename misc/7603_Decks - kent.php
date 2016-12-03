<? 
error_reporting(E_ALL|E_STRICT);
ini_set('display_errors', true);

include_once('db.txt');
	
	

function array2csv(array &$array)
{
   if (count($array) == 0) {
     return null;
   }
   ob_start();
   $df = fopen(date("Ymd_His").'.csv', 'a');
   foreach ($array as $row) {
      fputcsv($df, $row);
   }
   fclose($df);
   return ob_get_clean();
}


function getMembers(){
	
	if( $curl = curl_init() ) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_URL,"https://mobile.tyrantonline.com/api.php?message=updateFaction&user_id=3565325");
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, 'password=d9810b1022d7984267a0d77c9ede08bc=Unity4_6_6&client_version=61&target_user_id=4401099&user_id=3565325&timestamp=1469168029&hash=6be150e702e89f2e154ad66c4cdad8c5&syncode=74c74bd19cbd75b48cd993c81e13a1180c31a44922c00b3ed40d739d202a2751&client_version=61&device_type=Intel(R)+Core(TM)+i3-2350M+CPU+%40+2.30GHz+(6049+MB)&os_version=Windows+7+Service+Pack+1+(6.1.7601)+64bit&platform=Web&kong_id=15485404&kong_token=6448056933a0383f4dac7caee4462713dcf9d90e09cd6e73dd5af469cc141203&kong_name=kentasaurus');  //Post Fields
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$headers = array();
		$headers[] = 'X-Apple-Tz: 0';
		$headers[] = 'X-Apple-Store-Front: 143444,12';
		$headers[] = 'Accept: *\*';
		$headers[] = 'Connection: keep-alive';
		$headers[] = 'Cache-Control: no-cache';
		$headers[] = 'Content-Type:application/json';
		$headers[] = 'Host: mobile.tyrantonline.com';
		$headers[] = 'User-Agent: tyrantmobile/1.26 CFNetwork/672.0.8 Darwin/14.0.0';
		$headers[] = 'X-MicrosoftAjax: Delta=true';
		$headers[] = 'X-Requested-With:XMLHttpRequest';
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		$server_output = curl_exec ($ch);
		curl_close ($ch);
		return $server_output;
	}
}

function getCards($user_id){
	
	if( $curl = curl_init() ) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_URL,"https://mobile.tyrantonline.com/api.php?message=getProfileData&user_id=3565325");
		curl_setopt($ch, CURLOPT_POST, 1);
		
		curl_setopt($ch, CURLOPT_POSTFIELDS, 'api_stat_time=269&api_stat_name=updateFaction&password=d9810b1022d7984267a0d77c9ede08bc&unity=Unity4_6_6&client_version=61&target_user_id='.$user_id.'&user_id=3565325&timestamp=1469170044&hash=a70bdacbea4c4851adfa8be65ba9dd5c&syncode=74c74bd19cbd75b48cd993c81e13a1180c31a44922c00b3ed40d739d202a2751&client_version=61&device_type=Intel(R)+Core(TM)+i5+CPU+750+@+2.67GHz+(10236+MB)&os_version=Windows+7+Service+Pack+1+(6.1.7601)+64bit&platform=Web&kong_id=15485404&kong_token=6448056933a0383f4dac7caee4462713dcf9d90e09cd6e73dd5af469cc141203&kong_name=kentasaurus&data_usage=212421');  //Post Fields
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		$headers = array();
		$headers[] = 'X-Apple-Tz: 0';
		$headers[] = 'X-Apple-Store-Front: 143444,12';
		$headers[] = 'Accept: *\*';
		$headers[] = 'Connection: keep-alive';
		$headers[] = 'Cache-Control: no-cache';
		$headers[] = 'Content-Type:application/json';
		$headers[] = 'Host: mobile.tyrantonline.com';
		$headers[] = 'User-Agent: tyrantmobile/1.26 CFNetwork/672.0.8 Darwin/14.0.0';
		$headers[] = 'X-MicrosoftAjax: Delta=true';
		$headers[] = 'X-Requested-With:XMLHttpRequest';
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		$server_output = curl_exec ($ch);
		curl_close ($ch);
		return $server_output;
	}

}




	$main = array();
	
	
	
	$members = getMembers();
	$m = json_decode($members);
	$m = $m->faction->members;
	
	foreach($m as $k=>$y){
		$name = $y->name.'';
	
	
		$main[]=array('name');
		$main[]=array($name);
		
		
		//echo $y->user_id.'<hr>';
		
		$server_output = getCards($y->user_id);
		
		
		
		$p = json_decode($server_output);
		
		
		///------------------- DECK1 ------------------------------------
		$deck1 = array();
		
		$deck1[] = $commander_id = $d[$p->player_info->deck->commander_id][0];
		$deck1[] = $deck_id =  $p->player_info->deck->deck_id;
		
		echo '<hr>';
		echo 'commander_id = '.$commander_id.'<br>';
		echo 'deck_id = '.$deck_id.'<br>';
		echo '<hr>';
		$cards = $p->player_info->deck->cards;
		
		foreach($cards as $c){
			
			$deck1[] = $d[$c][0] .' -'.$d[$c][1].'';
			
		}
		$main[] = $deck1;
		
		
		///------------------- DECK2 ------------------------------------
		$deck2 = array();
		
		$deck2[] = $commander_id =  $d[$p->player_info->defense_deck->commander_id][0];
		$deck2[] = $deck_id =  $p->player_info->defense_deck->deck_id;
		
		echo '<hr>';
		echo 'commander_id = '.$commander_id.'<br>';
		echo 'deck_id = '.$deck_id.'<br>';
		echo '<hr>';
		$cards='';
		$cards = $p->player_info->defense_deck->cards;
		
		 
		foreach($cards as $c){
			$deck2[] = $d[$c][0] .' -'.$d[$c][1].'';         		
		}

		$main[] = $deck2;
		/**/
		
		
		flush();
	
	}

	array2csv($main);

?>