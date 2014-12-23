//
//  VOKBenkodeTests.m
//  VOKBenkodeTests
//
//  Created by Isaac Greenspan on 12/23/2014.
//  Copyright (c) 2014 Isaac Greenspan. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKBenkode.h>

@interface VOKBenkodeTests : XCTestCase

@end

@implementation VOKBenkodeTests

#pragma mark - Test Cases from https://github.com/mjackson/bencode/blob/master/tests/Bencode.php

- (void)test_mjackson_1
{
    NSString *original = @"hello world";
    NSData *encoded = [@"11:hello world" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode encode:original], encoded);
    XCTAssertEqualObjects([VOKBenkode decode:encoded], original);
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

- (void)test_mjackson_2
{
    NSNumber *original = @123;
    NSData *encoded = [@"i123e" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode encode:original], encoded);
    XCTAssertEqualObjects([VOKBenkode decode:encoded], original);
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

- (void)test_mjackson_3
{
    NSArray *original = @[ @1, @2, @3, ];
    NSData *encoded = [@"li1ei2ei3ee" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode encode:original], encoded);
    XCTAssertEqualObjects([VOKBenkode decode:encoded], original);
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

- (void)test_mjackson_4
{
    NSDictionary *original = @{
                               @"a": @"b",
                               @"c": @"def",
                               };
    NSData *encoded = [@"d1:a1:b1:c3:defe" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode encode:original], encoded);
    XCTAssertEqualObjects([VOKBenkode decode:encoded], original);
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

#pragma mark - Test Cases from https://github.com/rgrinberg/bencode/blob/master/lib_test/test_ounit.ml

- (void)test_rgrinberg_1
{
    NSArray *original = @[ @42, @0, @(-200), ];
    NSData *encoded = [@"li42ei0ei-200ee" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode encode:original], encoded);
    XCTAssertEqualObjects([VOKBenkode decode:encoded], original);
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

- (void)test_rgrinberg_2
{
    NSDictionary *original = @{
                               @"foo": @42,
                               @"bar": @[ @0, @"caramba si", ],
                               @"": @"",
                               };
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

- (void)test_rgrinberg_3
{
    NSDictionary *original = @{
                               @"a": @1,
                               @"b": @"bbbb",
                               @"l": @[ @0, @0, @"zero\n\t \x00", ],
                               @"d": @{ @"foo": @"bar", },
                               };
    XCTAssertEqualObjects([VOKBenkode decode:[VOKBenkode encode:original]], original);
}

@end