/*
Copyright (c) 2003-2009, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config )
{
	// Define changes to default configuration here. For example:
	config.language = 'en';
	config.uiColor = '#e6e6e6';
	config.toolbar = 'BlankToolbar';
	config.height = '400';
	config.width = '608';
	
	
	config.toolbar_BlankToolbar =
	[
	  	['Source','Undo','Redo','-','Bold','Italic','NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
		['Link','Unlink','Anchor','Image','Flash','Table','SpecialChar'],
		['Styles','Format','Font','FontSize','TextColor','BGColor','Maximize','ShowBlocks' ]
	];
	
	config.filebrowserBrowseUrl = '/admin/content_for_popup/all';
	config.filebrowserImageBrowseUrl = '/admin/content_for_popup/images';
	
	config.filebrowserWindowWidth = '640';
    config.filebrowserWindowHeight = '480';

	config.filebrowserUploadUrl = '/admin/fckuploads';
	config.LinkUploadAllowedExtensions	= ".(7z|aiff|asf|avi|bmp|csv|doc|fla|flv|gif|gz|gzip|jpeg|jpg|mid|mov|mp3|mp4|mpc|mpeg|mpg|ods|odt|pdf|png|ppt|pxd|qt|ram|rar|rm|rmi|rmvb|rtf|sdc|sitd|swf|sxc|sxw|tar|tgz|tif|tiff|txt|vsd|wav|wma|wmv|xls|xml|zip)$" ;			// empty for all

};
