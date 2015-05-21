//
//  LocationManager.h
//  ParkSmart
//
//  Created by Rao, Amit on 5/4/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

@import Foundation;

@interface ImageLocationManager : NSObject

@property (nonatomic, strong) CLLocation *parkingLocation;
@property (nonatomic, strong) CLLocation *currentLocation;

+ (instancetype)sharedInstance;
- (NSMutableData *)getImageWithMetaData:(UIImage *)pImage;
- (NSMutableData *)getImagedataPhotoLibrary:(NSDictionary *)pImgDictionary andImage:(UIImage *)pImage;
- (void)processImageEXIFData:(NSData *)imageData;

@end
