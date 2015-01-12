//
//  VOKBenkodeDictionaryOrdering.m
//  VOKBenkode
//
//  Created by Isaac Greenspan on 12/29/14.
//  Copyright (c) 2014 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKBenkode.h>

#import "VOKBenkodeAssert.h"

@interface VOKBenkodeDictionaryOrdering : XCTestCase

@end

@implementation VOKBenkodeDictionaryOrdering

- (void)testFoo
{
    NSLog(@">>> %@", [[NSString alloc] initWithData:[VOKBenkode encode:@{
                                                                         @"email": @"user@example.com",
                                                                         @"password": @"password",
                                                                         }]
                                           encoding:NSUTF8StringEncoding]);
}

- (void)testVariantsOfA
{
    /* ```python
     from bencode import bencode
     bencode({ 'a':1, 'A':1, 'ä':1, 'Ä':1, 'å':1, 'â':1, 'Å':1, 'Â':1, 'á':1, 'Á':1, })
     ``` */
    NSString *pythonOutput = @"d1:Ai1e1:ai1e2:\xc3\x81i1e2:\xc3\x82i1e2:\xc3\x84i1e2:\xc3\x85i1e2:\xc3\xa1i1e2:\xc3\xa2i1e2:\xc3\xa4i1e2:\xc3\xa5i1ee";
    
    AssertOriginalMatchesEncodedString((@{ @"a": @1, @"A": @1, @"ä": @1, @"Ä": @1, @"å": @1, @"â": @1, @"Å": @1, @"Â": @1, @"á": @1, @"Á": @1, }),
                                       pythonOutput);
}

- (void)testAllFrom1To128
{
    /* ```python
     from bencode import bencode
     bencode(dict((chr(x), 1) for x in xrange(1, 128)))
     ``` */
    NSString *pythonOutput = @"d1:\x01i1e1:\x02i1e1:\x03i1e1:\x04i1e1:\x05i1e1:\x06i1e1:\x07i1e1:\x08i1e1:\ti1e1:\ni1e1:\x0bi1e1:\x0ci1e1:\ri1e1:\x0ei1e1:\x0fi1e1:\x10i1e1:\x11i1e1:\x12i1e1:\x13i1e1:\x14i1e1:\x15i1e1:\x16i1e1:\x17i1e1:\x18i1e1:\x19i1e1:\x1ai1e1:\x1bi1e1:\x1ci1e1:\x1di1e1:\x1ei1e1:\x1fi1e1: i1e1:!i1e1:\"i1e1:#i1e1:$i1e1:%i1e1:&i1e1:\'i1e1:(i1e1:)i1e1:*i1e1:+i1e1:,i1e1:-i1e1:.i1e1:/i1e1:0i1e1:1i1e1:2i1e1:3i1e1:4i1e1:5i1e1:6i1e1:7i1e1:8i1e1:9i1e1::i1e1:;i1e1:<i1e1:=i1e1:>i1e1:?i1e1:@i1e1:Ai1e1:Bi1e1:Ci1e1:Di1e1:Ei1e1:Fi1e1:Gi1e1:Hi1e1:Ii1e1:Ji1e1:Ki1e1:Li1e1:Mi1e1:Ni1e1:Oi1e1:Pi1e1:Qi1e1:Ri1e1:Si1e1:Ti1e1:Ui1e1:Vi1e1:Wi1e1:Xi1e1:Yi1e1:Zi1e1:[i1e1:\\i1e1:]i1e1:^i1e1:_i1e1:`i1e1:ai1e1:bi1e1:ci1e1:di1e1:ei1e1:fi1e1:gi1e1:hi1e1:ii1e1:ji1e1:ki1e1:li1e1:mi1e1:ni1e1:oi1e1:pi1e1:qi1e1:ri1e1:si1e1:ti1e1:ui1e1:vi1e1:wi1e1:xi1e1:yi1e1:zi1e1:{i1e1:|i1e1:}i1e1:~i1e1:\x7fi1ee";
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:127];
    for (NSUInteger index = 1; index < 128; index++) {
        dict[[NSString stringWithFormat:@"%c", (char)index]] = @1;
    }
    AssertOriginalMatchesEncodedString(dict, pythonOutput);
}

- (void)testMultiLengthKeys
{
    /* ```python
     from bencode import bencode
     bencode(dict((chr(x) * y, 1) for x in xrange(60, 120) for y in xrange(1, 5)))
     ``` */
    NSString *pythonOutput = @"d1:<i1e2:<<i1e3:<<<i1e4:<<<<i1e1:=i1e2:==i1e3:===i1e4:====i1e1:>i1e2:>>i1e3:>>>i1e4:>>>>i1e1:?i1e2:??i1e3:???i1e4:????i1e1:@i1e2:@@i1e3:@@@i1e4:@@@@i1e1:Ai1e2:AAi1e3:AAAi1e4:AAAAi1e1:Bi1e2:BBi1e3:BBBi1e4:BBBBi1e1:Ci1e2:CCi1e3:CCCi1e4:CCCCi1e1:Di1e2:DDi1e3:DDDi1e4:DDDDi1e1:Ei1e2:EEi1e3:EEEi1e4:EEEEi1e1:Fi1e2:FFi1e3:FFFi1e4:FFFFi1e1:Gi1e2:GGi1e3:GGGi1e4:GGGGi1e1:Hi1e2:HHi1e3:HHHi1e4:HHHHi1e1:Ii1e2:IIi1e3:IIIi1e4:IIIIi1e1:Ji1e2:JJi1e3:JJJi1e4:JJJJi1e1:Ki1e2:KKi1e3:KKKi1e4:KKKKi1e1:Li1e2:LLi1e3:LLLi1e4:LLLLi1e1:Mi1e2:MMi1e3:MMMi1e4:MMMMi1e1:Ni1e2:NNi1e3:NNNi1e4:NNNNi1e1:Oi1e2:OOi1e3:OOOi1e4:OOOOi1e1:Pi1e2:PPi1e3:PPPi1e4:PPPPi1e1:Qi1e2:QQi1e3:QQQi1e4:QQQQi1e1:Ri1e2:RRi1e3:RRRi1e4:RRRRi1e1:Si1e2:SSi1e3:SSSi1e4:SSSSi1e1:Ti1e2:TTi1e3:TTTi1e4:TTTTi1e1:Ui1e2:UUi1e3:UUUi1e4:UUUUi1e1:Vi1e2:VVi1e3:VVVi1e4:VVVVi1e1:Wi1e2:WWi1e3:WWWi1e4:WWWWi1e1:Xi1e2:XXi1e3:XXXi1e4:XXXXi1e1:Yi1e2:YYi1e3:YYYi1e4:YYYYi1e1:Zi1e2:ZZi1e3:ZZZi1e4:ZZZZi1e1:[i1e2:[[i1e3:[[[i1e4:[[[[i1e1:\\i1e2:\\\\i1e3:\\\\\\i1e4:\\\\\\\\i1e1:]i1e2:]]i1e3:]]]i1e4:]]]]i1e1:^i1e2:^^i1e3:^^^i1e4:^^^^i1e1:_i1e2:__i1e3:___i1e4:____i1e1:`i1e2:``i1e3:```i1e4:````i1e1:ai1e2:aai1e3:aaai1e4:aaaai1e1:bi1e2:bbi1e3:bbbi1e4:bbbbi1e1:ci1e2:cci1e3:ccci1e4:cccci1e1:di1e2:ddi1e3:dddi1e4:ddddi1e1:ei1e2:eei1e3:eeei1e4:eeeei1e1:fi1e2:ffi1e3:fffi1e4:ffffi1e1:gi1e2:ggi1e3:gggi1e4:ggggi1e1:hi1e2:hhi1e3:hhhi1e4:hhhhi1e1:ii1e2:iii1e3:iiii1e4:iiiii1e1:ji1e2:jji1e3:jjji1e4:jjjji1e1:ki1e2:kki1e3:kkki1e4:kkkki1e1:li1e2:lli1e3:llli1e4:lllli1e1:mi1e2:mmi1e3:mmmi1e4:mmmmi1e1:ni1e2:nni1e3:nnni1e4:nnnni1e1:oi1e2:ooi1e3:oooi1e4:ooooi1e1:pi1e2:ppi1e3:pppi1e4:ppppi1e1:qi1e2:qqi1e3:qqqi1e4:qqqqi1e1:ri1e2:rri1e3:rrri1e4:rrrri1e1:si1e2:ssi1e3:sssi1e4:ssssi1e1:ti1e2:tti1e3:ttti1e4:tttti1e1:ui1e2:uui1e3:uuui1e4:uuuui1e1:vi1e2:vvi1e3:vvvi1e4:vvvvi1e1:wi1e2:wwi1e3:wwwi1e4:wwwwi1ee";
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:240];
    for (NSUInteger index = 60; index < 120; index++) {
        for (NSUInteger count = 1; count < 5; count++) {
            NSString *key = @"";
            for (NSUInteger innerCount = 0; innerCount < count; innerCount++) {
                key = [key stringByAppendingFormat:@"%c", (char)index];
            }
            dict[key] = @1;
        }
    }
    AssertOriginalMatchesEncodedString(dict, pythonOutput);
    
    // Swap the construction loop order and make sure it doesn't change anything.
    dict = [NSMutableDictionary dictionaryWithCapacity:240];
    for (NSUInteger count = 1; count < 5; count++) {
        for (NSUInteger index = 60; index < 120; index++) {
            NSString *key = @"";
            for (NSUInteger innerCount = 0; innerCount < count; innerCount++) {
                key = [key stringByAppendingFormat:@"%c", (char)index];
            }
            dict[key] = @1;
        }
    }
    AssertOriginalMatchesEncodedString(dict, pythonOutput);
}

@end
