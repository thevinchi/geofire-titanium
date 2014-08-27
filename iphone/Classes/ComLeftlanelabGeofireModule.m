/**
 * GeoFire
 *
 * Created by Left Lane Lab
 * Copyright (c) 2014 Your Company. All rights reserved.
 */

#import "ComLeftlanelabGeofireModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@interface ComLeftlanelabGeofireModule ()

@property NSMutableDictionary *gInstances;
@property NSDictionary *gEventTypes;
@property NSMutableDictionary *gListeners;

@end


@implementation ComLeftlanelabGeofireModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"6f677a17-3ffa-451f-9d05-ec349169e5b1";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.leftlanelab.geofire";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	// Initialize [gEventTypes]
	self.gEventTypes = [[NSDictionary alloc]

		initWithObjects:@[
			[NSNumber numberWithInteger:GFEventTypeKeyEntered],
			[NSNumber numberWithInteger:GFEventTypeKeyExited],
			[NSNumber numberWithInteger:GFEventTypeKeyMoved]
		]

		forKeys:@[
			@"key_entered",
			@"key_exited",
			@"key_moved"
		]
	];

	// Initialize [gInstances]
	self.gInstances = [NSMutableDictionary dictionary];

	// Initialize [gListeners]
	self.gListeners = [NSMutableDictionary dictionary];

	NSLog(@"[INFO] %@ loaded", self);
}

-(void)shutdown:(id)sender
{
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

/**
 * Set [instance]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (NSString) key
 *  - args[2] - (NSArray) location
 *  - args[3] - (KrollCallback) callback
 *
 */
- (void)setLocation: (id)args
{
    if (! [args count] == 4) {return;}
	
	// Initialize the [args]
	NSString *_url = ([args[0] isKindOfClass:[NSString class]] ? args[0] : nil);
	NSString *_key = ([args[1] isKindOfClass:[NSString class]] ? args[1] : nil);
	NSArray *_location = ([args[2] isKindOfClass:[NSArray class]] ? args[2] : nil);
	KrollCallback *_callback = ([args[3] isKindOfClass:[KrollCallback class]] ? args[3] : nil);

	// Argument Filter
	if (! _url || ! _key || ! _location || ! _callback) {return;}

	// Validate [location] array
	if (! [_location count] == 2
		|| ! [_location[0] isKindOfClass:[NSNumber class]]
		|| ! [_location[1] isKindOfClass:[NSNumber class]]
	) {return;}

	// Create a [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

	// Create the [coordinates] from [location]
	CLLocation * _coordinates = [[CLLocation alloc] initWithLatitude:[_location[0] doubleValue] longitude:[_location[1] doubleValue]];

	[_geo setLocation:_coordinates forKey:_key withCompletionBlock:^(NSError *error)
	{
		// Execute [callback]
		[_callback call:@[(error ? [error localizedDescription] : [NSNull alloc])] thisObject:nil];
	}];
}

/**
 * Fetches the location stored for [key]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (NSString) key
 *  - args[2] - (KrollCallback) callback
 *
 */
- (void)getLocation: (id)args
{
    if (! [args count] == 3) {return;}

	// Initialize the [args]
	NSString *_url = ([args[0] isKindOfClass:[NSString class]] ? args[0] : nil);
	NSString *_key = ([args[1] isKindOfClass:[NSString class]] ? args[1] : nil);
	KrollCallback *_callback = ([args[2] isKindOfClass:[KrollCallback class]] ? args[2] : nil);

	// Argument Filter
	if (! _url || ! _key || ! _callback) {return;}

	// Create a [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

	// Kick the Firebase
	[_geo getLocationForKey:_key withCallback:^(CLLocation *location, NSError *error)
	{
		// Execute [callback]
		[_callback call:@[(location ? @[[[NSNumber alloc] initWithDouble:location.coordinate.latitude], [[NSNumber alloc] initWithDouble:location.coordinate.longitude]] : [NSNull alloc]), (error ? [error localizedDescription] : [NSNull alloc])] thisObject:nil];
	}];
}

/**
 * Removes the provided [key]
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (NSString) key
 *  - args[2] - (KrollCallback) callback
 *
 */
- (void)removeLocation: (id)args
{
    if (! [args count] == 3) {return;}
	
	// Initialize the [args]
	NSString *_url = ([args[0] isKindOfClass:[NSString class]] ? args[0] : nil);
	NSString *_key = ([args[1] isKindOfClass:[NSString class]] ? args[1] : nil);
	KrollCallback *_callback = ([args[2] isKindOfClass:[KrollCallback class]] ? args[2] : nil);
	
	// Argument Filter
	if (! _url || ! _key || ! _callback) {return;}
	
	// Create a [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

	// Kick the Firebase
	[_geo removeKey:_key withCompletionBlock:^(NSError *error)
	{
		// Execute [callback] callback
		[_callback call:@[(error ? [error localizedDescription] : [NSNull alloc])] thisObject:nil];
	}];
}

/**
 * Create a listener for an [instance] of GF[Circle|Region]Query
 *
 *	- args[0] - (NSNumber) the GFQuery [instance] identifier
 *	- args[1] - (NSString) the URL for Firebase Reference
 *	- args[2] - (NSDictionary) the Query Criteria
 *	- args[3] - (NSString) Event Type to listen for
 *  - args[4] - (KrollCallback) callback
 *
 */
-(id)queryOn: (id)args
{
    if (! [args count] == 5) {return;}

	// Initialize the [args]
	NSNumber *_id = ([args[0] isKindOfClass:[NSNumber class]] ? args[0] : nil);
	NSString *_url = ([args[1] isKindOfClass:[NSString class]] ? args[1] : nil);
	NSDictionary *_criteria = ([args[2] isKindOfClass:[NSDictionary class]] ? args[2] : nil);
	NSString *_type = ([args[3] isKindOfClass:[NSString class]] ? args[3] : nil);
	KrollCallback *_callback = ([args[4] isKindOfClass:[KrollCallback class]] ? args[4] : nil);
	
	// Argument Filter
	if (! _id || ! _url || !_criteria || ! _type || ! _callback) {return;}

	// Validate [type]
	if (! [_type isEqual:@"ready"] && ! self.gEventTypes[_type]) {return;}

	// Initialize an [instance] for [id] @ [url] (only done once p/[id])
	if (! self.gInstances[_id])
	{
		// Validate [criteria] (Simple)
		if (! _criteria[@"center"] || ! _criteria[@"radius"]) {return;}

		// Validate [criteria].[center]
		if (! [_criteria[@"center"] isKindOfClass:[NSArray class]]
			|| ! [_criteria[@"center"] count] == 2
			|| ! [_criteria[@"center"][0] isKindOfClass:[NSNumber class]]
			|| ! [_criteria[@"center"][1] isKindOfClass:[NSNumber class]]
		) {return;}

		// Validate [criteria].[radius]
		if (! [_criteria[@"radius"] isKindOfClass:[NSNumber class]]) {return;}

		// Create a [geo] Instance
		GeoFire *_geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

		// Create the [coordinates] from [criteria]
		CLLocation *_coordinates = [[CLLocation alloc] initWithLatitude:[_criteria[@"center"][0] doubleValue] longitude:[_criteria[@"center"][1] doubleValue]];

		// Set the GFQuery [instance] for [id]
		[self.gInstances setObject:[_geo queryAtLocation:_coordinates withRadius:[_criteria[@"radius"] doubleValue]] forKey:_id];
	}

	// Extract the [query]
	GFCircleQuery *_query = self.gInstances[_id];

	// Initialize the [handle]
	FirebaseHandle *_handle;

	// Add an observer for READY events
	if ([_type isEqual:@"ready"])
	{
		_handle = [_query observeReadyWithBlock:^
		{
			// Execute [callback]
			[_callback call:nil thisObject:nil];
		}];
	}

	// Add observer for ALL OTHER events
	else
	{
		_handle = [_query observeEventType:[self.gEventTypes[_type] intValue] withBlock:^(NSString *key, CLLocation *location)
		{
			// Execute [callback]
			[_callback call:@[key, @[[[NSNumber alloc] initWithDouble:location.coordinate.latitude], [[NSNumber alloc] initWithDouble:location.coordinate.longitude]]] thisObject:nil];
		}];
	}

	// Return the [handle] for future reference
	return [NSNumber numberWithInteger:_handle];
}

/**
 * Remove a listener from an [instance] of GF[Circle|Region]Query
 *
 *	- args[0] - (NSNumber) the GFQuery [instance] identifier
 *	- args[1] - (NSNumber) the [handle] for the observer to remove
 *
 */
-(void)queryOff: (id)args
{
    if (! [args count] == 2) {return;}

	// Initialize the [args]
	NSNumber *_id = ([args[0] isKindOfClass:[NSNumber class]] ? args[0] : nil);
	NSNumber *_handle = ([args[1] isKindOfClass:[NSNumber class]] ? args[1] : nil);

	// Argument Filter
	if (! _id || ! _handle) {return;}

	// Validate [instance] exists for [id]
	if (! self.gInstances[_id]) {return;}

	// Remove the observer by [handle]
	[self.gInstances[_id] removeObserverWithHandle:[_handle integerValue]];
}

/**
 * Updates the criteria for a query.
 *
 *	- args[0] - (NSNumber) the GFQuery [instance] identifier
 *	- args[1] - (NSDictionary) the Query Criteria
 */
- (void)queryUpdate: (id)args
{
    if (! [args count] == 2) {return;}
	
	// Initialize the [args]
	NSNumber *_id = ([args[0] isKindOfClass:[NSNumber class]] ? args[0] : nil);
	NSDictionary *_criteria = ([args[1] isKindOfClass:[NSDictionary class]] ? args[1] : nil);
	
	// Argument Filter
	if (! _id || ! _criteria) {return;}
	
	// Validate [instance] exists for [id]
	if (! self.gInstances[_id]) {return;}
	
	// Validate [criteria] (Simple)
	if (! _criteria[@"center"] || ! _criteria[@"radius"]) {return;}
	
	// Validate [criteria].[center]
	if (! [_criteria[@"center"] isKindOfClass:[NSArray class]]
		|| ! [_criteria[@"center"] count] == 2
		|| ! [_criteria[@"center"][0] isKindOfClass:[NSNumber class]]
		|| ! [_criteria[@"center"][1] isKindOfClass:[NSNumber class]]
		) {return;}
	
	// Validate [criteria].[radius]
	if (! [_criteria[@"radius"] isKindOfClass:[NSNumber class]]) {return;}
	
	// Extract the [query]
	GFCircleQuery * _query = self.gInstances[_id];
	
	// Update the [center] && [radius]
	_query.center = [[CLLocation alloc] initWithLatitude:[_criteria[@"center"][0] doubleValue] longitude:[_criteria[@"center"][1] doubleValue]];
	_query.radius = [_criteria[@"radius"] doubleValue];
}

/**
 * Cancel all Observers && destroy the [instance]
 *
 *	- args[0] - (NSNumber) the GFQuery [instance] identifier
 */
- (void)queryCancel: (id)args
{
    if (! [args count]) {return;}

	// Initialize the [args]
	NSNumber *_id = ([args[0] isKindOfClass:[NSNumber class]] ? args[0] : nil);
	
	// Argument Filter
	if (! _id) {return;}

	// Validate [instance] exists for [id]
	if (! self.gInstances[_id]) {return;}

	// Remove all Observers from [instance] for [id]
	[self.gInstances[_id] removeAllObservers];

	// Remove [instance]
	[self.gInstances removeObjectForKey:_id];
}

@end
