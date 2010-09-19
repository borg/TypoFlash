<?php

/*
 *
 * FILTERS
 *
 * This file is for configuring IDV's Show/Hide filters.
 *
 * IDV first finds all files matched by the Show filters. From the resulting
 * list, it then excludes all files matched by the Hide filters. This allows
 * for advanced control of the file listings.
 *
 * Note that while IDV's filters can hide files from the listings, the files
 * can still be accessed via direct URLs and therefore the filters should not
 * be used for security purposes. However, as of version 2006.2, browsing of
 * directories marked as "hidden", by specifying them in the $_GET['dir'],
 * is not allowed. 
 *
 * If you wish to change this behavior, set the DisableHiddenDirectViewing
 * option in the config to false.
 *
 *
 * Show filters go between the <<<SHOW and SHOW; tags,
 * Hide filters go between the <<<HIDE and HIDE; tags. Multiple filters are
 * separated by newlines.
 *
 *
 * To make a filter case insensitive, prepend its name with "i:".
 *
 * "*" and "?" can be used as wildcards. "*" will match any sequence of
 * characters and "?" will match any single character. Examples:
 *
 * Match all files:                                          *
 * Match all files with a .jpg extension:                    *.jpg
 * Match all files with a .jpg extension, case insensitive:  i:*.jpg
 * Match files whose names contain "foo":                    *foo*
 * Match files whose names are 3 or more characters long:    ???*
 *
 */


$filters['show'] = <<<SHOW

*

SHOW;


$filters['hide'] = <<<HIDE

index.php
_idv*
*/_idv*

HIDE;

?>