<?php
/*
Usage:
http://127.0.0.1/apns/apns.php?message=Hello%20from%20macoscoders&badge=2&sound=received5.caf
*/

// Taras Kalapun
$deviceToken = 'd5025023632fc36640110e5cd646ba9f5e8f0a71180617295709a0d5e00038f7';

// Slava
//$deviceToken = 'c5d0ed46bf3ec7a1209fd31068d64c8069a02cf2548d9920c850eb1cf0365dbd';

// Get the parameters from http get
$message = (!empty($_GET['msg'])) ?      $_GET['msg'] : 'Test: test message:)!';
$badge   = (!empty($_GET['badge']))   ? (int)$_GET['badge']   : null;
$sound   = (!empty($_GET['sound']))   ?      $_GET['sound']   : null;
$acme1   = (!empty($_GET['acme1']))   ?      $_GET['acme1']   : null;

// Construct the notification payload
$body = array();
$body['aps']['alert'] = $message;
if ($badge) $body['aps']['badge'] = $badge;
if ($sound) $body['aps']['sound'] = $sound;
if ($acme1) $body['acme1'] = $acme1;

/* End of Configurable Items */
$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', '1111');

$fp = stream_socket_client('ssl://gateway.sandbox.push.apple.com:2195', $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);
//$fp = stream_socket_client('ssl://gateway.push.apple.com:2195', $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);

if (!$fp) {
	print "Failed to connect $err $errstr \n";
	return;
}
else {
	print "Connection OK.\n";
}
$payload = json_encode($body);
$msg = chr(0) . pack("n",32) . pack('H*', str_replace(' ', '', $deviceToken)) . pack("n",strlen($payload)) . $payload;
print "Sending message :" . $payload . "\n";
fwrite($fp, $msg);
fclose($fp);
?>
