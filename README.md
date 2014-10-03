# GeoFire for Titanium #

JavaScript library for realtime location queries using the [Firebase iOS Module for Titanium](https://github.com/LeftLaneLab/firebase-titanium).

## Dependencies ##

- [Firebase iOS Module for Titanium](https://github.com/LeftLaneLab/firebase-titanium)
- [RSVP.js](https://github.com/tildeio/rsvp.js)

## Compatibility ##

Tested with the following Titanium API versions

- Titanium 3.2.1
- Titanium 3.3.0
- Titanium 3.4.0

## Installation ##

- Install the [Firebase iOS Module for Titanium](https://github.com/LeftLaneLab/firebase-titanium)
- Save the [latest version](http://rsvpjs-builds.s3.amazonaws.com/rsvp-latest.js) of RSVP.js as `/app/lib/rsvp.js` in your project.
- Save the [latest version](https://github.com/LeftLaneLab/geofire-titanium/releases) of GeoFire-Titanium as `/app/lib/geofire-titanium.js` in your project.

## Documentation ##

This library is an unofficial port of the [GeoFire-js library](https://github.com/firebase/geofire-js). All functions available with the official library are also available on this library. All methods take the same arguments and return the same values where applicable.

## Using the Library ##

Below is a very simple example of using the GeoFire library to move a `key` around on a map and detect the changes relative to a `radius` with a `center` point.

```JavaScript
var Firebase = require('com.leftlanelab.firebase');
var GeoFire = require('geofire-titanium');

// Create a [GeoFire] Reference from your Firebase
var newRef = Firebase.new('https://l3-appcelerator-demo.firebaseio.com/geofire');
var geoRef = new GeoFire(newRef);

// Set a location for John
geoRef.set('John', [39.092765, -84.509733]).then(function ()
{
	console.log('John is Set');
},
function (err) {console.log('Something Went Wrong:', err);});

// Create a new [query] with a radius of 2km from a central point
var query = geoRef.query({
	'center' : [39.103090, -84.512308],
	'radius' : 2
});

// Attach a simple READY listener to the new [query]
var queryEventHandle = query.on('ready', function ()
{
	// ... do something with your UI Here

	// Cancel this listener
	queryEventHandle.cancel();
});

// Add a Listener
var queryEnterHandle = query.on('key_entered', function (key, location)
{
	// Update the UI
	lblMsg.text = key + ' Has Arrived';
	lblCoordinates.text = '(' + location[0] + ', ' + location[1] + ')';

	// Reveal the MOVE button
	btnInvite.hide();
	btnMove.show();
});

// Add a Listener
var queryMovedHandle = query.on('key_moved', function (key, location)
{
	// Update the UI
	lblMsg.text = key + ' Has Moved!';
	lblCoordinates.text = '(' + location[0] + ', ' + location[1] + ')';

	// Reveal the KICK button
	btnMove.hide();
	btnKick.show();
});

// Add a Listener
var queryExitedHandle = query.on('key_exited', function (key, location)
{
	// Update the UI
	lblMsg.text = key + ' Has Left The Party!';
	lblCoordinates.text = '(' + location[0] + ', ' + location[1] + ')';

	// Reveal the INVITE button
	btnKick.hide();
	btnInvite.show();
});

// Open a Window with a Label & Button
var winUsers = Ti.UI.createWindow({backgroundColor:'white', layout:'vertical'});
var lblMsg = Ti.UI.createLabel({top:'50%'});
var lblCoordinates = Ti.UI.createLabel();
var btnMove = Ti.UI.createButton({visible:false, title:'Move John'});
var btnKick = Ti.UI.createButton({visible:false, title:'Kick John'});
var btnInvite = Ti.UI.createButton({visible:false, title:'Invite John Back'});

btnMove.addEventListener('click', function ()
{
	// Move John a LITTLE
	geoRef.set('John', [39.092800, -84.509733]);
});

btnKick.addEventListener('click', function ()
{
	// Move John a LOT
	geoRef.set('John', [40.092800, -84.509733]);
});

btnInvite.addEventListener('click', function ()
{
	// Move John BACK
	geoRef.set('John', [39.092765, -84.509733]);
});

winUsers.add(lblMsg);
winUsers.add(lblCoordinates);
winUsers.add(btnMove);
winUsers.add(btnKick);
winUsers.add(btnInvite);

winUsers.open();
```

*Refer to the [GeoFire JavaScript Library from Firebase](https://github.com/firebase/geofire-js) for a full list of available methods and their uses.*