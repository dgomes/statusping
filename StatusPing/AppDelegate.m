//
//  AppDelegate.m
//  StatusPing
//
//  Created by Diogo Gomes on 02/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import "AppDelegate.h"
#include <netdb.h>


@implementation AppDelegate

@synthesize statusBar = _statusBar;
@synthesize addressInput = _addressInput;
@synthesize setButton = _setButton;
@synthesize ipaddress = _ipaddress;

@synthesize address = _address;
@synthesize pinger    = _pinger;
@synthesize sendTimer = _sendTimer;

- (void)dealloc
{
    [self->_pinger stop];
    [self->_sendTimer invalidate];
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
    
    NSLog(@"pinging %@", self.addressInput.description);
    
    // Send the first ping straight away.
    
    [self sendPing];
    
    // And start a timer to send the subsequent pings.
    
    assert(self.sendTimer == nil);
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
// A SimplePing delegate callback method.  We shut down our timer and the
// SimplePing object itself, which causes the runloop code to exit.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(error)
    NSLog(@"failed: %@", [self shortErrorFromError:error]);
    self.statusBar.title = @"⛔";
    [_ipaddress setTitle:[self shortErrorFromError:error]];
    
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
    NSLog(@"#%u sent", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber) );
    self.unreceivedReplys++;
    if(self.unreceivedReplys >5) {
        self.statusBar.title = @"⛔";
        [_ipaddress setTitle:@"Packets are being lost!"];
    }
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
// A SimplePing delegate callback method.  We just log the failure.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(packet)
#pragma unused(error)
    NSLog(@"#%u send failed: %@", (unsigned int) OSSwapBigToHostInt16(((const ICMPHeader *) [packet bytes])->sequenceNumber), [self shortErrorFromError:error]);
    self.statusBar.title = @"⛔";
    [_ipaddress setTitle:[self shortErrorFromError:error]];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
// A SimplePing delegate callback method.  We just log the reception of a ping response.
{
#pragma unused(pinger)
    assert(pinger == self.pinger);
#pragma unused(packet)
    NSLog(@"#%u received", (unsigned int) OSSwapBigToHostInt16([SimplePing icmpInPacket:packet]->sequenceNumber) );
    self.statusBar.title = @"⚡";
    self.unreceivedReplys--;
}

- (void)startPingLoop: (NSString *)address {
    if(_pinger != nil) {
        [_pinger stop];
        _pinger = nil;
        [_sendTimer invalidate];
        _sendTimer = nil;
    }
    [_ipaddress setTitle:_addressInput.stringValue];
    NSLog(@"%@", [_ipaddress title]);
    [_window performClose:self];
    self.unreceivedReplys = 0;
    [NSThread detachNewThreadSelector:@selector(runInBackground:) toTarget:self withObject:[_ipaddress title]];    
}

-(IBAction)onSetButton:(id)sender {
    [self startPingLoop:nil];
}

-(IBAction)onAddressEnter:(id)sender {
    [self startPingLoop:nil];    
}

-(IBAction)setNewAddress:(id)sender {
    NSLog(@"set new address");
	[_window makeKeyAndOrderFront:self];
    [_addressInput setStringValue:@"Lixo"];
}

- (void) awakeFromNib {
    NSLog(@"Loading");

    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    self.statusBar.title = @"⚡";
    
    // you can also set an image
    //self.statusBar.image =
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    
    [_window setReleasedWhenClosed:FALSE];
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

@end
