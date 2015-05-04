//
//  StringParser.m
//  ParkSmart
//
//  Created by Rao, Amit on 2/21/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

#import "StringParser.h"

@implementation StringParser

+ (NSString *)expiryDateFromString:(NSString *)string
{
    NSString *expiryTimeString = nil;
    
    
    NSError *error = nil;
    NSString *matchPattern = @"\\d\\d:\\d\\d(A|P)M";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:matchPattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];

    NSRange notFound = {NSNotFound, 0};
                                    
    if(NSEqualRanges(result.range, notFound))
    {
        NSLog(@"Could not parse the expiry timestamp from the OCR String %@", string);
    }
    else
    {
        expiryTimeString = [string substringWithRange:result.range];
    }
    
    return expiryTimeString;
}



@end
