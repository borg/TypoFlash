<?php ?>
<HTML>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<HEAD>

<SCRIPT LANGUAGE="JavaScript">
if (parent.window.document.main) {

	var str = "<?php 

		$str = $_SERVER['QUERY_STRING'];
		$rstr = substr($str,0,strpos($str,'&_title')-1);//removes trailing &. Presumptuous perhaps
		echo $rstr;
	?>";
	var m = parent.window.document.main;
	if (m.updateFlashHistory !=null){
		m.updateFlashHistory(str);
	}

	//parent.window.location.hash = str;
	var title = "<?php 
	$t = $_GET['_title'];
	if($t!=null){	
		echo $t;
	}
	?>";
	//http://blogs.pathf.com/agileajax/2007/12/really-simple-1.html
	//not always correct title in history stack...but better than ugly hashes etc
	if(title != ""){
		document.title = title;
	}else{
		document.title = ' ';
	}
	//this will update the title of the parent window when going back and forth in history..else it seems only the iframe ttle changes
	parent.window.document.title = document.title;
}

</SCRIPT>

</HEAD>

</HTML>
