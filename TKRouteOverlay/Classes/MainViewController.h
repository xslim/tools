//
//  MainViewController.h
//  iMarshrutka
//
//  Created by Тарас Калапунь on 18.11.09.
//  Copyright 2009 Taras Kalapun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TKPoiAnnotation.h"
#import "TKRouteOverlayMapView.h"


@interface MainViewController : UIViewController 
    <CLLocationManagerDelegate>
{

    MKMapView *map;
    UILabel *infoLabel;
    
    NSMutableDictionary *mapAnnotations;
    TKRouteOverlayMapView *routeOverlayView;
    
    CLLocationManager *locationManager;
    
    NSUInteger currentRoute;
    NSMutableArray *mapRoutes;
    NSMutableArray *poiPoints;
    NSMutableArray *poiPointsLite;
    
}

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) NSMutableDictionary *mapAnnotations;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *mapRoutes;
@property (nonatomic, retain) NSMutableArray *poiPoints;
@property (nonatomic, retain) NSMutableArray *poiPointsLite;


//private
- (void)addRoute:(NSString *)trackPointsKeyName andPoints:(NSString *)pointsKeyName fromData:(NSDictionary *)routesData;
- (void)showRoute:(NSUInteger)routeId;


@end
