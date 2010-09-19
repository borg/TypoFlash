<?php

// Tell the service explorer not to list this file.
//no_explore

// Init stuff

$resdir    = '_idvr';
$version   = '2006.5';
require $resdir.'/functions.php';
$starttime = microtime_c(); // PHP4 compatible microtime, see functions.php for details

define('base', dirname(__file__));
define('NL', "\n");

// Load config

if(file_exists($configfile = $resdir.'/config.ini')) {

  $conf = parse_ini_file($configfile);

} else {

  die('Error: could not load configuration file (config.ini). Please make sure it is in the '.$resdir.' directory.');

}

// Load language file

if(file_exists($langfile = $resdir.'/languages/'.$conf['Language'].'.ini')) {

  $lang = parse_ini_file($langfile, true);

} else {

  die('Error: could not load language file "'.$conf['Language'].'.ini". Please check your Language setting in '.$resdir.'/config.ini and make sure the appropriate language file exists in '.$resdir.'/languages.');

}

// More initialization

$filters     = array();
$headers     = array();
$templist    = array();
$list        = array();
$count       = array('file' => 0, 'dir' => 0);
$filelist    = '';
$totalsize   = 0;
$themeinfo   = '';
$dir_c       = ''; // Client-side directory
$dir_s       = ''; // Server-side directory
$dir_a       = false; // Whether this directory can be viewed
$newlocation = false;

// Clear stat cache if DisableStatCache is set to true

if($conf['DisableStatCache']) clearstatcache();

// Prepare filters

require $resdir.'/filters.php';
$filters = prepare_filters($filters);

// Check GET['dir'] data, clean up if necessary

$dir_c = isset($_GET['dir']) ? $_GET['dir'] : false;
$dir_s = pathcheck($dir_c, base);
$dir_c = substr($dir_s, strlen(base)+1);

if(isset($_GET['dir'])) {
  
  if($_GET['dir'] !== $dir_c) {
    
    $newlocation = './'.($dir_c ? '?dir='.pathurlencode($dir_c) : '');
  
  } elseif($conf['DisableHiddenDirectViewing']) {
  
    // Check if Show filters match current directory
  
    foreach($filters['show'] as $showf) {
      
      if(preg_match($showf, $dir_c)) {
      
        $dir_a = true;
        break;
      
      }
    
    }
    
    // Check if Hide filters match current directory
    
    if($dir_a) {
    
      foreach($filters['hide'] as $hidef) {
      
        if(preg_match($hidef, $dir_c)) {
        
          $dir_a = false;
          break;
        
        }
      
      }
    
    }
    
    // If hidden, go back to root directory
    
    if(!$dir_a) {
    
      $newlocation = './';
    
    }
  
  }

}

if($newlocation) redirect($newlocation);

$dir_c = (string) $dir_c;

// Create table headers

                          $headers['name']    = $lang['Headers']['Name'];
if($conf['ShowSizes'])    $headers['size']    = $lang['Headers']['Size'];
if($conf['ShowPerms'])    $headers['perms']   = $lang['Headers']['Permissions'];
if($conf['ShowModTimes']) $headers['modtime'] = $lang['Headers']['ModTime'];

// The dirty work

if($files = glob($dir_s.'/*')) {
  
  foreach($files as $n => $rfile) {
  
    $file         = array();
    $file['raw']  = substr($rfile, strlen(base)+1);    
    $file['show'] = false;
    $file['type'] = (is_dir($file['raw'])) ? 'dir' : 'file';
    $file['name'] = basename($file['raw']).($file['type'] == 'dir' && $conf['DirAppendSlashes'] ? '/' : '');
    $file['link'] = ($file['type'] == 'dir' ? '?dir=' :  '').pathurlencode($file['raw']);

    // Check Show filters

    foreach($filters['show'] as $showf) {
  
      if(preg_match($showf, $file['raw'])) {
      
        $file['show'] = true;
        break;
    
      }
  
    }

    // If file matched any Show filter, check Hide filters

    if($file['show']) {
  
      foreach($filters['hide'] as $hidef) {
    
        if(preg_match($hidef, $file['raw'])) {
        
          $file['show'] = false;
          break;

        }

      }

    }

    if($file['show']) {

      // Create a temporary list that can be sorted easily

      $templist[$n]['name'] = $file['name'];
      $templist[$n]['type'] = $file['type'];
      $templist[$n]['link'] = $file['link'];
      $templist[$n]['raw']  = $file['raw'];

      if($conf['ShowSizes']) {

        if($conf['FileSizeType'] == 'recursive') {
      
          $file['size'] = rfilesize($file['raw']);
      
        } elseif($conf['FileSizeType'] == 'diskspace') {
        
          $file['size'] = filespace($file['raw']);
      
        } else {
      
          $file['size'] = filesize($file['raw']);

        }
      
        $totalsize += $templist[$n]['size'] = $file['size'];

      }

      if($conf['ShowPerms']) {

        $file['perms']         = substr(sprintf('%o', fileperms($file['raw'])), -3);
        $templist[$n]['perms'] = ($conf['FilePermsType'] == 'symbolic' ? oct2sym($file['perms']) : $file['perms']);

      }

      if($conf['ShowModTimes']) {

        $file['modtime']         = filemtime($file['raw']);
        $templist[$n]['modtime'] = $file['modtime'];

      }
    
      if($conf['ShowFileCount']) {

        $count[$file['type']]++;

      }

    }
    
  }

  // Sorting
  // customsort() checks the config options, so no check is needed here
  // See functions.php for more details

  customsort($templist);
  
}

$filecount = count($templist);

// Check if the list contains any items

if($filecount > 0) {

  // Assemble the final list

  foreach($templist as $n => $tlval) {

    $list[$n]['name'] = '<a class="'.$tlval['type'].'" href="'.$tlval['link'].'">'.htmlentities($tlval['name']).'</a>';

	// Has user asked for PHP files to be displayed as source instead of run?
	if ($conf['ShowPHPSource']) 
	{
		// Yes, see if this is a PHP file and, if so, make a link to display its source.
		if (substr($tlval['name'], -4, 4) == '.php')
		{
			$list[$n]['name'] = '<a class="'.$tlval['type'].'" href="'.$resdir.'/showsource.php?file=../'.$tlval['link'].'"  target="_blank">'.htmlentities($tlval['name']).'</a>';
		}
		else
		{
			// Make it a regular link
			$list[$n]['name'] = '<a class="'.$tlval['type'].'" href="'.$tlval['link'].'">'.htmlentities($tlval['name']).'</a>';
		    
		}
	}
    
    if($conf['ShowSizes'])    $list[$n]['size']    = htmlentities($conf['FileSizeType'] == 'simple' && $tlval['type'] == 'dir' ? '--' : efilesize($tlval['size'], $conf['RoundSizes'], $lang['Num']));
    if($conf['ShowPerms'])    $list[$n]['perms']   = htmlentities($tlval['perms']);
    if($conf['ShowModTimes']) $list[$n]['modtime'] = htmlentities(date($conf['DateTimeFormat'], $tlval['modtime']));

  }

} else {

  // Empty list

                            $list[0]['name']    = htmlentities($lang['General']['EmptyName']);
  if($conf['ShowSizes'])    $list[0]['size']    = htmlentities($lang['General']['Empty']);
  if($conf['ShowPerms'])    $list[0]['perms']   = htmlentities($lang['General']['Empty']);
  if($conf['ShowModTimes']) $list[0]['modtime'] = htmlentities($lang['General']['Empty']);
  
}

// Construct table

$filelist .= '<table id="list">'.NL;
$filelist .= '<tr>'.NL;

foreach($headers as $headerk => $headerv) {

  $filelist .= '<th class="'.$headerk.'"><span>'.htmlentities($headerv).'</span></th>'.NL;

}

$filelist .= '</tr>'.NL;

foreach($list as $item) {

  $filelist .= '<tr>'.NL;

  foreach($item as $itemk => $itemv) {

    $filelist .= '<td class="'.$itemk.'"><span>'.$itemv.'</span></td>'.NL;

  }

  $filelist .= '</tr>'.NL;

}

$filelist .= '</table>'.NL;

?>

<html>

<head>
<title><?php echo htmlentities($conf['Title']); ?></title>
<link rel="stylesheet" type="text/css" href="<?php echo $resdir.'/themes/'.$conf['Theme']; ?>" />

<?php 
	$oldFolder = getcwd();

	$servicesFolder = $oldFolder;
	chdir('../../flash/examples/');
	$examplesFolder = getcwd();
	chdir($oldFolder);

	$folderOverride = '../../';
	$current = 2; // Set services folder as root.
	require('../../header.php'); 
	chdir($oldFolder);

?>

<div id="wrap">

<h1><?php echo '<b>'.htmlentities($conf['Header']).'</b>'.($conf['ShowDateTime'] ? ' :: '.date($conf['DateTimeFormat']) : ''); ?></h1>

<?php

// InfoBox; parse comments away and evaluate

if($conf['InfoBox']) {
  $ibContent = file_get_contents($resdir.'/infobox.php');
  infobox('info1', $ibContent);

}

// Same as above, but for a per-directory info box

if($conf['DirInfoBox'] && file_exists($sInfoBox = $dir_s.'/'.$conf['DirInfoBoxFile'])) {

  $sIbContent = file_get_contents($sInfoBox);
  infobox('info2', $sIbContent);

}

?>

<div id="files">

<div id="nav">
<?php

// Create the path display

echo '<div id="path">'.construct_path_links($dir_c, $conf['DirectoryLabel']).'</div>'.NL;

// File count

if($conf['ShowFileCount']) {

  echo '<span id="filecount">'.NL;
  echo htmlentities(sprintf($lang['Nav']['FileCount'], $count['dir'], ($count['dir'] == 1 ? $lang['Nav']['DirsSingular'] : $lang['Nav']['DirsPlural']), $count['file'], ($count['file'] == 1 ? $lang['Nav']['FilesSingular'] : $lang['Nav']['FilesPlural'])));
  
  if($conf['ShowSizes'] && $conf['ShowDirTotalSize']) {
  
    echo '<span id="totalsize">';  
    echo htmlentities(sprintf($lang['Nav']['TotalSize'], efilesize($totalsize, $conf['RoundSizes'], $lang['Num'])));
    echo '</span>'.NL;
  
  }
  
  echo '</span>'.NL;

}

?>
<br class="cl" />
</div>

<?php echo $filelist; ?>

</div>

<?php

// Page generation time

if($conf['ShowGenTime']) {

  $gentime = number_format(microtime_c()-$starttime, $conf['RoundGenTime'], $lang['Num']['DecimalSeparator'], '');
  echo '<div id="gentime">';
  echo htmlentities(sprintf($lang['Footer']['PageGenerationTime'], $gentime));
  echo '</div>'.NL;

}

// Credits

if($conf['ShowCredits']) {

  $themecredits = file($resdir.'/themes/'.$conf['Theme']);

  if(substr($themecredits[0], 0, 2) == '/*') {

    if(
    preg_match('#\[thmname\](.*)$#', $themecredits[1], $theme_name) &&
    preg_match('#\[creator\](.*)$#', $themecredits[2], $theme_crtr)
    ) {

      $themeinfo = htmlentities(sprintf($lang['Footer']['CreditsTheme'], $theme_name[1], $theme_crtr[1]));

    } else {
    
      $themeinfo = '';
    
    }

  }

  $credits = '<div id="credits">'.NL.'<a href="http://idv.sf.net">'.htmlentities(sprintf($lang['Footer']['CreditsIDV'], $version)).'</a><span>'.$themeinfo.'</span>'.NL.'</div>';
  
  echo $credits;

}

?>
<br class="cl" />

</div>
<div id="footer">
<?php require('../../footer.php');  ?>