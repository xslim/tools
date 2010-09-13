<?php
/*
Usage:
http://127.0.0.1/apns/apns.php?message=Hello%20from%20macoscoders&badge=2&sound=received5.caf
http://127.0.0.1/apns/apns.php?deviceToken=d5025023632fc36640110e5cd646ba9f5e8f0a71180617295709a0d5e00038f7
*/

// Taras Kalapun
$deviceToken = 'd5025023632fc36640110e5cd646ba9f5e8f0a71180617295709a0d5e00038f7';

$deviceToken = (!empty($_REQUEST['deviceToken'])) ? $_REQUEST['deviceToken'] : $deviceToken;

// Slava
//$deviceToken = 'c5d0ed46bf3ec7a1209fd31068d64c8069a02cf2548d9920c850eb1cf0365dbd';

// Get the parameters from http get
$message = (!empty($_REQUEST['msg'])) ?      $_REQUEST['msg'] : 'Test: test message:)!';
$badge   = (!empty($_REQUEST['badge']))   ? (int)$_REQUEST['badge']   : null;
$sound   = (!empty($_REQUEST['sound']))   ?      $_REQUEST['sound']   : null;
$acme1   = (!empty($_REQUEST['acme1']))   ?      $_REQUEST['acme1']   : null;

$cert = (!empty($_REQUEST['cert'])) ? $_REQUEST['cert'] : 'ck';
$certPass = (!empty($_REQUEST['certPass'])) ? $_REQUEST['certPass'] : '1111';


$isSandbox = (!empty($_REQUEST['isSandbox'])) ? $_REQUEST['isSandbox'] : 1;
$isDebug = (!empty($_REQUEST['isDebug'])) ? $_REQUEST['isDebug'] : 0;

$host = ($isSandbox) ? 'ssl://gateway.sandbox.push.apple.com:2195' : 'ssl://gateway.push.apple.com:2195';

// Construct the notification payload
$body = array();
$body['aps']['alert'] = $message;
if ($badge) $body['aps']['badge'] = $badge;
if ($sound) $body['aps']['sound'] = $sound;
if ($acme1) $body['acme1'] = $acme1;

/* End of Configurable Items */
$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', $cert.'.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $certPass);

$fp = stream_socket_client($host, $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);

$payload = json_encode($body);
$msg = chr(0) . pack("n",32) . pack('H*', str_replace(' ', '', $deviceToken)) . pack("n",strlen($payload)) . $payload;

if ($isDebug) {
	if (!$fp) {
		print "Failed to connect $err $errstr \n";
		return;
	} else {
		print "Connection OK.\n";
	}
	print "Sending message :" . $payload . "\n";
}

fwrite($fp, $msg);
fclose($fp);

?>
