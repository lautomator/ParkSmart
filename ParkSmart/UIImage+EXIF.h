//
//  UIImage+EXIF.h
//  ParkSmart
//
//  Created by Rao, Amit on 4/20/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (EXIF)

+ (NSMutableData *)getImageWithMetaData:(UIImage *)pImage;
+ (NSMutableData *)getImagedataPhotoLibrary:(NSDictionary *)pImgDictionary andImage:(UIImage *)pImage;

@end
