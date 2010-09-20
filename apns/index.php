<?php

/**
 * APNS test
 * Developed by Taras Kalapun <t.kalapun@gmail.com>
 * http://kalapoun.com
 * Free for beer!
 */

$iniFile = 'config.ini';

$config = parse_ini_file($iniFile, true);

$message = (!empty($_REQUEST['message'])) ? $_REQUEST['message'] : '';
$badge   = (!empty($_REQUEST['badge']))   ? (int)$_REQUEST['badge']   : null;
$appId   = (!empty($_REQUEST['appId']))   ? $_REQUEST['appId'] : '';

if (!empty($message) && !empty($appId)) {
	
	// Construct the notification payload
	$body = array();
	$body['aps']['alert'] = $message;
	if ($badge) $body['aps']['badge'] = $badge;
	//if ($sound) $body['aps']['sound'] = $sound;
	//if ($acme1) $body['acme1'] = $acme1;
	
	$certPass = '1111';
	
	foreach ($config[$appId]['device'] as $deviceToken) {
		push_apns($body, $deviceToken, $appId, $certPass);
	}
}

?>

<html><body>
<center>
	
	<form name="apns" action="" method="POST">
		<b>Push to App ID:</b>
		<select name="appId">
			<option value=""></option>
			<?php foreach ($config as $key => $val) { echo '<option value="'.$key.'">'.$key.'</option>'."\n"; }?>
		</select>
		
		<b>Message:</b>
		<input type="text" name="message" value="Hello" />
		
		<b>Badge:</b>
		<input type="text" name="badge" value="" />
		
		<input type="submit" />
	</form>
	
</center>


<br /><br />
<b>Config:</b>
<pre>
<?php echo print_r($config, true); ?>
</pre>

</body></html>

<?php

function push_apns($body, $deviceToken, $certName, $certPass, $isSandbox=true) {
	
	$host = ($isSandbox) ? 'ssl://gateway.sandbox.push.apple.com:2195' : 'ssl://gateway.push.apple.com:2195';
	
	$ctx = stream_context_create();
	stream_context_set_option($ctx, 'ssl', 'local_cert', $certName.'.pem');
	stream_context_set_option($ctx, 'ssl', 'passphrase', $certPass);

	$fp = stream_socket_client($host, $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);

	$payload = json_encode($body);
	$msg = chr(0) . pack("n",32) . pack('H*', str_replace(' ', '', $deviceToken)) . pack("n",strlen($payload)) . $payload;

	fwrite($fp, $msg);
	fclose($fp);
}

?>
