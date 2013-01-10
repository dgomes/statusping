//
//  DefaultsController.m
//  StatusPing
//
//  Created by Diogo Gomes on 06/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import "DefaultsController.h"

@implementation DefaultsController

- (id)init {
	
	self = [super init];
	
    if (self != nil) {
		defaults = [NSUserDefaults standardUserDefaults];
    }
	
    return self;
	
}
- (void) setIPAddress:(NSString *)IPAddress {
    [defaults setObject:IPAddress forKey:@"StatusPing_Address"];
    
}

- (NSString *) getIPAddress {
    return [defaults stringForKey:@"StatusPing_Address"];
}
@end
