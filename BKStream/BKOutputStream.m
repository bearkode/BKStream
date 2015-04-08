/*
 *  BKOutputStream.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKOutputStream.h"


@interface BKStream (Privates)


- (NSStream *)stream;
- (NSMutableData *)buffer;
- (id)delegate;


@end


@implementation BKOutputStream


- (void)writeData:(NSData *)aData
{
    [[self buffer] appendData:aData];
    [self writeDataFromBuffer];
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
    [self writeDataFromBuffer];
}


- (void)didReceiveStreamEventErrorOccurred
{
    
}


- (void)didReceiveStreamEventEndEncountered
{
    NSData *sNewData = [[self stream] propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    if (!sNewData)
    {
        NSLog(@"No data written to memory!");
    }
    else
    {
        //  TODO :
        //  [self processData:newData];
    }
    
    [self close];
}


@end
