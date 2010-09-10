//
//  iMarshrutkaAppDelegate.h
//  iMarshrutka
//
//  Copyright Taras Kalapun 2009. All rights reserved.
//



#import <UIKit/UIKit.h>

#import "MainViewController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    MainViewController *mainViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end

