//
//  PingDelegate.m
//  StatusPing
//
//  Created by Diogo Gomes on 07/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import "PingDelegate.h"
#import "AppDelegate.h"
#include <sys/socket.h>
#include <netdb.h>

@implementation PingDelegate

@synthesize pinger    = _pinger;
@synthesize sendTimer = _sendTimer;

- (void)dealloc
{
    [self->_pinger stop];
    [self->_sendTimer invalidate];
}

- (NSString *)displayAddressForAddress:(NSData *)address
// Returns a dotted decimal string for the specified address (a (struct sockaddr)
// within the address NSData).
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo([address bytes], (socklen_t) [address length], hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = [NSString stringWithCString:hostStr encoding:NSASCIIStringEncoding];
            assert(result != nil);
        }
    }
    
    return result;
}

- (NSString *)shortErrorFromError:(NSError *)error
// Given an NSError, returns a short error string that we can print, handling
// some special cases along the way.
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    assert(error != nil);
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ( [[error domain] isEqual:(NSString *)kCFErrorDomainCFNetwork] && ([error code] == kCFHostErrorUnknown) ) {
        failureNum = [[error userInfo] objectForKey:(id)kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = [failureNum intValue];
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = [NSString stringWithUTF8String:failureStr];
                    assert(result != nil);
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    
    if (result == nil) {
        result = [error localizedFailureReason];
    }
    if (result == nil) {
        result = [error localizedDescription];
    }
    if (result == nil) {
        result = [error description];
    }
    assert(result != nil);
    return result;
}

- (void)sendPing
// Called to send a ping, both directly (as soon as the SimplePing object starts up)
// and via a timer (to continue sending pings periodically).
{
    assert(self.pinger != nil);
    [self.pinger sendPingWithData:nil];
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
// A SimplePing delegate callback method.  We respond to the startup by sending a
// ping immediately and starting a timer to continue sending them every second.
{
    assert(pinger == self.pinger);
    assert(address != nil);
        
    NSLog(@"pinging %@", [self displayAddressForAddress: address]);
    
    // Send the first ping straight away.
    self.state = AppStateError;
    [self sendPing];
    
    // And start a timer to send the subsequent pings.
    
    NSLog(@"Interval: %f", self.pingInterval);
    
    assert(self.sendTimer == nil);
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:self.pingInterval target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
// A SimplePing delegate callback method.  We shut down our timer and the
// SimplePing object itself, which causes the runloop code to exit.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(error)
    NSLog(@"failed: %@", [self shortErrorFromError:error]);
    
    if(self.state != AppStateError) {
        [[NSApp delegate] setInfo:[self shortErrorFromError:error] icon:@"⛔"];
        self.state = AppStateError;
    }
    // No need to call -stop.  The pinger will stop itself in this case.
    // We do however want to nil out pinger so that the runloop stops.
    
    self.pinger = nil;
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the send.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(packet)
#ifdef DEBUG
    NSLog(@"#%u sent", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber) );
#endif
    
    if(self.state == AppStateTimeout) {
        self.state = AppStateTimeout;
    } else if(self.state == AppStateError) {
        self.state = AppStateError;
    }else if(self.state == AppStatePingSent) {
        [[NSApp delegate] setInfo:@"Packets are being lost!" icon:@"⛔"];
        self.state = AppStateTimeout;
    } else
        self.state = AppStatePingSent;
    
    return;
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
// A SimplePing delegate callback method.  We just log the failure.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(packet)
#pragma unused(error)
    NSLog(@"#%u send failed: %@", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber), [self shortErrorFromError:error]);
    
    if(self.state != AppStateError) {
        [[NSApp delegate] setInfo:[self shortErrorFromError:error] icon:@"⛔"];
        self.state = AppStateError;
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the reception of a ping response.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(packet)
#ifdef DEBUG
    NSLog(@"#%u received", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber) );
#endif
    
    if(self.state != AppStatePingSent) {
        [[NSApp delegate] setInfo:[self displayAddressForAddress:pinger.hostAddress] icon:@"🌍"];
    }
    self.state = AppStatePingReceived;
}

- (void)startPingLoop: (NSString *)address {
    [self startPingLoop:address interval:1];
}

- (void)startPingLoop: (NSString *)address interval: (float) seconds {
    NSLog(@"startPingLoop: %@", address);
    if(address == nil) {
        NSLog(@"nil address to ping!!!!!!!");
        return;
    }
    self.pingInterval = seconds;
    
    if(_pinger != nil) {
        [_pinger stop];
        _pinger = nil;
        [_sendTimer invalidate];
        _sendTimer = nil;
    }
    
    [[NSApp delegate] setInfo:address icon:@"🌍"];
    
    [NSThread detachNewThreadSelector:@selector(runInBackground:) toTarget:self withObject:address];
}

- (void) runInBackground:(id)arg
{
    NSLog(@"In the background %@", (NSString *) arg);
    
    self.pinger = [SimplePing simplePingWithHostName:(NSString *) arg];
    assert(self.pinger != nil);
    
    self.pinger.delegate = self;
    [self.pinger start];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    } while (self.pinger != nil);
    
    NSLog(@"Leaving the background %@", (NSString *) arg);
}

@end
