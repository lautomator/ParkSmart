//
//  DirectionsViewController.m
//  ParkSmart
//
//  Created by Rao, Amit on 12/5/14.
//  Copyright (c) 2014 Rao, Amit. All rights reserved.
//

@import MapKit;
@import CoreLocation;
#import "DirectionsViewController.h"
#import "ImageLocationManager.h"

typedef void(^addressCompletion)(NSString *);

@interface DirectionsViewController () <MKMapViewDelegate>

@property (nonatomic, strong) CLLocation *fromLocation;    //current location
@property (nonatomic, strong) CLLocation *toLocation;      //parked location
@property (nonatomic, strong) IBOutlet MKMapView *mapView; //mapView
@property (nonatomic, strong) IBOutlet UILabel *walkingDistance;
@property (nonatomic, strong) IBOutlet UILabel *walkingTime;


@end

@implementation DirectionsViewController

- (ImageLocationManager *)_imageLocationManager
{
    return [ImageLocationManager sharedInstance];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Directions";


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self renderWalkingDirectionsToParkingSpot];
    [self zoomToCurrentLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-  (void)zoomToCurrentLocation
{
    float spanX = 0.01;
    float spanY = 0.01;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}

- (void)renderWalkingDirectionsToParkingSpot
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];

    CLLocationDegrees parkingSpotLatitude = self._imageLocationManager.parkingLocation.coordinate.latitude;
    CLLocationDegrees parkingSpotLongitude = self._imageLocationManager.parkingLocation.coordinate.longitude;

    MKPlacemark *destinationPlaceMark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(parkingSpotLatitude, parkingSpotLongitude)
                                                              addressDictionary:@{@"destination": @"parking spot"}];

    MKMapItem *sourceMapItem = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlaceMark];
    [request setSource:sourceMapItem];
    [request setDestination:destinationMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            for (MKRoute *route in [response routes]) {
                [self.mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
                // You can also get turn-by-turn steps, distance, advisory notices, ETA, etc by accessing various route properties.

                for (MKRouteStep *step in route.steps)
                {
                    NSLog(@"%@", step.instructions);
                }
                NSLog(@"walking distance = %f meters", route.distance);
                NSLog(@"Expected walking time = %f mins", route.expectedTravelTime/60.0);
                self.walkingDistance.text  = [NSString stringWithFormat:@"walking distance %f", route.distance];
                self.walkingTime.text = [NSString stringWithFormat:@"walking time %f", route.expectedTravelTime/60.0];
                [self.walkingTime sizeToFit];
                [self.walkingDistance sizeToFit];

            }
        }
    }];

    //now create the annotation...

    MKPointAnnotation *destinationPin = [[MKPointAnnotation alloc] init];

    destinationPin.coordinate = CLLocationCoordinate2DMake(parkingSpotLatitude, parkingSpotLongitude);

    CLLocation* parkingLocation = self._imageLocationManager.parkingLocation;

    [self getAddressFromLocation:parkingLocation completionBlock:^(NSString * address) {
        if(address) {
            destinationPin.title = address;
            //TBD: make sure address is not truncated
        }
    }];

    [self.mapView addAnnotation:destinationPin];

}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // this part is boilerplate code used to create or reuse a pin annotation
    MKAnnotationView *annotationView = nil;
    static NSString *viewId = @"MKPinAnnotationView";

    if(annotation != mapView.userLocation)
    {
        annotationView = (MKPinAnnotationView*)
        [self.mapView dequeueReusableAnnotationViewWithIdentifier:viewId];

        if(annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:viewId];
        }

        // set your custom image
        annotationView.image = [UIImage imageNamed:@"car-park"];
        annotationView.canShowCallout = YES;

    }

    return annotationView;
}

-(void)getAddressFromLocation:(CLLocation *)location completionBlock:(addressCompletion)completionBlock
{
    __block CLPlacemark* placemark;
    __block NSString *address = nil;

    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             address = [NSString stringWithFormat:@"%@, %@ %@", placemark.name, placemark.postalCode, placemark.locality];
             completionBlock(address);
         }
     }];
}

- (IBAction)walkingDirectionsInMapsApp:(id)sender
{
    CLLocationDegrees parkingSpotLatitude = self._imageLocationManager.parkingLocation.coordinate.latitude;
    CLLocationDegrees parkingSpotLongitude = self._imageLocationManager.parkingLocation.coordinate.longitude;

    MKPlacemark *destinationPlaceMark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(parkingSpotLatitude, parkingSpotLongitude)
                                                              addressDictionary:@{@"destination": @"parking spot"}];

    MKMapItem* destMapItem = [[MKMapItem alloc] initWithPlacemark:destinationPlaceMark];
    destMapItem.name = @"parking spot";

    NSArray* mapItems = [[NSArray alloc] initWithObjects:destMapItem, nil];

    NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeWalking,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems:mapItems launchOptions:options];


}

@end
