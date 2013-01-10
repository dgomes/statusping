//
//  DefaultsController.h
//  StatusPing
//
//  Created by Diogo Gomes on 06/01/13.
//  Copyright (c) 2013 diogogomes.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultsController : NSObject {
    NSUserDefaults *defaults;
}

- (void) setIPAddress:(NSString *)address;
- (NSString *) getIPAddress;
@end
