//
//  UICRouteOverlayMapView.h
//  MapDirections
//
//  Created by KISHIKAWA Katsumi on 09/08/10.
//  Copyright 2009 KISHIKAWA Katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TKRouteOverlayMapView : UIView {
	MKMapView *inMapView;
	NSMutableArray *routes;
    NSMutableArray *colors;
}

- (id)initWithMapView:(MKMapView *)mapView;

@property (nonatomic, retain) MKMapView *inMapView;
@property (nonatomic, retain) NSMutableArray *routes;
@property (nonatomic, retain) NSMutableArray *colors;

- (void)addRoute:(NSArray *)routePoints;
- (void)addRoute:(NSArray *)routePoints withColor:(UIColor *)lineColor;
- (void)clearRoutes;
- (void)display;

@end
