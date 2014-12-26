//
//  VOKBenkodeAssert.h
//  VOKBenkode
//
//  Created by Isaac Greenspan on 12/25/14.
//  Copyright (c) 2014 Isaac Greenspan. All rights reserved.
//

#ifndef VOKBenkode_VOKBenkodeAssert_h
#define VOKBenkode_VOKBenkodeAssert_h

#define AssertOriginalMatchesEncodedString(__original, __encodedString) \
    ({ \
        id original = (__original); \
        NSData *encoded = [(__encodedString) dataUsingEncoding:NSUTF8StringEncoding]; \
        XCTAssertEqualObjects([VOKBenkode encode:original], encoded); \
        XCTAssertEqualObjects([VOKBenkode decode:encoded], original); \
        XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original); \
    })

#define AssertDecodingProducesError(__encodedString) \
    ({ \
        NSData *encoded = [(__encodedString) dataUsingEncoding:NSUTF8StringEncoding]; \
        NSError *error; \
        id decoded = [VOKBenkode decode:encoded error:&error]; \
        XCTAssertNil(decoded); \
        XCTAssertNotNil(error); \
    })

#define AssertBencodedStringAndJsonStringYieldEqualObjects(__encodedString, __jsonString) \
    ({ \
        id bdecoded = [VOKBenkode decode:[(__encodedString) dataUsingEncoding:NSUTF8StringEncoding]]; \
        id json = [NSJSONSerialization JSONObjectWithData:[(__jsonString) dataUsingEncoding:NSUTF8StringEncoding] \
                                                  options:NSJSONReadingAllowFragments \
                                                    error:NULL]; \
        XCTAssertEqualObjects(bdecoded, json); \
    })

#endif
