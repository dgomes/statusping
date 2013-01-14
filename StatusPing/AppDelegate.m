//
//  AppDelegate.m
//  StatusPing
//
//  Created by Diogo Gomes on 02/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusBar = _statusBar;
@synthesize statusInfo = _statusInfo;
@synthesize pingDelegate = _pingDelegate;
@synthesize preferences = _preferences;
@synthesize preferencesWindow = _preferencesWindow;


- (id)init {
	
	self = [super init];
	
    if (self != nil)
    {
        _preferences = [[PreferencesDelegate alloc] init];
        _pingDelegate = [[PingDelegate alloc] init];
    }
    return self;
}


- (void) setInfo:(NSString *)info icon:(NSString *)unicodestr
{
    NSLog(@"setInfo: %@", info);
    [_statusBar setTitle: unicodestr];
    [_statusInfo setTitle: info];
}


-(IBAction)savePreferences:(id)sender {
    [_preferencesWindow close];
}

-(IBAction)openPreferences:(id)sender {
    NSLog(@"open prefs");
    [NSApp activateIgnoringOtherApps:YES];
    [_preferencesWindow center];
	[_preferencesWindow makeKeyAndOrderFront:self];

}

- (void) awakeFromNib {
    NSLog(@"Loading");

    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    self.statusBar.title = @"🌍";
    
    // you can also set an image
    //self.statusBar.image =
    
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;

    [_preferencesWindow setReleasedWhenClosed:FALSE];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL openprefs = FALSE;
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_address"]==nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@"8.8.8.8" forKey:@"StatusPing_address"];
        openprefs = TRUE;
    }

    if([[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_interval"]==nil)
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"StatusPing_interval"];

    if(openprefs) {
        // wait for user preferences
        [self openPreferences:nil];
    } else {
        //Start pinging
        [[[NSApp delegate] pingDelegate]
            startPingLoop:[[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_address"]
            interval:[[[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_interval"] floatValue]];
    }
}

@end
