<?php


require_once('contentrendering.php');	

    class excelexport extends contentrendering{
		/*
		
		*/

		function convertData(){
			$header = array();//t3lib_div::_GP('header');//name & type (default String)
			$data = array();//t3lib_div::_GP('data');
			$author = 'borg';//t3lib_div::_GP('author');
			$date = '20000';//t3lib_div::_GP('date');//2005-08-02T04:30:11Z
			$version = '0.0';



  header( "content-type: text/xml" );

  print "<?xml version=\"1.0\"?>\n";
  print "<?mso-application progid=\"Excel.Sheet\"?>\n";
  $str='<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:html="http://www.w3.org/TR/REC-html40">
  <DocumentProperties 
     xmlns="urn:schemas-microsoft-com:office:office">
 <Author>'.$author.'</Author>
  <LastAuthor>'.$author .'</LastAuthor>
  <Created>'.$date .'</Created>
  <LastSaved>'.$date .'</LastSaved>
  <Company>'. $company .'</Company>
  <Version>'. $version .'</Version>
  </DocumentProperties>
  <ExcelWorkbook 
     xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>8535</WindowHeight>
  <WindowWidth>12345</WindowWidth>
  <WindowTopX>480</WindowTopX>
  <WindowTopY>90</WindowTopY>
  <ProtectStructure>False</ProtectStructure>
  <ProtectWindows>False</ProtectWindows>
  </ExcelWorkbook>
  <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
  <Alignment ss:Vertical="Bottom"/>
  <Borders/>
  <Font/>
  <Interior/>
  <NumberFormat/>
  <Protection/>
  </Style>
  <Style ss:ID="s21" ss:Name="Hyperlink">
  <Font ss:Color="#0000FF" ss:Underline="Single"/>
  </Style>
  <Style ss:ID="s23">
  <Font x:Family="Swiss" ss:Bold="1"/>
  </Style>
  </Styles>
  <Worksheet ss:Name="Names">
  <Table ss:ExpandedColumnCount="4"
  ss:ExpandedRowCount="'.(count( $data ) + 1)  .'"
  x:FullColumns="1" x:FullRows="1">
  <Column ss:Index="'. count( $header ).'" ss:AutoFitWidth="0" ss:Width="154.5"/>
  <Row ss:StyleID="s23">
';

  foreach($header as $h){
  $str .='<Cell><Data ss:Type="'.$h['type'].'">'.$h['name'].'</Data></Cell>';
  }

    $str .='</Row>
';
  
  
  foreach( $data as $row ) {
	  $str.='<Row>
';
		foreach( $header as $k=>$v) {
			//$k is really just a numeric counter
			  $str.='	<Cell><Data ss:Type="String">'.$row[$k].'</Data></Cell>
';
		}
	 $str.=' </Row>
';
  }

 $str .='</Table>
  <WorksheetOptions 
     xmlns="urn:schemas-microsoft-com:office:excel">
  <Print>
  <ValidPrinterInfo/>
  <HorizontalResolution>300</HorizontalResolution>
  <VerticalResolution>300</VerticalResolution>
  </Print>
  <Selected/>
  <Panes>
  <Pane>
  <Number>3</Number>
  <ActiveRow>1</ActiveRow>
  </Pane>
  </Panes>
  <ProtectObjects>False</ProtectObjects>
  <ProtectScenarios>False</ProtectScenarios>
  </WorksheetOptions>
  </Worksheet>
  </Workbook>';

  echo $str;


  		}



	}

excelexport::convertData();