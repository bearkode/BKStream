/*
 *  BKInputStream.h
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 7..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKStream.h"


@interface BKInputStream : BKStream


- (void)handleDataUsingBlock:(NSInteger (^)(NSData *aData))aBlock;


@end
