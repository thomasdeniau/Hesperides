//
//  DFArrayController.m
//  Hesperides
//
//  Created by Thomas Deniau on Mon May 4 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.


#import "DFArrayController.h"

#import <Foundation/NSKeyValueObserving.h>
#import <AGRegex/AGRegex.h>

@implementation DFArrayController

-(void)setSearchString:(NSString*)str
{
	if (searchString != str)
	{
		[searchString release];
		searchString=[str retain];
	}
}

- (void)search:(id)sender {
	[self setSearchString:[sender stringValue]];
    [self rearrangeObjects];    	
}

- (NSArray *)arrangeObjects:(NSArray *)objects 
{
	BOOL useRegexp = [[[NSUserDefaults standardUserDefaults] objectForKey:DFUseRegexp] boolValue];
	AGRegex *re=nil;
	
    if ((searchString == nil) || ([searchString isEqualToString:@""])) {
        return [super arrangeObjects:objects];   
    }

    NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    NSEnumerator *objectsEnumerator = [objects objectEnumerator];
    id item;
	
	if (! useRegexp)
	{	
		while (item = [objectsEnumerator nextObject]) 
		{
			if ([[item valueForKeyPath:@"id"] rangeOfString:searchString options:NSAnchoredSearch].location != NSNotFound) 
			{
				[filteredObjects addObject:item];
			}
		}
	}
	else
	{
		re=[AGRegex regexWithPattern:searchString];
		while (item = [objectsEnumerator nextObject]) 
		{
			if ([re findInString:[item valueForKeyPath:@"id"]] != nil) 
			{
				[filteredObjects addObject:item];
			}
		}
	}
	
    return [super arrangeObjects:filteredObjects];
}
@end