/**
 * @author vstross
 */
var RSVP = require('rsvp'),
	_instances = {'GeoFire':0, 'GeoQuery':0},
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

/*
 * Creates & return a new [GeoQuery] instance with [queryCriteria]
 *
 ******************************************************************************/
GeoFire.prototype.query = function (queryCriteria)
{
	return new GeoQuery (this.url, queryCriteria);
};

/*
===============================================================================>
	GeoQuery
===============================================================================>
*/
/*
 * GeoQuery API Controller
 *
 * 	- expects to be created from an existing [GeoFire] instance
 ******************************************************************************/
function GeoQuery (url, queryCriteria)
{
	// Safety Net
	if (! _.isString(url) || ! _.isObject(queryCriteria)) {throw Error('Invalid GeoQuery');}

	// Global Variables
	this._url = url;
	this._listeners = {};
	this._query = queryCriteria;

	// Evaluate the [queryCriteria]
	if (! _.isArray(this._query['center']) || ! _.isNumber(this._query['radius'])) {throw Error('Invalid Arguments');}
	if (this._query.center.length != 2 || ! _.isNumber(this._query.center[0]) || ! _.isNumber(this._query.center[1])) {throw Error('Invalid value for CENTER');}

	// Register the new [instance]
	this._instance = _instances.GeoQuery++;

	// Return the new [FirebaseQuery] pseudo-reference
	return this;
}

/*
 * Returns the location signifying the center of this query
 *
 ******************************************************************************/
GeoQuery.prototype.center = function ()
{
	return this._query.center;
};

/*
 * Returns the radius of this query, in kilometers.
 *
 ******************************************************************************/
GeoQuery.prototype.radius = function ()
{
	return this._query.radius;
};

/*
 * Updates the criteria for this query.
 *
 ******************************************************************************/
GeoQuery.prototype.updateCriteria = function (queryCriteria)
{
	// Safety Net
	if (! _.isObject(queryCriteria) || (_.isUndefined(queryCriteria['center']) && _.isUndefined(queryCriteria['radius']))) {throw Error('Invalid Arguments');}

	// Evaluate the [queryCriteria].center
	if (! _.isUndefined(queryCriteria['center']))
	{
		if (! _.isArray(queryCriteria['center'])) {throw Error('Invalid CENTER Argument, expects Array');}
		if (queryCriteria.center.length != 2 || ! _.isNumber(queryCriteria.center[0]) || ! _.isNumber(queryCriteria.center[1])) {throw Error('Invalid value for CENTER');}

		// Overwrite the current [query].[center]
		this._query.center = queryCriteria.center;
	}

	// Evaluate the [queryCriteria].radius
	if (! _.isUndefined(queryCriteria['radius']))
	{
		if (! _.isNumber(queryCriteria['radius'])) {throw Error('Invalid RADIUS Argument, expects Number');}

		// Overwrite the current [query].[radius]
		this._query.radius = queryCriteria.radius;
	}

	// Only update the GeoQuery if there are listeners
	if (! _.isEmpty(this._listeners))
	{
		_geofire.updateQuery(this._instance, this._url, this._query.center, this._query.radius);
	}
};

/*
 * Updates the criteria for this query.
 *
 ******************************************************************************/
GeoQuery.prototype.on = function (eventType, callback)
{
	// Safety Net
	if (! _.isString(eventType)) {throw Error('GeoQuery.on: Invalid Arguments');}
	if (! _.isFunction(callback)) {throw Error('GeoQuery.on: Invalid Arguments');}

	// Initialize [listeners] collector for this [type]
	if (_.isUndefined(this._listeners[eventType])) {this._listeners[eventType] = [];}

	// Set the [listener], and save the [handle]
	this._listeners[eventType].push({
		'callback' : callback,
		'handle' : _geofire.queryOn(this._instance, eventType,

			function (key, location, distance)
			{
				if (_.isUndefined(key)) {callback()}
				else {callback(key, location, distance)}
			}
		)
	});

	// Return the [callback] for future de-referencing purposes
	return callback;
};
