<?php
if ( function_exists( 'wfLoadExtension' ) ) {
	wfLoadExtension( 'ModDoc', __DIR__ . '/extension.json' );
	// Keep i18n globals so mergeMessageFileList.php doesn't break
	$wgMessagesDirs['ModDoc'] = __DIR__ . '/i18n';
	// $wgExtensionMessagesFiles['SpecMagic'] = __DIR__ . '/ModDoc.i18n.magic.php';
	wfWarn(
		'Deprecated PHP entry point used for ModDoc extension. Please use wfLoadExtension ' .
		'instead, see https://www.mediawiki.org/wiki/Extension_registration for more details.'
	);
	return true;
} else {
	die( 'This version of the ModDoc extension requires MediaWiki 1.25+' );
}
