//
//  VOKBenkodeS3rvacCppBencodingTests.m
//  VOKBenkode
//
//  Created by Isaac Greenspan on 12/25/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKBenkode.h>

#import "VOKBenkodeAssert.h"

@interface VOKBenkodeS3rvacCppBencodingTests : XCTestCase

@end

@implementation VOKBenkodeS3rvacCppBencodingTests

#pragma mark - cases from https://github.com/s3rvac/cpp-bencoding/blob/master/tests/EncoderTests.cpp

#pragma mark Dictionary encoding.

- (void)test_EncoderTests_EmptyDictionarysIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString(@{}, @"de");
}

- (void)test_EncoderTests_DictionarysWithOneItemIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString((@{
                                         @"test": @1,
                                         }),
                                       @"d4:testi1ee");
}

- (void)test_EncoderTests_DictionarysWithTwoItemsIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString((@{
                                          @"test1": @1,
                                          @"test2": @2,
                                          }),
                                       @"d5:test1i1e5:test2i2ee");
}

#pragma mark Integer encoding.

- (void)test_EncoderTests_IntegerWithZeroValueIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString(@0, @"i0e");
}

- (void)test_EncoderTests_IntegerWithPositiveValueIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString(@13, @"i13e");
}

- (void)test_EncoderTests_IntegerWithNegativeValueIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString(@(-13), @"i-13e");
}

#pragma mark List encoding.

- (void)test_EncoderTests_EmptyListIsEncodedCorrectly
{
    AssertOriginalMatchesEncodedString(@[], @"le");
}

- (void)test_EncoderTests_ListContainingTwoStringsIsEncodedCorrectly
{
    AssertOriginalMatchesEncodedString((@[ @"test", @"hello", ]),
                                       @"l4:test5:helloe");
}

#pragma mark String encoding.

- (void)test_EncoderTests_EmptyStringIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString(@"", @"0:");
}

- (void)test_EncoderTests_NonemptyStringIsCorrectlyEncoded
{
    AssertOriginalMatchesEncodedString(@"test", @"4:test");
}

#pragma mark Other.

- (void)test_EncoderTests_EncodeFunctionWorksAsCreatingEncoderAndCallingEncode
{
    AssertOriginalMatchesEncodedString(@0, @"i0e");
}

#pragma mark - cases from https://github.com/s3rvac/cpp-bencoding/blob/master/tests/DecoderTests.cpp

#pragma mark Dictionary decoding.

- (void)test_DecoderTests_EmptyDictionaryIsDecodedCorrectly
{
    AssertOriginalMatchesEncodedString(@{}, @"de");
}

- (void)test_DecoderTests_DictionaryWithSingleItemIsDecodedCorrectly
{
    AssertOriginalMatchesEncodedString((@{
                                          @"test": @1,
                                          }),
                                       @"d4:testi1ee");
}

- (void)test_DecoderTests_DictionaryWithTwoItemsIsDecodedCorrectly
{
    AssertOriginalMatchesEncodedString((@{
                                          @"test1": @1,
                                          @"test2": @2,
                                          }),
                                       @"d5:test1i1e5:test2i2ee");
}

- (void)test_DecoderTests_DictionaryWithKeysThatAreNotSortedIsDecodedCorrectly
{
    // Even though the specification says that a dictionary has all its keys lexicographically sorted, we should
    // support the decoding of dictionaries whose keys are not sorted.  We can't, however, round-trip this ill-formed
    // encoded string.
    NSData *encoded = [@"d1:bi2e1:ai1ee" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode decode:encoded],
                          (@{
                             @"a": @1,
                             @"b": @2,
                             }));
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingDictionaryWithoutEndingE
{
    AssertDecodingProducesError(@"d");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingDictionaryWithKeyNotBeingString
{
    AssertOnlyStrictDecodingProducesError(@"di1ei2ee");
}

#pragma mark Integer decoding.

- (void)test_DecoderTests_IntegerZeroIsCorrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@0, @"i0e");
}

- (void)test_DecoderTests_PositiveIntegerIsCorrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@13, @"i13e");
}

- (void)test_DecoderTests_ExplicitlyPositiveIntegerIsCorrectlyDecoded
{
    NSData *encoded = [@"i+13e" dataUsingEncoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects([VOKBenkode decode:encoded], @13);
}

- (void)test_DecoderTests_NegativeIntegerIsCorrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@(-13), @"i-13e");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingIntegerWithoutEndingE
{
    AssertDecodingProducesError(@"i13");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingIntegerWithoutValue
{
    AssertDecodingProducesError(@"ie");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingIntegerWithBeginningWhitespace
{
    AssertDecodingProducesError(@"i 1e");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingIntegerWithTrailingWhitespace
{
    AssertDecodingProducesError(@"i1 e");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingIntegerIsPaddedWithZeros
{
    // From https://wiki.theory.org/BitTorrentSpecification#Bencoding:
    // "Only the significant digits should be used, one cannot pad the Integer with zeroes. such as i04e."
    AssertOnlyStrictDecodingProducesError(@"i001e");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenDecodingIntegerOfInvalidValue
{
    AssertDecodingProducesError(@"i e");
    AssertDecodingProducesError(@"i+e");
    AssertDecodingProducesError(@"i-e");
    AssertDecodingProducesError(@"i1-e");
    AssertDecodingProducesError(@"i1+e");
    AssertDecodingProducesError(@"i$e");
    AssertDecodingProducesError(@"i1.1e");
}

#pragma mark List decoding.

- (void)test_DecoderTests_EmptyListIsCorrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@[], @"le");
}

- (void)test_DecoderTests_ListWithSingleIntegerIsDecodedCorrectly
{
    AssertOriginalMatchesEncodedString((@[ @1, ]), @"li1ee");
}

- (void)test_DecoderTests_ListWithTwoStringsIsDecodedCorrectly
{
    AssertOriginalMatchesEncodedString((@[ @"test", @"hello", ]), @"l4:test5:helloe");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenCharEIsMissingFromEndOfList
{
    AssertDecodingProducesError(@"li1e");
    AssertDecodingProducesError(@"l4:test");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenListItemIsInvalidIsMissingFromEndOfList
{
    AssertDecodingProducesError(@"l$e");
}

#pragma mark String decoding.

- (void)test_DecoderTests_EmptyStringIsCorrrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@"", @"0:");
}

- (void)test_DecoderTestsNonemptyStringWithSingleCharacterIsCorrrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@"a", @"1:a");
}

- (void)test_DecoderTests_NonemptyStringWithTenCharacterIsCorrrectlyDecoded
{
    AssertOriginalMatchesEncodedString(@"abcdefghij", @"10:abcdefghij");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenColonIsMissingInString
{
    AssertDecodingProducesError(@"1a");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenStringHasNotEnoughCharacters
{
    AssertDecodingProducesError(@"3:aa");
}

#pragma mark Other.

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenInputIsEmpty
{
    AssertDecodingProducesError(@"");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenInputBeginsWithInvalidSymbol
{
    AssertDecodingProducesError(@"$");
}

- (void)test_DecoderTests_DecodeThrowsDecodingErrorWhenInputBeginsWithUnexpectedSymbol
{
    AssertDecodingProducesError(@"e");
}

@end
