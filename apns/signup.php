<?php

$appId = (!empty($_REQUEST['appId'])) ? $_REQUEST['appId'] : '';
$deviceToken = (!empty($_REQUEST['deviceToken'])) ? $_REQUEST['deviceToken'] : '';


if (empty($appId) || empty($deviceToken)) return;

$iniFile = 'config.ini';

$config = parse_ini_file($iniFile, true);

if (!is_array($config[$appId]['device']) || !in_array($deviceToken, $config[$appId]['device'])) {
	$config[$appId]['device'][] = $deviceToken;
	write_ini_file($config, $iniFile, true);
}

function write_ini_file($assoc_arr, $path, $has_sections=false) { 
    $content = ""; 
    if ($has_sections) { 
        foreach ($assoc_arr as $key=>$elem) { 
            $content .= "[".$key."]\n"; 
            foreach ($elem as $key2=>$elem2) { 
                if(is_array($elem2)) 
                { 
                    for($i=0;$i<count($elem2);$i++) 
                    { 
                        $content .= $key2."[] = \"".$elem2[$i]."\"\n"; 
                    } 
                } 
                else if($elem2=="") $content .= $key2." = \n"; 
                else $content .= $key2." = \"".$elem2."\"\n"; 
            } 
        } 
    } 
    else { 
        foreach ($assoc_arr as $key=>$elem) { 
            if(is_array($elem)) 
            { 
                for($i=0;$i<count($elem);$i++) 
                { 
                    $content .= $key2."[] = \"".$elem[$i]."\"\n"; 
                } 
            } 
            else if($elem=="") $content .= $key2." = \n"; 
            else $content .= $key2." = \"".$elem."\"\n"; 
        } 
    } 

    if (!$handle = fopen($path, 'w')) { 
        return false; 
    } 
    if (!fwrite($handle, $content)) { 
        return false; 
    } 
    fclose($handle); 
    return true; 
}

?>