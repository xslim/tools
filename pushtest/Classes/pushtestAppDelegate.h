//
//  pushtestAppDelegate.h
//  pushtest
//
//  Created by Taras Kalapun on 10.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PushViewController;

@interface pushtestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PushViewController *pushViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PushViewController *pushViewController;

@end
