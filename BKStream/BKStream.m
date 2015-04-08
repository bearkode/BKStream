/*
 *  BKStream.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKStream.h"


static const NSInteger kMaxBufferSize = 1024;


@implementation BKStream
{
    id             mDelegate;
    NSStream      *mStream;
    NSMutableData *mBuffer;
}


- (instancetype)initWithStream:(NSStream *)aStream delegate:(id)aDelegate
{
    self = [super init];
    
    if (self)
    {
        mDelegate = aDelegate;
        mStream   = [aStream retain];
        mBuffer   = [[NSMutableData alloc] init];
        
        [mStream setDelegate:self];
    }
    
    return self;
}


- (void)dealloc
{
    [self close];
    
    [mStream release];
    [mBuffer release];
    
    [super dealloc];
}


- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aEventCode
{
    static NSDictionary   *sDispatchTable = nil;
    static dispatch_once_t sOnceToken;
    
    dispatch_once(&sOnceToken, ^{
        sDispatchTable = [@{ [NSNumber numberWithUnsignedInteger:NSStreamEventNone]              : NSStringFromSelector(@selector(didReceiveStreamEventNone)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventOpenCompleted]     : NSStringFromSelector(@selector(didReceiveStreamEventOpenComplete)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventHasBytesAvailable] : NSStringFromSelector(@selector(didReceiveStreamEventHasBytesAvailable)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventHasSpaceAvailable] : NSStringFromSelector(@selector(didReceiveStreamEventHasSpaceAvailable)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventErrorOccurred]     : NSStringFromSelector(@selector(didReceiveStreamEventErrorOccurred)),
                             [NSNumber numberWithUnsignedInteger:NSStreamEventEndEncountered]    : NSStringFromSelector(@selector(didReceiveStreamEventEndEncountered)) } retain];
    });
    
    SEL sSelector = NSSelectorFromString([sDispatchTable objectForKey:[NSNumber numberWithUnsignedInteger:aEventCode]]);
    
    if (sSelector)
    {
        [self performSelector:sSelector withObject:nil];
    }
}


#pragma mark -


- (void)open
{
    [mStream open];
    [mStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)close
{
    [mStream close];
    [mStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)handleDataUsingBlock:(NSInteger (^)(NSData *aData))aBlock
{
    if (!aBlock)
    {
        return;
    }
    
    NSInteger sHandeledLength = 1;
    
    while ([mBuffer length] && sHandeledLength)
    {
        sHandeledLength = aBlock(mBuffer);
        
        if (sHandeledLength)
        {
            [mBuffer replaceBytesInRange:NSMakeRange(0, sHandeledLength) withBytes:NULL length:0];
        }
    }
}


- (void)writeData:(NSData *)aData
{
    [[self buffer] appendData:aData];
    [self writeDataFromBuffer];
}


#pragma mark -


- (void)didReceiveStreamEventNone
{
    
}


- (void)didReceiveStreamEventOpenComplete
{
    
}


- (void)didReceiveStreamEventHasBytesAvailable
{
    UInt8      sBuffer[kMaxBufferSize];
    NSUInteger sLength = 0;
    NSData    *sReceivedData = nil;
    
    if ([(NSInputStream *)[self stream] hasBytesAvailable])
    {
        sLength = [(NSInputStream *)[self stream] read:sBuffer maxLength:kMaxBufferSize];
        NSLog(@"sLength = %ld", sLength);
        
        if (sLength)
        {
            sReceivedData = [NSData dataWithBytes:sBuffer length:sLength];
            [[self buffer] appendData:sReceivedData];
            
            if ([[self delegate] respondsToSelector:@selector(stream:didReceiveData:)])
            {
                [[self delegate] stream:self didReceiveData:sReceivedData];
            }
        }
        else
        {
            NSLog(@"no buffer!");
        }
    }
    else
    {
        NSLog(@"???");
    }
}


- (void)didReceiveStreamEventHasSpaceAvailable
{
    [self writeDataFromBuffer];
}


- (void)didReceiveStreamEventErrorOccurred
{
    
}


- (void)didReceiveStreamEventEndEncountered
{
    [self close];
}


#pragma mark -


- (NSStream *)stream
{
    return mStream;
}


- (NSMutableData *)buffer
{
    return mBuffer;
}


- (id)delegate
{
    return mDelegate;
}


- (void)writeDataFromBuffer
{
    NSOutputStream *sStream = (NSOutputStream *)[self stream];
    NSMutableData  *sBuffer = [self buffer];
    
    if ([sStream hasSpaceAvailable] && [[self buffer] length])
    {
        NSInteger sWrittenLength = [sStream write:[sBuffer bytes] maxLength:[sBuffer length]];
        
        if (sWrittenLength > 0)
        {
            [sBuffer replaceBytesInRange:NSMakeRange(0, sWrittenLength) withBytes:NULL length:0];
        }
    }
}


@end


