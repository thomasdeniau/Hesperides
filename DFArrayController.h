//
//  DFArrayController.h
//  Hesperides
//
//  Created by Thomas Deniau on Mon May 4 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.


#import <Foundation/Foundation.h>

extern NSString *DFUseRegexp;

@interface DFArrayController : NSArrayController {
	
    NSString *searchString;
	
}


- (void)search:(id)sender;


@end