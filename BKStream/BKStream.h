/*
 *  BKStream.h
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>


@interface BKStream : NSObject <NSStreamDelegate>


- (instancetype)initWithStream:(NSStream *)aStream delegate:(id)aDelegate;


- (void)open;
- (void)close;


- (void)handleDataUsingBlock:(NSInteger (^)(NSData *aData))aBlock;
- (void)writeData:(NSData *)aData;


/*  Override  */
- (void)didReceiveStreamEventNone;
- (void)didReceiveStreamEventOpenComplete;
- (void)didReceiveStreamEventHasBytesAvailable;
- (void)didReceiveStreamEventHasSpaceAvailable;
- (void)didReceiveStreamEventErrorOccurred;
- (void)didReceiveStreamEventEndEncountered;


@end


@protocol NEBufferedStreamDelegate <NSObject>

- (void)stream:(BKStream *)aStream didReceiveData:(NSData *)aData;

@end