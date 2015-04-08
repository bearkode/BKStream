/*
 *  BKStream.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKStream.h"


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


#pragma mark -


- (void)didReceiveStreamEventNone
{
    
}


- (void)didReceiveStreamEventOpenComplete
{
    
}


- (void)didReceiveStreamEventHasBytesAvailable
{
    
}


- (void)didReceiveStreamEventHasSpaceAvailable
{
    
}


- (void)didReceiveStreamEventErrorOccurred
{
    
}


- (void)didReceiveStreamEventEndEncountered
{
    
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


@end


