<?php

require_once('ExcelExportClass.php');
require_once('contentrendering.php');	

    class export extends contentrendering{
		/*
		
		*/

		function convertData(){
			$header = array();//t3lib_div::_GP('header');//name & type (default String)
			$data = array();//t3lib_div::_GP('data');
			$author = 'borg';//t3lib_div::_GP('author');
			$date = '20000';//t3lib_div::_GP('date');//2005-08-02T04:30:11Z
			$version = '0.0';


			$xls = new ExcelExportClass();
			$xls->addRow(Array("First Name","Last Name","Website","ID"));
$xls->addRow(Array("james","lin","www.chumby.net",0));
$xls->addRow(Array("bhaven","mistry","www.mygumballs.com",1));
$xls->addRow(Array("erica","truex","www.wholegrainfilms.com",2));
$xls->addRow(Array("eliot","gann","www.dissolvedfish.com",3));
$xls->addRow(Array("trevor","powell","gradius.classicgaming.gamespy.com",4));
			$xls->download("websites.xls");

		}


	}

export::convertData();
?>