//
//  AppDelegate.h
//  StatusPing
//
//  Created by Diogo Gomes on 02/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "SimplePing.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, SimplePingDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet NSButton *setButton;
@property (strong, retain) IBOutlet NSTextField *addressInput;
@property (strong) IBOutlet NSMenuItem *ipaddress;
@property (strong, nonatomic) NSStatusItem *statusBar;

@property (strong, atomic) NSString *address;

@property (nonatomic, strong, readwrite) SimplePing *   pinger;
@property (nonatomic, strong, readwrite) NSTimer *      sendTimer;
@property (atomic, readwrite) NSInteger unreceivedReplys;

@end
