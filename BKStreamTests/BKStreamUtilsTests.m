/*
 *  BKStreamUtilsTests.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 8..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BKStreamUtils.h"


@interface BKStreamUtilsTests : XCTestCase


@end


@implementation BKStreamUtilsTests


- (void)setUp
{
    [super setUp];
}


- (void)tearDown
{
    [super tearDown];
}


- (void)testBKGetAddressesFromHostName
{
    NSArray *sResult = BKGetAddressesFromHostName(@"www.apple.com");
    NSLog(@"sResult = %@", sResult);
}


@end
