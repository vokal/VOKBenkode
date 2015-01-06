//
//  VOKBenkodeLibTransmissionTests.m
//  VOKBenkode
//
//  Created by Isaac Greenspan on 12/26/14.
//  Copyright (c) 2014 VOKAL Interactive. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKBenkode.h>

#import "VOKBenkodeAssert.h"

@interface VOKBenkodeLibTransmissionTests : XCTestCase

@end

@implementation VOKBenkodeLibTransmissionTests

#pragma mark - cases from https://trac.transmissionbt.com/browser/trunk/libtransmission/bencode-test.c?rev=11688

- (void)testInt
{
    // good int string
    AssertOriginalMatchesEncodedString(@64, @"i64e");
    
    // missing 'e'
    AssertDecodingProducesError(@"i64");
    
    // empty buffer
    AssertDecodingProducesError(@"");
    
    // bad number
    AssertDecodingProducesError(@"i6z4e");
    
    // negative number
    AssertOriginalMatchesEncodedString(@(-3), @"i-3e");
    
    // zero
    AssertOriginalMatchesEncodedString(@0, @"i0e");
    
    // no leading zeroes allowed
    AssertOnlyStrictDecodingProducesError(@"i04e");
}

- (void)testStr
{
    // good string
    AssertOriginalMatchesEncodedString(@"boat", @"4:boat");
    
    // string goes past end of buffer
    AssertDecodingProducesError(@"4:boa");
    
    // empty string
    AssertOriginalMatchesEncodedString(@"", @"0:");
    
    // short string
    XCTAssertEqualObjects([VOKBenkode decode:[@"3:boat" dataUsingEncoding:NSUTF8StringEncoding]], @"boa");
}

- (void)testParse
{
    AssertOriginalMatchesEncodedString(@64, @"i64e");
    
    AssertOriginalMatchesEncodedString((@[ @64, @32, @16, ]), @"li64ei32ei16ee");
    
    AssertDecodingProducesError(@"lllee");
    
    AssertOriginalMatchesEncodedString(@[], @"le");
    
    AssertOriginalMatchesEncodedString(@[@[@[]]], @"llleee");
    
    AssertOriginalMatchesEncodedString((@{
                                          @"cow": @"moo",
                                          @"spam": @"eggs",
                                          }),
                                       @"d3:cow3:moo4:spam4:eggse");
    
    AssertOriginalMatchesEncodedString((@{
                                          @"spam": @[ @"a", @"b", ],
                                          }),
                                       @"d4:spaml1:a1:bee");
    
    AssertOriginalMatchesEncodedString((@{
                                          @"green": @[ @1, @2, @3, ],
                                          @"spam": @{
                                                  @"a": @123,
                                                  @"key": @214,
                                                  },
                                          }),
                                       @"d5:greenli1ei2ei3ee4:spamd1:ai123e3:keyi214eee");
    
    AssertOriginalMatchesEncodedString((@{
                                          @"publisher": @"bob",
                                          @"publisher-webpage": @"www.example.com",
                                          @"publisher.location": @"home",
                                          }),
                                       @"d9:publisher3:bob17:publisher-webpage15:www.example.com18:publisher.location4:homee");
    
    AssertOriginalMatchesEncodedString((@{
                                          @"complete": @1,
                                          @"interval": @1800,
                                          @"min interval": @1800,
                                          @"peers": @"",
                                          }),
                                       @"d8:completei1e8:intervali1800e12:min intervali1800e5:peers0:e");
    
    AssertDecodingProducesError(@"d1:ai0e1:be");  // odd number of children
    
    AssertDecodingProducesError(@"");
    
    AssertDecodingProducesError(@" ");
    
    // decode an unsorted dict, re-encode it, and make sure it comes out sorted
    XCTAssertEqualObjects([VOKBenkode encode:[VOKBenkode decode:[@"lld1:bi32e1:ai64eeee" dataUsingEncoding:NSUTF8StringEncoding]]],
                          [@"lld1:ai64e1:bi32eeee" dataUsingEncoding:NSUTF8StringEncoding]);
    
    // too many endings
    XCTAssertEqualObjects([VOKBenkode encode:[VOKBenkode decode:[@"leee" dataUsingEncoding:NSUTF8StringEncoding]]],
                          [@"le" dataUsingEncoding:NSUTF8StringEncoding]);
    
    // no ending
    AssertDecodingProducesError(@"l1:a1:b1:c");
    
    // incomplete string
    AssertDecodingProducesError(@"1:");
}

- (void)testJSON
{
    AssertBencodedStringAndJsonStringYieldEqualObjects(@"i6e", @"6");
    
    AssertBencodedStringAndJsonStringYieldEqualObjects(@"d5:helloi1e5:worldi2ee", @"{\"hello\":1,\"world\":2}");
    
    AssertBencodedStringAndJsonStringYieldEqualObjects(@"d5:helloi1e5:worldi2e3:fooli1ei2ei3eee",
                                                       @"{\"foo\":[1,2,3],\"hello\":1,\"world\":2}");
    
    AssertBencodedStringAndJsonStringYieldEqualObjects(@"d5:helloi1e5:worldi2e3:fooli1ei2ei3ed1:ai0eeee",
                                                       @"{\"foo\":[1,2,3,{\"a\":0}],\"hello\":1,\"world\":2}");
    
    AssertBencodedStringAndJsonStringYieldEqualObjects(@"d4:argsd6:statusle7:status2lee6:result7:successe",
                                                       @"{\"args\":{\"status\":[],\"status2\":[]},\"result\":\"success\"}");
}

- (void)testStackSmash
{
    NSUInteger depth = 10000;  // Passes for 10,000; fails (stack limit?) for 100,000.
    NSMutableString *encodedString = [NSMutableString stringWithCapacity:(2 * depth)];
    for (NSUInteger i = 0; i < depth; ++i) {
        [encodedString appendString:@"l"];
    }
    for (NSUInteger i = 0; i < depth; ++i) {
        [encodedString appendString:@"e"];
    }
    id decoded = [VOKBenkode decode:[encodedString dataUsingEncoding:NSUTF8StringEncoding]];
    XCTAssertNotNil(decoded);
}

@end
