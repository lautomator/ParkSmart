//
//  UIImage+UIImage_Rotate.m
//  ParkSmart
//
//  Created by Rao, Amit on 1/25/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

#import "UIImage+Rotate.h"

@implementation UIImage (Rotate)

// Apple only stores EXIF orientation in the image meta data and does not rotate the image.
// So image taken in portrait and landscape mode differ in only EXIF orientation.
// Windows and many image viewers do not parse EXIF orientation.
// This method rotates the image based on the EXIF orientation of the image.
+ (UIImage*) rotateImageToEXIFOrientation:(UIImage*) src
{
    UIGraphicsBeginImageContext(src.size);
    UIImageOrientation orientation = src.imageOrientation;
    
    CGContextRef context= UIGraphicsGetCurrentContext();
    
    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM (context, 90/180*M_PI) ;
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM (context, -90/180*M_PI);
    } else if (orientation == UIImageOrientationDown) {
        // NOTHING
    } else if (orientation == UIImageOrientationUp) {
        CGContextRotateCTM (context, 90/180*M_PI);
    }
    
    [src drawAtPoint:CGPointMake(0, 0)];
    UIImage *img=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end
