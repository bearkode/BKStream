/*
 *  BKStreamUtils.m
 *  BKStream
 *
 *  Created by bearkode on 2015. 4. 8..
 *  Copyright (c) 2015 bearkode. All rights reserved.
 *
 */

#import "BKStreamUtils.h"
#import <netdb.h>
#import <arpa/inet.h>


NSArray *BKGetAddressesFromHostName(NSString *aHostName)
{
    CFHostRef sHostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)aHostName);
    BOOL      sSuccess = CFHostStartInfoResolution(sHostRef, kCFHostAddresses, nil);
    
    if (!sSuccess)
    {
        return nil;
    }
    
    CFArrayRef sAddressesRef = CFHostGetAddressing(sHostRef, nil);
    
    if (sAddressesRef == nil)
    {
        return nil;
    }
    
    char            sIPAddress[INET6_ADDRSTRLEN];
    NSMutableArray *sAddresses    = [NSMutableArray array];
    CFIndex         sNumAddresses = CFArrayGetCount(sAddressesRef);
    
    for (CFIndex sIndex = 0; sIndex < sNumAddresses; sIndex++)
    {
        struct sockaddr *sAddress = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(sAddressesRef, sIndex));

        if (sAddress == nil)
        {
            return nil;
        }
        
        getnameinfo(sAddress, sAddress->sa_len, sIPAddress, INET6_ADDRSTRLEN, nil, 0, NI_NUMERICHOST);

        if (sIPAddress == nil)
        {
            return nil;
        }

        [sAddresses addObject:[NSString stringWithCString:sIPAddress encoding:NSASCIIStringEncoding]];
    }
    
    CFRelease(sHostRef);
    
    return sAddresses;
}
