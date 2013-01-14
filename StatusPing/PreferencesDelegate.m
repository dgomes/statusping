//
//  PreferencesDelegate.m
//  StatusPing
//
//  Created by Diogo Gomes on 07/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import "PreferencesDelegate.h"
#import "AppDelegate.h"

@implementation PreferencesDelegate

@synthesize addressInput = _addressInput;

- (void) windowWillClose:(NSNotification *)notification {
    NSLog(@"Will close preferences and ping %@", [_addressInput stringValue]);
    
    [[NSUserDefaults standardUserDefaults] setObject:[_addressInput stringValue] forKey:@"StatusPing_address"];
    [[NSUserDefaults standardUserDefaults] setObject:[_intervalInput stringValue] forKey:@"StatusPing_interval"];
    
    [[[NSApp delegate] pingDelegate] startPingLoop:[_addressInput stringValue] interval:[[_intervalInput stringValue] floatValue ]];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    NSLog(@"Loading UserDefaults %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_address"]);
    [_addressInput setStringValue: [[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_address"]];
    [_intervalInput setStringValue: [[NSUserDefaults standardUserDefaults] stringForKey:@"StatusPing_interval"]];
}

@end
