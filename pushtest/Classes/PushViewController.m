//
//  PushViewController.m
//  pushtest
//
//  Created by Taras Kalapun on 13.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PushViewController.h"


@implementation PushViewController

@synthesize deviceTokenField, appIdField;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.deviceTokenField = nil;
    self.appIdField = nil;
}


- (void)dealloc {
    
    [deviceTokenField release];
    [appIdField release];
    [super dealloc];
}


- (IBAction)signUp
{
    if ([self.deviceTokenField.text isEqualToString:@""] ||
        [self.appIdField.text isEqualToString:@""])
        return;
    
    
    NSString *host = @"http://kalapun.com/apns/signup.php";
    NSString *url = [NSString stringWithFormat:@"%@?appId=%@&deviceToken=%@", 
                     host, self.appIdField.text, self.deviceTokenField.text];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"requesting: %@", request);
    
    NSError *error = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:NULL error:&error];
    
    if (error) {
        NSLog(@"error signing-up: %@", [error localizedDescription]);
    }
    
}

@end
