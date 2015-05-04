//
//  UIImage+EXIF.m
//  ParkSmart
//
//  Created by Rao, Amit on 4/20/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

@import ImageIO;
@import CoreLocation;
#import "UIImage+EXIF.h"

@implementation UIImage (EXIF)

//FOR CAMERA IMAGE

+ (NSMutableData *)getImageWithMetaData:(UIImage *)pImage
{
    NSData* pngData =  UIImagePNGRepresentation(pImage);

    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
    NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));

    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];

    //For GPS Dictionary
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if(!GPSDictionary)
        GPSDictionary = [NSMutableDictionary dictionary];

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters; // 10 m
    [locationManager startUpdatingLocation];

    CLLocationDegrees currentLatitude = locationManager.location.coordinate.latitude;
    CLLocationDegrees currentLongitude = locationManager.location.coordinate.longitude;

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

    [GPSDictionary setValue:[NSNumber numberWithFloat:locationManager.location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];

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

+ (NSMutableData *)getImagedataPhotoLibrary:(NSDictionary *)pImgDictionary andImage:(UIImage *)pImage
{
    NSData* data = UIImagePNGRepresentation(pImage);

    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    NSMutableDictionary *metadataAsMutable = [pImgDictionary mutableCopy];

    CFStringRef UTI = CGImageSourceGetType(source);

    NSMutableData *dest_data = [NSMutableData data];

    //For Mutabledata
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);

    if(!destination)
        dest_data = [data mutableCopy];
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

@end
