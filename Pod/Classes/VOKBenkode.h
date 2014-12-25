//
//  VOKBenkode.h
//
//  Created by Isaac Greenspan on 12/23/14.
//  Copyright (c) 2014 VOKAL Interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const VOKBenkodeErrorDomain;

enum {
    VOKBenkodeErrorUnknownDataType,
    VOKBenkodeErrorMissingEndingDelimiter,
    VOKBenkodeErrorStringMissingColon,
    VOKBenkodeErrorStringLengthNegative,
    VOKBenkodeErrorStringLengthExceedsData,
    VOKBenkodeErrorDictionaryKeyNotString,
    VOKBenkodeErrorNumberInvalid,
} VOKBenkodeErrorCodes;

@interface VOKBenkode : NSObject

+ (NSData *)encode:(id)obj
    stringEncoding:(NSStringEncoding)stringEncoding
             error:(NSError **)error;
+ (NSData *)encode:(id)obj
             error:(NSError **)error;
+ (NSData *)encode:(id)obj
    stringEncoding:(NSStringEncoding)stringEncoding;
+ (NSData *)encode:(id)obj;

+ (id)decode:(NSData *)data
stringEncoding:(NSStringEncoding)stringEncoding
       error:(NSError **)error;
+ (id)decode:(NSData *)data
       error:(NSError **)error;
+ (id)decode:(NSData *)data
stringEncoding:(NSStringEncoding)stringEncoding;
+ (id)decode:(NSData *)data;

@end
