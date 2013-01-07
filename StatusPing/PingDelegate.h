//
//  PingDelegate.h
//  StatusPing
//
//  Created by Diogo Gomes on 07/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SimplePing.h"

typedef NS_ENUM(NSInteger, AppState) {
    AppStatePingSent,
    AppStatePingReceived,
    AppStateTimeout,
    AppStateError
};

@interface PingDelegate : NSObject <SimplePingDelegate>

@property (nonatomic, strong, readwrite) SimplePing *   pinger;
@property (nonatomic, strong, readwrite) NSTimer *      sendTimer;
@property (atomic, readwrite) NSInteger unreceivedReplys;
@property (readwrite) float pingInterval;

@property (atomic, readwrite) AppState state;

- (NSString *)displayAddressForAddress:(NSData *) address;
- (void)startPingLoop: (NSString *)address interval: (float)seconds;

@end
