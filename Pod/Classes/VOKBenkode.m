//
//  VOKBenkode.m
//
//  Created by Isaac Greenspan on 12/23/14.
//  Copyright (c) 2014 VOKAL Interactive. All rights reserved.
//

#import "VOKBenkode.h"

@implementation VOKBenkode

#pragma mark - Encoding

+ (NSData *)encode:(id)obj
    stringEncoding:(NSStringEncoding)stringEncoding
             error:(NSError **)error
{
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [[NSString stringWithFormat:@"i%lde", [obj longValue]] dataUsingEncoding:NSASCIIStringEncoding];
    } else if ([obj isKindOfClass:[NSString class]]) {
        NSMutableData *result = [[[NSString stringWithFormat:@"%@:", @([obj length])] dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
        [result appendData:[obj dataUsingEncoding:stringEncoding]];
        return result;
    } else if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableData *result = [NSMutableData dataWithBytes:"l" length:1];
        for (id innerObj in obj) {
            NSError *innerError;
            NSData *data = [self encode:innerObj
                         stringEncoding:stringEncoding
                                  error:&innerError];
            if (!data) {
                // TODO: bubble up innerError -> error.
                return nil;
            }
            [result appendData:data];
        }
        [result appendBytes:"e" length:1];
        return result;
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableData *result = [NSMutableData dataWithBytes:"d" length:1];
        for (id key in obj) {
            NSError *innerError;
            NSData *data = [self encode:key
                         stringEncoding:stringEncoding
                                  error:&innerError];
            if (!data) {
                // TODO: bubble up innerError -> error.
                return nil;
            }
            [result appendData:data];
            data = [self encode:obj[key]
                 stringEncoding:stringEncoding
                          error:&innerError];
            if (!data) {
                // TODO: bubble up innerError -> error.
                return nil;
            }
            [result appendData:data];
        }
        [result appendBytes:"e" length:1];
        return result;
    } else {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
}

+ (NSData *)encode:(id)obj
             error:(NSError **)error
{
    return [self encode:obj
         stringEncoding:NSUTF8StringEncoding
                  error:error];
}

+ (NSData *)encode:(id)obj
    stringEncoding:(NSStringEncoding)stringEncoding
{
    return [self encode:obj
         stringEncoding:stringEncoding
                  error:NULL];
}

+ (NSData *)encode:(id)obj
{
    return [self encode:obj
                  error:NULL];
}

#pragma mark - Decoding

+ (id)decode:(NSData *)data
stringEncoding:(NSStringEncoding)stringEncoding
       error:(NSError **)error
      length:(NSUInteger *)length
{
    char *dataBytes = (char *)data.bytes;
    char firstByte = dataBytes[0];
    switch (firstByte) {
        case 'd':
            return [self decodeDict:data
                     stringEncoding:stringEncoding
                              error:error
                             length:length];
            
        case 'l':
            return [self decodeArray:data
                      stringEncoding:stringEncoding
                               error:error
                              length:length];
            
        case 'i':
            return [self decodeNumber:data
                                error:error
                               length:length];
            
        case '0':  // Intentional grouping.
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
            return [self decodeString:data
                       stringEncoding:stringEncoding
                                error:error
                               length:length];
            
        default:
            if (error) {
                // TODO: set error object
            }
            return nil;
    }
}

+ (id)decode:(NSData *)data
stringEncoding:(NSStringEncoding)stringEncoding
       error:(NSError **)error
{
    return [self decode:data
         stringEncoding:stringEncoding
                  error:error
                 length:NULL];
}

+ (id)decode:(NSData *)data
       error:(NSError **)error
{
    return [self decode:data
         stringEncoding:NSUTF8StringEncoding
                  error:error];
}

+ (id)decode:(NSData *)data
stringEncoding:(NSStringEncoding)stringEncoding
{
    return [self decode:data
         stringEncoding:stringEncoding
                  error:NULL];
}

+ (id)decode:(NSData *)data
{
    return [self decode:data
                  error:NULL];
}

#pragma mark Decoding Primitives

+ (NSDictionary *)decodeDict:(NSData *)data
              stringEncoding:(NSStringEncoding)stringEncoding
                       error:(NSError **)error
                      length:(NSUInteger *)length
{
    char *dataBytes = (char *)data.bytes;
    NSAssert(dataBytes[0] == 'd', @"Data does not begin with dictionary-data indicator.");
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSUInteger index = 1;
    while (index < data.length
           && dataBytes[index] != 'e') {
        NSError *innerError;
        NSUInteger innerLength;
        id innerKey = [self decode:[data subdataWithRange:NSMakeRange(index, data.length - index)]
                    stringEncoding:stringEncoding
                             error:&innerError
                            length:&innerLength];
        if (!innerKey) {
            // TODO: bubble up innerError -> error.
            return nil;
        }
        index += innerLength;
        id innerValue = [self decode:[data subdataWithRange:NSMakeRange(index, data.length - index)]
                      stringEncoding:stringEncoding
                               error:&innerError
                              length:&innerLength];
        if (!innerValue) {
            // TODO: bubble up innerError -> error.
            return nil;
        }
        result[innerKey] = innerValue;
        index += innerLength;
    }
    if (index >= data.length) {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
    if (length) {
        *length = index + 1;  // +1 for the 'e' at the end.
    }
    return result;
}

+ (NSArray *)decodeArray:(NSData *)data
          stringEncoding:(NSStringEncoding)stringEncoding
                   error:(NSError **)error
                  length:(NSUInteger *)length
{
    char *dataBytes = (char *)data.bytes;
    NSAssert(dataBytes[0] == 'l', @"Data does not begin with array-data indicator.");
    NSMutableArray *result = [NSMutableArray array];
    NSUInteger index = 1;
    while (index < data.length
           && dataBytes[index] != 'e') {
        NSError *innerError;
        NSUInteger innerLength;
        id innerObject = [self decode:[data subdataWithRange:NSMakeRange(index, data.length - index)]
                       stringEncoding:stringEncoding
                                error:&innerError
                               length:&innerLength];
        if (!innerObject) {
            // TODO: bubble up innerError -> error.
            return nil;
        }
        [result addObject:innerObject];
        index += innerLength;
    }
    if (index >= data.length) {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
    if (length) {
        *length = index + 1;  // +1 for the 'e' at the end.
    }
    return result;
}

+ (NSNumber *)decodeNumber:(NSData *)data
                     error:(NSError **)error
                    length:(NSUInteger *)length
{
    char *dataBytes = (char *)data.bytes;
    NSAssert(dataBytes[0] == 'i', @"Data does not begin with numeric-data indicator.");
    NSMutableString *buffer = [NSMutableString stringWithCapacity:data.length - 2];
    NSUInteger index = 1;
    while (index < data.length
           && dataBytes[index] != 'e') {
        [buffer appendFormat:@"%c", dataBytes[index]];
        index++;
    }
    if (index >= data.length) {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
    if (length) {
        *length = index + 1;  // +1 for the 'e' at the end.
    }
    return [NSNumber numberWithLongLong:[buffer longLongValue]];
}

+ (NSString *)decodeString:(NSData *)data
            stringEncoding:(NSStringEncoding)stringEncoding
                     error:(NSError **)error
                    length:(NSUInteger *)length
{
    char *dataBytes = (char *)data.bytes;
    NSMutableString *buffer = [NSMutableString stringWithCapacity:data.length - 2];
    NSUInteger index = 0;
    while (index < data.length
           && dataBytes[index] != ':') {
        [buffer appendFormat:@"%c", dataBytes[index]];
        index++;
    }
    if (index >= data.length) {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
    long long stringLength = [buffer longLongValue];
    if (stringLength < 0) {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
    index++;  // +1 for the ':' between the length and the string.
    NSUInteger localLength = index + stringLength;
    if (localLength > data.length) {
        if (error) {
            // TODO: set error object
        }
        return nil;
    }
    if (length) {
        *length = localLength;
    }
    return [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(index, stringLength)]
                                 encoding:stringEncoding];
}

@end
