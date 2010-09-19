<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Close</title>
			<script type="text/javascript">
			/*<![CDATA[*/
				
			if(thisMovie("main").externalEdit){
			
				thisMovie("main").externalEdit("<?php echo $_GET['key']; ?>");
			}
			self.close();




			function thisMovie(movieName) {
				if (navigator.appName.indexOf("Microsoft") != -1) {
					return window.opener[movieName]
				}
				else {
					return window.opener.document[movieName]
				}
			}
			/*]]>*/
			</script>
</head>
<body>
</body>
</html>