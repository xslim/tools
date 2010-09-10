//
//  MainViewController.m
//  iMarshrutka
//
//  Created by Тарас Калапунь on 18.11.09.
//  Copyright 2009 Taras Kalapun. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"



@implementation MainViewController


@synthesize map, mapAnnotations;
@synthesize locationManager;
@synthesize mapRoutes, poiPoints, poiPointsLite;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    routeOverlayView = [[TKRouteOverlayMapView alloc] initWithMapView:map];
    
    [map sizeToFit];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"path" ofType:@"plist"];
    NSDictionary *route = [NSDictionary dictionaryWithContentsOfFile:path];
    
    
    if (route) {
        [self addRoute:@"route" andPoints:@"points" fromData:route];
        [self showRoute:0];
    }
}


/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UIDeviceOrientationIsLandscape(interfaceOrientation) || interfaceOrientation == UIDeviceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
    self.map = nil;
}


- (void)dealloc {
    [map release];
    [locationManager release];
    [mapRoutes release];
    [poiPoints release];
    [poiPointsLite release];
    [super dealloc];
}

#pragma mark -
#pragma mark Custom methods




- (IBAction)rotateRoutes
{
    if ([mapRoutes count] > 0) {
        NSUInteger newRoute = currentRoute + 1;
        if ( newRoute > ([mapRoutes count] - 1) ) newRoute = 0;
        [self showRoute:newRoute];
    }
}

- (void)showRoute:(NSUInteger)routeId
{

    NSDictionary *route = [mapRoutes objectAtIndex:routeId];
    if ([[route objectForKey:@"track"]  count] > 0) 
        [routeOverlayView addRoute:[route objectForKey:@"track"]];
    if ([[route objectForKey:@"points"] count] > 0) 
        [map addAnnotations:[route objectForKey:@"points"]];
    
    currentRoute = routeId;
    
    [routeOverlayView display];
}

- (void)addRoute:(NSString *)trackPointsKeyName andPoints:(NSString *)pointsKeyName fromData:(NSDictionary *)routesData
{
    NSMutableArray *trackPoints  = [[NSMutableArray array] retain];
    NSMutableArray *stopPoints   = [[NSMutableArray array] retain];
    
    for (NSArray *values in [routesData objectForKey:trackPointsKeyName]) {
        CLLocationDegrees latitude  = [[values objectAtIndex:0] doubleValue];
        CLLocationDegrees longitude = [[values objectAtIndex:1] doubleValue];
        CLLocation* currentLocation = [[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease];
        
        [trackPoints addObject:currentLocation];
    }
    
    for (NSArray *values in [routesData objectForKey:pointsKeyName]) {
        CLLocationCoordinate2D point;
        point.latitude  = [[values objectAtIndex:0] doubleValue];
        point.longitude = [[values objectAtIndex:1] doubleValue];
        
        TKPoiAnnotation *currentAnnotation = [[[TKPoiAnnotation alloc] initWithCoordinate:point] autorelease];
        
        currentAnnotation.title = [values objectAtIndex:2];
        currentAnnotation.pinColor = MKPinAnnotationColorPurple;
        
        //currentAnnotation.subtitle = [values objectAtIndex:2];
        [stopPoints addObject:currentAnnotation];
    }
    
    if (self.mapRoutes == nil) {
        NSMutableArray *var = [[NSMutableArray alloc] init];
        self.mapRoutes = var;
        [var release], var = nil;
    }
    
    
    [mapRoutes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          trackPoints, @"track",
                          stopPoints, @"points",
                          nil]];
    
    [trackPoints release];
    [stopPoints release];
}



#pragma mark -
#pragma mark MKMap Delegates

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
	routeOverlayView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	routeOverlayView.hidden = NO;
	[routeOverlayView setNeedsDisplay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *pinIdentifier = @"RoutePinAnnotation";
	    
	if ([annotation isKindOfClass:[TKPoiAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
		if(!pinAnnotation) {
			pinAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier] autorelease];
		}
        TKPoiAnnotation *poiAnnotation = (TKPoiAnnotation *)annotation;
		
		if (poiAnnotation.pinColor) {
			pinAnnotation.pinColor = poiAnnotation.pinColor;
		}
		
		pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
        
        if (poiAnnotation.buttonTag > 0) {
            UIButton *disclosureButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
            disclosureButton.tag = poiAnnotation.buttonTag;
            pinAnnotation.rightCalloutAccessoryView = disclosureButton;
        }
        
		return pinAnnotation;
	}
    
    MKAnnotationView* annotationView = nil;
    return annotationView; //TODO: create correct ann
}





@end
