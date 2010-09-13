//
//  pushtestAppDelegate.m
//  pushtest
//
//  Created by Taras Kalapun on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "pushtestAppDelegate.h"
#import "PushViewController.h"

@implementation pushtestAppDelegate


@synthesize window, pushViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    
    NSDictionary *pushDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (pushDictionary != nil) {
        NSLog(@"pushDictionary : %@", pushDictionary);
		//[self handlePushMessage:pushDictionary];
	}
    
    // Override point for customization after application launch.
    [window addSubview:pushViewController.view];
    [window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

    // Save data if appropriate.
}

- (void)dealloc {

    [pushViewController release];
    [window release];
    [super dealloc];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    const unsigned *tokenData = deviceToken.bytes;
    NSString *deviceTokenString = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", 
                        ntohl(tokenData[0]), ntohl(tokenData[1]), ntohl(tokenData[2]), ntohl(tokenData[3]), 
                        ntohl(tokenData[4]), ntohl(tokenData[5]), ntohl(tokenData[6]), ntohl(tokenData[7])];
    

    
    
    
	NSLog(@"deviceToken: %@", deviceTokenString);
    self.pushViewController.deviceTokenField.text = deviceTokenString;
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] != 3010) {
        NSLog(@"Failed to register, error: %@", error);
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
     NSLog(@"Received notification: %@", userInfo);

}

@end
