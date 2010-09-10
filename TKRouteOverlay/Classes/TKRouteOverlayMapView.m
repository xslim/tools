//
//  UICRouteOverlayMapView.m
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import "TKRouteOverlayMapView.h"

@implementation TKRouteOverlayMapView

@synthesize inMapView;
@synthesize routes, colors;

- (id)initWithMapView:(MKMapView *)mapView {
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, mapView.frame.size.width, mapView.frame.size.height)];
	if (self != nil) {
		self.inMapView = mapView;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		[self.inMapView addSubview:self];
	}
	
	return self;
}

- (void)dealloc {
	[inMapView release];
	[routes release];
    [colors release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect { 
	if(!self.hidden && self.routes != nil && self.routes.count > 0) {
		
		//for (NSArray *route in self.routes) {
        NSArray *route;
        
        for(int k = 0; k < self.routes.count; k++) {
            
            route = [self.routes objectAtIndex:k];
            
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            
            CGContextSetStrokeColorWithColor(context, [[colors objectAtIndex:k] CGColor]);
            CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 1.0f);
            
            CGContextSetLineWidth(context, 4.0f);
            
            for(int i = 0; i < route.count; i++) {
                CLLocation* location = [route objectAtIndex:i];
                CGPoint point = [inMapView convertCoordinate:location.coordinate toPointToView:self];
                
                if(i == 0) {
                    CGContextMoveToPoint(context, point.x, point.y);
                } else {
                    CGContextAddLineToPoint(context, point.x, point.y);
                }
            }
            
            CGContextStrokePath(context);
            
		}
        
		
	}
}

- (void)addRoute:(NSArray *)routePoints {
    [self addRoute:routePoints withColor:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:0.5f]];
}

- (void)addRoute:(NSArray *)routePoints withColor:(UIColor *)lineColor {
    
    //self.routes = [NSMutableArray arrayWithCapacity:1];

    if (self.routes == nil) {
        //NSMutableArray *var = [[NSMutableArray alloc] init];
        //self.routes = var;
        //[var release], var = nil;
        self.routes = [[NSMutableArray alloc] init];
    }
    
    if (self.colors == nil) {
        NSMutableArray *var = [[NSMutableArray alloc] init];
        self.colors = var;
        [var release], var = nil;
    }
    
    [routes addObject:routePoints];
    [colors addObject:lineColor];
}

- (void)clearRoutes {
    if (self.routes != nil) {
        [routes release], self.routes = nil;
    }
    
    if (self.colors != nil) {
        [colors release], self.colors = nil;
    }
    [self setNeedsDisplay];
}

- (void)display {
    CLLocationDegrees maxLat = -90.0f;
    CLLocationDegrees maxLon = -180.0f;
    CLLocationDegrees minLat = 90.0f;
    CLLocationDegrees minLon = 180.0f;
    
    for (NSArray *route in self.routes) {
        //NSArray *route = [routes objectAtIndex:0];
        for (int i = 0; i < route.count; i++) {
            CLLocation *currentLocation = [route objectAtIndex:i];
            if(currentLocation.coordinate.latitude > maxLat) {
                maxLat = currentLocation.coordinate.latitude;
            }
            if(currentLocation.coordinate.latitude < minLat) {
                minLat = currentLocation.coordinate.latitude;
            }
            if(currentLocation.coordinate.longitude > maxLon) {
                maxLon = currentLocation.coordinate.longitude;
            }
            if(currentLocation.coordinate.longitude < minLon) {
                minLon = currentLocation.coordinate.longitude;
            }
        }
    }
    
    
    MKCoordinateRegion region;
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat;
    region.span.longitudeDelta = maxLon - minLon;
    
    [self.inMapView setRegion:region animated:YES];
    
    [self setNeedsDisplay];
}

@end
