<?php

// Human-readable file size

function efilesize($rsize, $round, $math) {

  if($rsize < 0) {

    $rsize = sprintf('%u', $rsize);

  }

  if(($fsize = $rsize/1024/1024/1024) >= 1) {

    $prefix = $math['PrefixGiga'];

  } elseif(($fsize = $rsize/1024/1024) >= 1) {

    $prefix = $math['PrefixMega'];

  } elseif(($fsize = $rsize/1024) >= 1) {

    $prefix = $math['PrefixKilo'];

  } else {
  
    $fsize  = $rsize;
    $prefix = '';
  
  }

  return number_format($fsize, ($prefix ? $round : 0), $math['DecimalSeparator'], '').$math['UnitSeparator'].$prefix.($fsize == 1 ? $math['ByteSingular'] : $math['BytePlural']);

}

// Path check

function pathcheck($path, $base) {

  $path = realpath(str_replace('\\', '/', ($path ? $path : $base)));

  if(substr($path, 0, strlen($base)) == $base && is_dir($path)) {

    return $path;

  } else {

    return false;

  }

}

// Redirection

function redirect($url) {

  header('Location: '.$url);
  die();

}

// Path display

function construct_path_links($path, $toplevelname) {

  $path  = explode('/', rtrim('/'.$path, '/'));
  $apath = '';
  $links = array();

  foreach($path as $n => $current) {

    $apath .= $current.($n ? '/' : '');
    $links[] = '<a href="./'.($n ? '?dir='.pathurlencode(rtrim($apath, '/')) : '').'">'.htmlentities($n ? $current : $toplevelname).'</a>/';

  }

  return implode('', $links);

}

// Prepare Show/Hide filters

function prepare_filters($source) {

  $filters = array();

  foreach($source as $filterk => $filterv) {

    $filterv = preg_quote($filterv, '#');
    $filterv = str_replace('\*', '.*', $filterv);
    $filterv = str_replace('\?', '.', $filterv);
    $filterv = preg_split("#(?:\r\n|\r|\n)#", trim($filterv));

    foreach($filterv as $tfilterv) {

      if(preg_match('#^([a-z]):(.*)$#i', $tfilterv, $match)) {

        $filters[$filterk][] = '#^'.$match[2].'$#'.$match[1];

      } else {

        $filters[$filterk][] = '#^'.$tfilterv.'$#';

      }

    }

  }

  return $filters;

}

// Main sort function

function customsort(&$array) {

  usort($array, 'cmp');

}

// Comparison function for customsort()

function cmp($a, $b) {

  global $conf;

  if($conf['SortNatural'] && $conf['SortBy'] == 'name') {

    $sorted = strnatcasecmp($a['name'], $b['name']);

  } else {

    $sorted = ($a[$conf['SortBy']] == $b[$conf['SortBy']] ? 0 : ($a[$conf['SortBy']] < $b[$conf['SortBy']] ? -1 : 1));

  }

  if($conf['SortType'] == 'desc') $sorted = -$sorted;

  return $sorted;

}

// PHP4 compatible "enhanced" microtime()

function microtime_c() {

  return (version_compare(PHP_VERSION, '5.0.0', '>=') ? microtime(true) : array_sum(explode(' ', microtime())));

}

// Convert octal file permissions to symbolic notation

function oct2sym($perms) {

  $symperms = '';

  for($i = -1; $i++ < 2;) {
  
    $tperms    = $perms[$i];
    $symperms .= (($tperms -= 4) < 0 ? '-' : 'r');
    $symperms .= (($tperms -= 2) < 0 ? '-' : 'w');
    $symperms .= (($tperms -= 1) < 0 ? '-' : 'x');
  
  }
  
  return $symperms;

}

// Urlencode() a path, but keep slashes intact

function pathurlencode($path) {

  $pathArray = explode('/', $path);

  foreach($pathArray as $k => $v) $pathArray[$k] = rawurlencode($v);

  return implode('/', $pathArray);

}

// filespace() - the disk space used by a file/dir

function filespace($filename) {

  $stat = stat($filename);
  $space = $stat['blocks'] * 512;

  if(is_dir($filename)) {
    
    $files = glob(rtrim($filename, '/').'/*');
    
    foreach($files as $file) {
      
      $space += filespace($file);

    }

  }

  return $space;

}

// Recursive filesize()

function rfilesize($path) {

  if(!is_dir($path)) {

    return filesize($path);

  } else {

    $files = glob(rtrim($path, '/').'/*');
    $totalSize = 0;

    foreach($files as $file) {

      $totalSize += rfilesize($file);

    }

    return $totalSize;

  }

}

// Display an infobox

function infobox($id, $contents) {

  eval('?><div class="infobox" id="'.$id.'">'.NL.trim(preg_replace('#<!--.*-->#s', '', $contents)).NL.'</div>'.NL.'<?php ');

}

?>