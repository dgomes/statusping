//
//  AppDelegate.h
//  StatusPing
//
//  Created by Diogo Gomes on 02/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PingDelegate.h"
#import "PreferencesDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusBar;

@property (assign) IBOutlet NSWindow *preferencesWindow;
@property (strong) IBOutlet NSMenuItem *statusInfo;

@property PreferencesDelegate *preferences;
@property PingDelegate *pingDelegate;

- (void)setInfo:(NSString *)info icon:(NSString *) unicodestr;

@end




