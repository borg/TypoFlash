#
# Table structure for table 'pages'
#
CREATE TABLE pages (
	tx_typoflash_template int(11) unsigned DEFAULT '0' NOT NULL,
	tx_typoflash_conf text NOT NULL,
	tx_typoflash_data blob NOT NULL
);



#
# Table structure for table 'tx_typoflash_template'
#
CREATE TABLE tx_typoflash_template (
	uid int(11) unsigned DEFAULT '0' NOT NULL auto_increment,
	pid int(11) unsigned DEFAULT '0' NOT NULL,
	tstamp int(11) unsigned DEFAULT '0' NOT NULL,
	crdate int(11) unsigned DEFAULT '0' NOT NULL,
	cruser_id int(11) unsigned DEFAULT '0' NOT NULL,
	sorting int(10) unsigned DEFAULT '0' NOT NULL,
	deleted tinyint(4) unsigned DEFAULT '0' NOT NULL,
	hidden tinyint(4) unsigned DEFAULT '0' NOT NULL,
	starttime int(11) unsigned DEFAULT '0' NOT NULL,
	endtime int(11) unsigned DEFAULT '0' NOT NULL,
	fe_group int(11) DEFAULT '0' NOT NULL,
	name tinytext NOT NULL,
	width tinytext NOT NULL,
	height tinytext NOT NULL,
	version tinytext NOT NULL,
	asversion tinytext NOT NULL,
	menu tinyint(3) unsigned DEFAULT '0' NOT NULL,
	bgcolour tinytext NOT NULL,
	movieid tinytext NOT NULL,
	historyframe tinyint(3) unsigned DEFAULT '0' NOT NULL,
	file blob NOT NULL,
	css text NOT NULL,
	title tinytext NOT NULL,
	metakeyword text NOT NULL,
	metadesc text NOT NULL,
	searchengine tinyint(3) unsigned DEFAULT '0' NOT NULL,
	redirectpage tinytext NOT NULL,
	conf text NOT NULL,
	language_file blob NOT NULL,
	preloader blob NOT NULL,
	dynamic_fonts varchar(200) DEFAULT '' NOT NULL,
	fonts blob NOT NULL,
	swfs blob NOT NULL,
	hosturl tinytext NOT NULL,
	relaysocket tinytext NOT NULL,
	relayport tinytext NOT NULL,
	relayserver tinytext NOT NULL,
	codepage tinyint(3) unsigned DEFAULT '0' NOT NULL,
	scalemode varchar(8) DEFAULT '' NOT NULL,
	align char(2) DEFAULT '' NOT NULL,
	windowmode varchar(11) DEFAULT '' NOT NULL,
	fullscreen tinyint(3) unsigned DEFAULT '0' NOT NULL,
	
	PRIMARY KEY (uid),
	KEY parent (pid)
);



#
# Table structure for table 'tx_typoflash_component'
#
CREATE TABLE tx_typoflash_component (
	uid int(11) unsigned DEFAULT '0' NOT NULL auto_increment,
	pid int(11) unsigned DEFAULT '0' NOT NULL,
	tstamp int(11) unsigned DEFAULT '0' NOT NULL,
	crdate int(11) unsigned DEFAULT '0' NOT NULL,
	cruser_id int(11) unsigned DEFAULT '0' NOT NULL,
	sorting int(10) unsigned DEFAULT '0' NOT NULL,
	deleted tinyint(4) unsigned DEFAULT '0' NOT NULL,
	hidden tinyint(4) unsigned DEFAULT '0' NOT NULL,
	starttime int(11) unsigned DEFAULT '0' NOT NULL,
	endtime int(11) unsigned DEFAULT '0' NOT NULL,
	fe_group int(11) DEFAULT '0' NOT NULL,
	name tinytext NOT NULL,
	prop_x tinytext NOT NULL,
	prop_y tinytext NOT NULL,
	prop_alpha tinytext NOT NULL,
	file blob NOT NULL,
	path tinytext NOT NULL,
	initobj text NOT NULL,
	
	PRIMARY KEY (uid),
	KEY parent (pid)
);


#
# Table structure for table 'tt_content'
#
CREATE TABLE tt_content (
	tx_typoflash_data blob NOT NULL
);

#
# Table structure for table 'tx_typoflash_content'
#
CREATE TABLE tx_typoflash_content (
    uid int(11) unsigned DEFAULT '0' NOT NULL auto_increment,
    pid int(11) unsigned DEFAULT '0' NOT NULL,
    tstamp int(11) unsigned DEFAULT '0' NOT NULL,
    crdate int(11) unsigned DEFAULT '0' NOT NULL,
    cruser_id int(11) unsigned DEFAULT '0' NOT NULL,
    sorting int(10) unsigned DEFAULT '0' NOT NULL,
    deleted tinyint(4) unsigned DEFAULT '0' NOT NULL,
    hidden tinyint(4) unsigned DEFAULT '0' NOT NULL,
    starttime int(11) unsigned DEFAULT '0' NOT NULL,
    endtime int(11) unsigned DEFAULT '0' NOT NULL,
    fe_group int(11) DEFAULT '0' NOT NULL,
    name tinytext NOT NULL,
    component int(11) unsigned DEFAULT '0' NOT NULL,
    target tinytext NOT NULL,
    records blob NOT NULL,
    storage_page blob NOT NULL,
    media blob NOT NULL,
    media_category blob NOT NULL,
    conf text NOT NULL,
    data blob NOT NULL,
    xml_conf blob NOT NULL,
    title tinytext NOT NULL,
    body_text text NOT NULL,
    sys_language_uid int(11) DEFAULT '0' NOT NULL,
    l18n_parent int(11) DEFAULT '0' NOT NULL,
    l18n_diffsource mediumblob NOT NULL,
	
    PRIMARY KEY (uid),
    KEY parent (pid)
);

#
# Table structure for table 'tt_content'
#
CREATE TABLE be_users (
	tx_typoflash_data blob NOT NULL,
	tx_typoflash_status int(11) unsigned DEFAULT '0' NOT NULL
);