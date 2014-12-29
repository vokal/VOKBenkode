//
//  VOKBenkodeTests.m
//  VOKBenkodeTests
//
//  Created by Isaac Greenspan on 12/23/2014.
//  Copyright (c) 2014 VOKAL Interactive. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKBenkode.h>

#import "VOKBenkodeAssert.h"

@interface VOKBenkodeBasicTests : XCTestCase

@end

@implementation VOKBenkodeBasicTests

#pragma mark - Test Cases from https://github.com/mjackson/bencode/blob/master/tests/Bencode.php

- (void)test_mjackson_1
{
    AssertOriginalMatchesEncodedString(@"hello world", @"11:hello world");
}

- (void)test_mjackson_2
{
    AssertOriginalMatchesEncodedString(@123, @"i123e");
}

- (void)test_mjackson_3
{
    AssertOriginalMatchesEncodedString((@[ @1, @2, @3, ]), @"li1ei2ei3ee");
}

- (void)test_mjackson_4
{
    AssertOriginalMatchesEncodedString((@{
                                          @"a": @"b",
                                          @"c": @"def",
                                          }),
                                       @"d1:a1:b1:c3:defe");
}

#pragma mark - Test Cases from https://github.com/rgrinberg/bencode/blob/master/lib_test/test_ounit.ml

- (void)test_rgrinberg_1
{
    AssertOriginalMatchesEncodedString((@[ @42, @0, @(-200), ]),
                                       @"li42ei0ei-200ee");
}

- (void)test_rgrinberg_2
{
    AssertOriginalMatchesEncodedString((@{
                                          @"foo": @42,
                                          @"bar": @[ @0, @"caramba si", ],
                                          @"": @"",
                                          }),
                                       @"d0:0:3:barli0e10:caramba sie3:fooi42ee");
}

- (void)test_rgrinberg_3
{
    // Because of the null character (\x00), this cannot be expressed in an NSString that will convert to/from NSData,
    // so can't be checked against an expected encoded string.
    NSDictionary *original = @{
                               @"a": @1,
                               @"b": @"bbbb",
                               @"l": @[ @0, @0, @"zero\n\t \x00", ],
                               @"d": @{ @"foo": @"bar", },
                               };
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

@end