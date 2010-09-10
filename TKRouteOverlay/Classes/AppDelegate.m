//
//  iMarshrutkaAppDelegate.m
//  iMarshrutka
//
//  Created by Тарас Калапунь on 18.11.09.
//  Copyright Taras Kalapun 2009. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	[window addSubview:mainViewController.view];
    [window makeKeyAndVisible];
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [mainViewController release];
	[window release];
	[super dealloc];
}




@end

