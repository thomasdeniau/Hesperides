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
	DFSearchMode useRegexp = [[[NSUserDefaults standardUserDefaults] objectForKey:DFSearchModeDefault] intValue];
	AGRegex *re=nil;
	
    if ((searchString == nil) || ([searchString isEqualToString:@""])) {
        return [super arrangeObjects:objects];   
    }

    NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
    NSEnumerator *objectsEnumerator = [objects objectEnumerator];
    id item;
	
	switch (useRegexp)
	{
		case DFSubstringRegexes:
			re=[AGRegex regexWithPattern:searchString];
			break;
		case DFWholeRegexes:
			re=[AGRegex regexWithPattern:[NSString stringWithFormat:@"^%@$",searchString]];
			break;
		default:
			re=nil;
	}
		
	BOOL selectWord;
	while (item = [objectsEnumerator nextObject]) 
	{
		if (useRegexp != DFPlainSearch)
		{
			selectWord = ([re findInString:[item valueForKeyPath:@"identifier"]] != nil);
		}
		else
		{
			selectWord = ([[item valueForKeyPath:@"identifier"] rangeOfString:searchString options:NSAnchoredSearch].location != NSNotFound);
		}
		if (selectWord)
		{
			[filteredObjects addObject:item];
		}
	}
	
    return [super arrangeObjects:filteredObjects];
}

@end