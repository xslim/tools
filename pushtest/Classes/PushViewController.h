//
//  PushViewController.h
//  pushtest
//
//  Created by Taras Kalapun on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PushViewController : UIViewController {
    UITextField *deviceTokenField;
    UITextField *appIdField;
}

@property (nonatomic, retain) IBOutlet UITextField *deviceTokenField;
@property (nonatomic, retain) IBOutlet UITextField *appIdField;

- (IBAction)signUp;

@end
