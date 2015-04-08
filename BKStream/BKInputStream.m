/*
 *  BKInputStream.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKInputStream.h"


static const NSInteger kMaxBufferSize = 1024;


@interface BKStream (Privates)


- (NSStream *)stream;
- (NSMutableData *)buffer;
- (id)delegate;


@end


@implementation BKInputStream


- (void)handleDataUsingBlock:(NSInteger (^)(NSData *aData))aBlock
{
    if (!aBlock)
    {
        return;
    }
    
    NSInteger sHandeledLength = 1;
    
    while ([[self buffer] length] && sHandeledLength)
    {
        sHandeledLength = aBlock([self buffer]);
        
        if (sHandeledLength)
        {
            [[self buffer] replaceBytesInRange:NSMakeRange(0, sHandeledLength) withBytes:NULL length:0];
        }
    }
}


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
    
}


- (void)didReceiveStreamEventErrorOccurred
{
    NSLog(@"didReceiveStreamEventError");
}


- (void)didReceiveStreamEventEndEncountered
{
    NSLog(@"stream event end encountered");
    
    [self close];
}


@end
