//
//  POI.m
//  iMarshrutka
//
//  Created by Тарас Калапунь on 02.11.09.
//  Copyright 2009 Укртелеком. All rights reserved.
//

#import "TKPoiAnnotation.h"


@implementation TKPoiAnnotation

@synthesize coordinate, title, subtitle, pinColor, buttonTag;

- (id) initWithCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self = [super init];
    if (self != nil) {
        self.coordinate = newCoordinate; 
    }
    return self;
}

- (void) dealloc
{
    [title release];
    [subtitle release];
    [super dealloc];
}
@end