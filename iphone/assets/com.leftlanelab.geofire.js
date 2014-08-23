/**
 * @author vstross
 */
var RSVP = require('rsvp');

var _instances = {'GeoFire':0},
	_geofire = false,
	_forge = false;

/**
 * Public API Endpoint for getting a [GeoFire] reference or module proxy
 *
 ******************************************************************************/
exports.new = function (firebase)
{
	// Only execute on the first GeoFire...
	if (! _instances.GeoFire++)
	{
		// Set the global [firebase] handle
		_geofire = this;

		// Try to set the [forge] from App Properties
		_forge = Ti.App.Properties.getString('com.leftlanelab.geofire.forge', false);
	}

	// Return a new Firebase API Controller
	return new GeoFire(firebase);
};

/*
===============================================================================>
	GeoFire
===============================================================================>
*/
/*
 * GeoFire API Controller
 *
 ******************************************************************************/
function GeoFire (firebase)
{
	// Safety Net (Firebase Instance)
	if (! _.isUndefined(firebase) && _.isObject(firebase))
	{
		if (_.isUndefined(firebase.id) || firebase.id != 'com.leftlanelab.firebase' || _.isUndefined(firebase.version))
		{throw Error('com.leftlanelab.firebase v0.1.9 or higher is required');}

		// Set the [url]
		this._url = firebase.url;

		// Save the [Firebase] reference
		this._firebase = firebase;
	}

	// Safety Net (Firebase URL)
	else
	{
		// Safety Net
		if (! _forge && (_.isUndefined(firebase) || _.isEmpty(firebase))) {throw Error('Invalid Arguments');}

		// Set the [url] (allows for absolute &| empty [forge]), then strip trailing "/" for the sloppy types...
		this._url = (! _.isUndefined(firebase) && firebase.indexOf('https://') === 0 ? firebase : (_forge || '') + (firebase || '')).replace(/^https\:\/\/([\S]+[^\/])[\/]?/i, "https://$1");

		// Set the [Firebase] flag
		this._firebase = false;
	}

	// Global Variables
	this._listeners = {};

	// Return the new [GeoFire] pseudo-reference
	return this;
}

/*
 * Quick & Easy Class detection hack
 *
 ******************************************************************************/
GeoFire.prototype.id = 'com.leftlanelab.geofire';
GeoFire.prototype.version = '0.1.0';

/*
 * Returns the [Firebase] instance used to create this [GeoFire] instance.
 *
 ******************************************************************************/
GeoFire.prototype.ref = function ()
{
	return (this._firebase || this._url);
};

/*
 * Adds the specified [key]:[location] pair to Firebase
 *
 ******************************************************************************/
GeoFire.prototype.set = function (key, location)
{
	// Safety Net
	if (! _.isString(key) || ! _.isArray(location)) {throw Error('Invalid arguments');}

	// Validate [location] argument
	if (location.length !== 2) {throw Error('Invalid location argument');}
	if (! _.isNumber(location[0]) || ! _.isNumber(location[1])) {throw Error('Invalid location argument');}

	return new RSVP.Promise(_.bind(function (resolve, reject)
	{
		// Kick the [GeoFire]
		_geofire.setLocation(this._url, key, location, function (error)
		{
			if (error) {reject(error)}
			else {resolve()}
		});
	}, this));
};

/*
 * Fetches the location stored for [key]
 *
 ******************************************************************************/
GeoFire.prototype.get = function (key)
{
	// Safety Net
	if (! _.isString(key)) {throw Error('Invalid arguments');}

	return new RSVP.Promise(_.bind(function (resolve, reject)
	{
		// Kick the [GeoFire]
		_geofire.getLocation(this._url, key, function (location, error)
		{
			if (error) {reject(error)}
			else {resolve(location)}
		});

	}, this));
};

/*
 * Removes the provided [key]
 *
 ******************************************************************************/
GeoFire.prototype.remove = function (key)
{
	// Safety Net
	if (! _.isString(key)) {throw Error('Invalid arguments');}

	return new RSVP.Promise(_.bind(function (resolve, reject)
	{
		// Kick the [GeoFire]
		_geofire.removeLocation(this._url, key, function (error)
		{
			if (error) {reject(error)}
			else {resolve()}
		});

	}, this));
};
