# ModDoc

<!-- ![stability-experimental](https://img.shields.io/badge/stability-experimental-orange.svg?style=for-the-badge) -->
![GitHub issues](https://img.shields.io/github/issues-raw/jeblad/ModDoc?style=for-the-badge)

 ***NOTE***: *This is only in the preparation. The goal is to reimplement [Module:Luadoc](https://en.wikipedia.org/wiki/Module:LuaDoc) and generalize it for more languages than just Lua.*

This [extension for Mediawiki](https://www.mediawiki.org/wiki/Extension:ModDoc) add formalized documentation to modules provided by the [Scribunto extension](https://www.mediawiki.org/wiki/Extension:Scribunto). This makes it possible to verify existence of sufficient documentation, to facilitate easy reuse in a collaborative environment.

## Usage

ModDoc depends on the Scribunto extension, and provide formatted documentation for Lua code.

1. Download from [Github](https://github.com/jeblad/ModDoc) ([zip](https://github.com/jeblad/ModDoc/archive/master.zip)) and place the file(s) in a directory called ModDoc in your extensions/ folder.
2. Add the following code at the bottom of your LocalSettings.php:

	```lua
	wfLoadExtension( 'ModDoc' );
	```

3. Done – Navigate to Special:Version on your wiki to verify that the extension is successfully installed.

## Development

ModDoc uses [Mediawiki-Vagrant](https://www.mediawiki.org/wiki/MediaWiki-Vagrant), and an instance can be made quite easily. A more complete setup can be found at the page [vagrant](../../wiki/vagrant).

1. Make sure you have Vagrant, etc, prepare a development directory, and move to that directory.
2. Clone Mediawiki

	```bash
	git clone --recursive https://gerrit.wikimedia.org/r/mediawiki/vagrant .
	```

3. Add the role unless [#?](https://gerrit.wikimedia.org/r/#/c/mediawiki/vagrant/+/?/) has been merged. (You need [git-review](https://www.mediawiki.org/wiki/Gerrit/git-review) to do this.)

	```bash
	git review -d ?
	```

4. Run setup.

	```bash
	./setup.sh
	```

5. Enable role for ModDoc. This pulls in the role for Scribunto, which then pulls in additional roles.

	```bash
	vagrant roles enable moddoc
	```

6. Start the instance.

	```bash
	vagrant up
	```

7. Done.
