//
//  LocationManager.m
//  ParkSmart
//
//  Created by Rao, Amit on 5/4/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

@import CoreLocation;
@import ImageIO;
#import "LocationManager.h"

@implementation LocationManager



+ (void)processImageEXIFData:(NSData *)imageData
{
    CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    if (mySourceRef != NULL)
    {
        NSDictionary *myMetadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
        NSDictionary *gpsDictionary = [myMetadata objectForKey:kCGImagePropertyGPSDictionary];

        
        NSLog(@"Parking spot latitude = %@", [gpsDictionary objectForKey:@"Latitude"]);
        NSLog(@"Parking spot longitude = %@", [gpsDictionary objectForKey:@"Longitude"]);
    }

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [locationManager startUpdatingLocation];

    CLLocationDegrees currentLatitude = locationManager.location.coordinate.latitude;
    CLLocationDegrees currentLongitude = locationManager.location.coordinate.longitude;

}

@end
