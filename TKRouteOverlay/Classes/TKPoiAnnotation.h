//
//  POI.h
//  iMarshrutka
//
//  Created by Тарас Калапунь on 02.11.09.
//  Copyright 2009 Укртелеком. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TKPoiAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *subtitle; 
    NSString *title;
    NSUInteger pinColor;
    NSInteger buttonTag;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) NSUInteger pinColor;
@property (nonatomic) NSInteger buttonTag;

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
