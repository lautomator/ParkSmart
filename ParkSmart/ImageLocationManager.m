//
//  LocationManager.m
//  ParkSmart
//
//  Created by Rao, Amit on 5/4/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

@import CoreLocation;
@import ImageIO;
#import "ImageLocationManager.h"

@interface ImageLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation ImageLocationManager

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });

    return _sharedInstance;
}



//FOR CAMERA IMAGE
- (NSMutableData *)getImageWithMetaData:(UIImage *)pImage
{
    NSData* pngData =  UIImagePNGRepresentation(pImage);

    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
    NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));

    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];

    //For GPS Dictionary
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if(!GPSDictionary)
        GPSDictionary = [NSMutableDictionary dictionary];


   self.locationManager = [[CLLocationManager alloc] init];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }

    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [self.locationManager startUpdatingLocation];

    CLLocationDegrees currentLatitude = self.locationManager.location.coordinate.latitude;
    CLLocationDegrees currentLongitude = self.locationManager.location.coordinate.longitude;

    [GPSDictionary setValue:[NSNumber numberWithDouble:currentLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [GPSDictionary setValue:[NSNumber numberWithDouble:currentLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];

    NSString* ref;
    if (currentLatitude <0.0)
        ref = @"S";
    else
        ref =@"N";
    [GPSDictionary setValue:ref forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];

    if (currentLongitude <0.0)
        ref = @"W";
    else
        ref =@"E";
    [GPSDictionary setValue:ref forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];

    [GPSDictionary setValue:[NSNumber numberWithFloat:self.locationManager.location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];

    //For EXIF Dictionary
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    if(!EXIFDictionary)
        EXIFDictionary = [NSMutableDictionary dictionary];

    [EXIFDictionary setObject:[NSDate date] forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    [EXIFDictionary setObject:[NSDate date] forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];

    //add our modified EXIF data back into the image’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];

    CFStringRef UTI = CGImageSourceGetType(source);

    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);

    if(!destination)
        dest_data = [pngData mutableCopy];
    else
    {
        CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) metadataAsMutable);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success)
            dest_data = [pngData mutableCopy];
    }

    if(destination)
        CFRelease(destination);

    CFRelease(source);

    return dest_data;
}

//FOR PHOTO LIBRARY IMAGE
- (NSMutableData *)getImagedataPhotoLibrary:(NSDictionary *)pImgDictionary andImage:(UIImage *)pImage
{
    NSData* data = UIImagePNGRepresentation(pImage);

    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    NSMutableDictionary *metadataAsMutable = [pImgDictionary mutableCopy];

    CFStringRef UTI = CGImageSourceGetType(source);

    NSMutableData *dest_data = [NSMutableData data];

    //For Mutabledata
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);

    if(!destination){
        dest_data = [data mutableCopy];
    }
    else
    {
        CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) metadataAsMutable);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success)
            dest_data = [data mutableCopy];
    }
    if(destination)
        CFRelease(destination);
    
    CFRelease(source);
    
    return dest_data;
}



- (void)processImageEXIFData:(NSData *)imageData
{
    CGImageSourceRef mySourceRef = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    if (mySourceRef != NULL)
    {
        NSDictionary *myMetadata = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(mySourceRef,0,NULL);
        NSDictionary *gpsDictionary = [myMetadata objectForKey:kCGImagePropertyGPSDictionary];

        

        NSLog(@"Parking spot latitude = %@", [gpsDictionary objectForKey:@"Latitude"]);
        NSLog(@"Parking spot longitude = %@", [gpsDictionary objectForKey:@"Longitude"]);

    }

    /*
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [locationManager startUpdatingLocation];
     */




    //For Testing
    //Setting the parking location to Khyber Pass
    CLLocationDegrees parkingLatitude = 39.9471513;
    CLLocationDegrees parkingLongitude = -75.1448697;
    self.parkingLocation = [[CLLocation alloc] initWithLatitude:parkingLatitude longitude:parkingLongitude];
    

    NSLog(@"parking latitude = %f", parkingLatitude);
    NSLog(@"parking longitude = %f", parkingLongitude);



}

// Location Manager Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

@end
