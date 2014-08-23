/**
 * @author vstross
 */
var RSVP = require('rsvp');

var _instances = {'GeoFire':0},
	_geofire = false;

/**
 * Public API Endpoint for getting a [GeoFire] reference or module proxy
 *
 ******************************************************************************/
exports.new = function (url)
{
	// Only execute on the first GeoFire...
	if (! _instances.GeoFire++)
	{
		// Set the global [firebase] handle
		_geofire = this;
	}

	// Return a new Firebase API Controller
	return new GeoFire(url);
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
	// Safety Net
	if (_.isUndefined(firebase)) {throw Error('Firebase reference required as first argument');}

	// Safety Net
	if (_.isUndefined(firebase.id) || firebase.id != 'com.leftlanelab.firebase' || _.isUndefined(firebase.version))
	{throw Error('com.leftlanelab.firebase v0.1.9 or higher is required');}

	// Global Variables
	this._listeners = {};
	this._firebase = firebase;

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
		_geofire.set(this._firebase.url, key, location, function (error)
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
		_geofire.getLocation(this._firebase.url, key, function (location, error)
		{
			if (error) {reject(error)}
			else {resolve(location)}
		});

	}, this));
};
