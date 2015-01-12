//
//  VOKBenkodeAristotlePagaltzisTests.m
//  VOKBenkode
//
//  Created by Isaac Greenspan on 12/26/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKBenkode.h>

#import "VOKBenkodeAssert.h"

// See also http://plasmasturm.org/log/420/

@interface VOKBenkodeAristotlePagaltzisTests : XCTestCase

@end

@implementation VOKBenkodeAristotlePagaltzisTests

#pragma mark - cases from http://cpansearch.perl.org/src/ARISTOTLE/Bencode-1.4/t/01.bdecode.t

- (void)test_decode
{
    AssertDecodingProducesError(@"i");  // unexpected end of data at 1\b | aborted integer'
    AssertDecodingProducesError(@"i0");  // malformed integer data at 1\b | unterminated integer'
    AssertDecodingProducesError(@"ie");  // malformed integer data at 1\b | empty integer'
    AssertDecodingProducesError(@"i341foo382e");  // malformed integer data at 1\b | malformed integer'
    AssertOriginalMatchesEncodedString(@4, @"i4e");
    AssertOriginalMatchesEncodedString(@0, @"i0e");
    AssertOriginalMatchesEncodedString(@123456789, @"i123456789e");
    AssertOriginalMatchesEncodedString(@(-10), @"i-10e");
    AssertOnlyStrictDecodingProducesError(@"i-0e");  // malformed integer data at 1\b | negative zero integer'
    AssertDecodingProducesError(@"i123");  // malformed integer data at 1\b | unterminated integer'
    AssertDecodingProducesError(@"");  // unexpected end of data at 0 | empty data'
    AssertDecodingProducesError(@"1:");  // unexpected end of string data starting at 2\b | string longer than data'
    AssertDecodingProducesError(@"35208734823ljdahflajhdf");  // garbage at 0 | garbage looking vaguely like a string, with large count'
    AssertOriginalMatchesEncodedString(@"", @"0:");
    AssertOriginalMatchesEncodedString(@"abc", @"3:abc");
    AssertOriginalMatchesEncodedString(@"1234567890", @"10:1234567890");
    AssertOnlyStrictDecodingProducesError(@"02:xy");  // malformed string length at 0\b | string with extra leading zero in count'
    AssertDecodingProducesError(@"l");  // unexpected end of data at 1\b | unclosed empty list'
    AssertOriginalMatchesEncodedString(@[], @"le");
    AssertOriginalMatchesEncodedString((@[ @"", @"", @"", ]), @"l0:0:0:e");
    AssertDecodingProducesError(@"relwjhrlewjh");  // garbage at 0 | complete garbage'
    AssertOriginalMatchesEncodedString((@[ @1, @2, @3, ]), @"li1ei2ei3ee");
    AssertOriginalMatchesEncodedString((@[ @"asd", @"xy", ]), @"l3:asd2:xye");
    AssertOriginalMatchesEncodedString((@[ @[ @"Alice", @"Bob", ], @[ @2, @3, ] ]), @"ll5:Alice3:Bobeli2ei3eee");
    AssertDecodingProducesError(@"d");  // unexpected end of data at 1\b | unclosed empty dict'
    AssertOriginalMatchesEncodedString(@{}, @"de");
    AssertOriginalMatchesEncodedString((@{ @"age": @25, @"eyes": @"blue" }), @"d3:agei25e4:eyes4:bluee");
    AssertOriginalMatchesEncodedString((@{ @"spam.mp3": @{ @"author": @"Alice", @"length": @100000 } }), @"d8:spam.mp3d6:author5:Alice6:lengthi100000eee");
    AssertDecodingProducesError(@"d3:fooe");  // dict key is missing value at 7\b | dict with odd number of elements'
    AssertOnlyStrictDecodingProducesError(@"di1e0:e");  // dict key is not a string at 1 | dict with integer key'
    AssertDecodingProducesError(@"d1:a0:1:a0:e");  // duplicate dict key at 9 | duplicate keys'
    AssertOnlyStrictDecodingProducesError(@"i03e");  // malformed integer data at 1 | integer with leading zero'
    AssertOnlyStrictDecodingProducesError(@"l01:ae");  // malformed string length at 1 | list with string with leading zero in count'
    AssertDecodingProducesError(@"9999:x");  // unexpected end of string data starting at 5 | string shorter than count'
    AssertDecodingProducesError(@"l0:");  // unexpected end of data at 3 | unclosed list with content'
    AssertDecodingProducesError(@"d0:0:");  // unexpected end of data at 5 | unclosed dict with content'
    AssertDecodingProducesError(@"d0:");  // unexpected end of data at 3 | unclosed dict with odd number of elements'
    AssertOnlyStrictDecodingProducesError(@"00:");  // malformed string length at 0 | zero-length string with extra leading zero in count'
    AssertDecodingProducesError(@"l-3:e");  // malformed string length at 1 | list with negative-length string'
    AssertOnlyStrictDecodingProducesError(@"i-03e");  // malformed integer data at 1 | negative integer with leading zero'
    AssertOriginalMatchesEncodedString(@"\x0A\x0D", @"2:\x0A\x0D");
}

#pragma mark - cases from http://cpansearch.perl.org/src/ARISTOTLE/Bencode-1.4/t/02.bencode.t

- (void)test_encode
{
    AssertOriginalMatchesEncodedString(@4, @"i4e");
    AssertOriginalMatchesEncodedString(@0, @"i0e");
    AssertOriginalMatchesEncodedString(@(-10), @"i-10e");
    AssertOriginalMatchesEncodedString(@"", @"0:");
    AssertOriginalMatchesEncodedString(@"abc", @"3:abc");
    AssertOriginalMatchesEncodedString(@"1234567890", @"10:1234567890");
    AssertOriginalMatchesEncodedString(@[], @"le");
    AssertOriginalMatchesEncodedString((@[ @1, @2, @3, ]), @"li1ei2ei3ee");
    AssertOriginalMatchesEncodedString((@[ @[ @"Alice", @"Bob", ], @[ @2, @3, ] ]), @"ll5:Alice3:Bobeli2ei3eee");
    AssertOriginalMatchesEncodedString(@{}, @"de");
    AssertOriginalMatchesEncodedString((@{ @"age": @25, @"eyes": @"blue", }), @"d3:agei25e4:eyes4:bluee");
    AssertOriginalMatchesEncodedString((@{
                                          @"spam.mp3": @{
                                                  @"author": @"Alice",
                                                  @"length": @100000,
                                                  },
                                          }),
                                       @"d8:spam.mp3d6:author5:Alice6:lengthi100000eee");
}

@end
