This is the source for the DeadPotato web application which is used, to the
delight of some, for playing variants of the Diplomacy board game online with
others.

## Developer Setup

The steps below should, in theory, be all that's necessary but this process
hasn't been tested very thoroughly at this point so let me know or open an issue
if you have problems.

### Install
1. Clone the repo
2. Run npm install as usual
3. Add `~/.deadpotato\_s3.json` in your `$HOME` directory
	- This file contains the S3 credentials. If you're working with me, which
	  seems likely, then contact me and I can get you my config file so you can
	  use the test S3 bucket.
4. Add `~/.auth\_credentials.json` which should contain valid API credentials
   (client id and secret) for Google Open ID connect. Again, if you're working
   with me, which seems likely, then contact me and I can get you info for the
   test credentials.
5. If you intend to work on Gavel also then the easiest thing to do is probably
   to clone it to where you want to work on it and then [npm
   link](https://docs.npmjs.com/cli/link) the dependency. I've had problems
   where the generated npm link symlink is overwritten when npm updates packages
   so you may have to do this after updates also.
6. Install Mongo and point the application to it (server.coffee). The current
   setting for the `DB\_URI` is hard coded to `mongodb://localhost:27017/deadpotato`
   so if you intend on using something else then you'll have to change that
   (this should probably be extracted to a config file).
7. Run Gulp. The default task is for development and should do the correct
   things.

### Testing
You can't test much of anything until your database has been populated with one
or more game variants. Variants can be uploaded and if everything is configured
properly should just work. Variants are stored partially in your local
database and partially in the S3 test bucket that you configured earlier.

Once you make it to the actual war room (i.e. join a game that you created)
inputting orders in on the map is kind of funny and will probably be updated in
the near future. The current procedure is

1. Click on the unit that you want to issue a move order for
2. Click a destination to move it to
3. Ctrl+click other units to tell them to convoy the moving unit
4. Shift+click other units to tell them to support the moving unit

Here are some other things that might cause problems:

- Some packages have historically had dependencies on the "coffee-script"
  package which has only coffee script version 1 iterations available and this
  project needs coffee script 2 for various things (async functionality). In
  general this can be resolved by bugging the author and asking them to upgrade.
- There have been some inconsistencies in the way that binary data is URI
  encoded on different platforms (UploadVariantController.coffee).
