//
//  PreferencesDelegate.h
//  StatusPing
//
//  Created by Diogo Gomes on 07/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesDelegate : NSObject <NSWindowDelegate>

@property (strong, retain) IBOutlet NSTextField *addressInput;
@property (strong, retain) IBOutlet NSTextField *intervalInput;

@end
