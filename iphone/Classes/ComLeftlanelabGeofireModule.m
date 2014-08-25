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
@property NSArray *gEventTypes;
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
	self.gEventTypes = @[@"child_added", @"child_removed", @"child_changed", @"child_moved", @"value"];
	
	// Initialize [gInstances]
	self.gInstances = [NSMutableDictionary dictionary];
	
	// Initialize [gListeners]
	self.gListeners = [NSMutableDictionary dictionary];
	
	NSLog(@"[INFO] %@ loaded", self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup


#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
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

	// Create the [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

	// Create teh [coordinates]
	CLLocation * _coordinates = [[CLLocation alloc] initWithLatitude:[_location[0] doubleValue] longitude:[_location[1] doubleValue]];

	[_geo setLocation:_coordinates forKey:_key withCompletionBlock:^(NSError *error)
	{
		// Execute [callback] callback
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

	// Create the [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

	// Kick the Firebase
	[_geo getLocationForKey:_key withCallback:^(CLLocation *location, NSError *error)
	{
		// Execute [callback] callback
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
	
	// Create the [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];

	// Kick the Firebase
	[_geo removeKey:_key withCompletionBlock:^(NSError *error)
	{
		// Execute [callback] callback
		[_callback call:@[(error ? [error localizedDescription] : [NSNull alloc])] thisObject:nil];
	}];
}

/**
 * Updates the criteria for a query.
 *
 *	- args[0] - (NSString) the URL for Firebase Reference
 *	- args[1] - (NSString) key
 *  - args[2] - (KrollCallback) callback
 *
- (void)updateQuery: (id)args
{
    if (! [args count] == 3) {return;}
	
	// Initialize the [args]
	NSString *_url = ([args[0] isKindOfClass:[NSString class]] ? args[0] : nil);
	NSString *_key = ([args[1] isKindOfClass:[NSString class]] ? args[1] : nil);
	KrollCallback *_callback = ([args[2] isKindOfClass:[KrollCallback class]] ? args[2] : nil);
	
	// Argument Filter
	if (! _url || ! _key || ! _callback) {return;}
	
	// Create the [geo] Instance
	GeoFire * _geo = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:_url]];
	
	// Kick the Firebase
	[_geo removeKey:_key withCompletionBlock:^(NSError *error)
	 {
		 // Execute [callback] callback
		 [_callback call:@[(error ? [error localizedDescription] : [NSNull alloc])] thisObject:nil];
	 }];
}
*/



@end
