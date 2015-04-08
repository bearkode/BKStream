/*
 *  BKStreamTests.m
 *  BKStreamTests
 *
 *  Created by bearkode on 2015. 4. 8..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "BKStream.h"


@interface BKStreamTests : XCTestCase


@end


@implementation BKStreamTests
{
    BOOL mCheck;
    BOOL mDidOpenCalled;
    BOOL mDidCloseCalled;
    BOOL mDidWriteCalled;
    BOOL mDidReadCalled;
}


- (void)setUp
{
    [super setUp];
}


- (void)tearDown
{
    [super tearDown];
}


- (void)testBasic
{
    NSInputStream  *sInputStream  = nil;
    NSOutputStream *sOutputStream = nil;
    BKStream       *sStream       = nil;
    
    [NSStream getStreamsToHostWithName:@"www.apple.com" port:80 inputStream:&sInputStream outputStream:&sOutputStream];
    
    XCTAssertTrue([sInputStream isKindOfClass:[NSInputStream class]]);
    XCTAssertTrue([sOutputStream isKindOfClass:[NSOutputStream class]]);
    
    sStream = [[[BKStream alloc] initWithInputStream:sInputStream outputStream:sOutputStream delegate:self] autorelease];

    XCTAssertTrue([sStream isKindOfClass:[BKStream class]]);
    
    [self waitWithTimeout:0.5 afterRunBlock:^{
        [sStream open];
    }];
    XCTAssertTrue(mDidOpenCalled);
    
    [self waitWithTimeout:0.5 afterRunBlock:^{
        NSData *sPacket = [[self httpRequestPacket] dataUsingEncoding:NSUTF8StringEncoding];
        [sStream writeData:sPacket];
    }];
    XCTAssertTrue(mDidWriteCalled);
    
    [self waitWithTimeout:0.5 afterRunBlock:nil];
    XCTAssertTrue(mDidReadCalled);

    [self waitWithTimeout:0.5 afterRunBlock:^{
        [sStream close];
    }];
    XCTAssertTrue(mDidCloseCalled);
}


- (void)streamDidOpen:(BKStream *)aStream
{
    mDidOpenCalled = YES;
    mCheck = YES;
}


- (void)streamDidClose:(BKStream *)aStream
{
    mDidCloseCalled = YES;
    mCheck = YES;
}


- (void)stream:(BKStream *)aStream didWriteData:(NSData *)aData
{
    XCTAssertTrue([aData length] > 0);
    
    mDidWriteCalled = YES;
    mCheck = YES;
}


- (void)stream:(BKStream *)aStream didReadData:(NSData *)aData
{
    XCTAssertTrue([aData length] > 0);
    
    [aStream handleDataUsingBlock:^NSInteger (NSData *aData) {
        NSString *sHTML = [[[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding] autorelease];
        XCTAssertTrue([sHTML length] > 100);
        NSLog(@"sHTML = %@", sHTML);
        return [aData length];
    }];
    
    mDidReadCalled = YES;
    mCheck = YES;
}


#pragma mark -


- (NSString *)httpRequestPacket
{
    NSMutableString *sResult = [NSMutableString string];
    
    [sResult appendString:@"GET / HTTP/1.1\n"];
    [sResult appendString:@"Host: www.apple.com\n"];
    [sResult appendString:@"Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\n"];
    [sResult appendString:@"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/600.4.10 (KHTML, like Gecko) Version/8.0.4 Safari/600.4.10\n"];
    [sResult appendString:@"Accept-Language: ko-kr\n"];
    [sResult appendString:@"Accept-Encoding: deflate\n"];
    [sResult appendString:@"Connection: keep-alive\n"];
    [sResult appendString:@"\n\n"];
    
    return sResult;
}


- (void)waitWithTimeout:(NSTimeInterval)aTimeInterval afterRunBlock:(void (^)(void))aBlock
{
    NSDate *sDate = [NSDate dateWithTimeIntervalSinceNow:aTimeInterval];
    
    mCheck = NO;
    
    if (aBlock)
    {
        aBlock();
    }
    
    while (!mCheck && [sDate timeIntervalSinceNow] > 0)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}


@end
