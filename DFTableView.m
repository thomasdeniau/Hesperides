//
//  DFTableView.m
//  Hesperides
//
//  Created by Thomas Deniau on Sun Jun 20 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
// License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
// Hesperides comes with ABSOLUTELY NO WARRANTY.

#import "DFTableView.h"


@implementation DFTableView

-(void)awakeFromNib
{	
	const unichar arrows[2] = {NSUpArrowFunctionKey,NSDownArrowFunctionKey};
	set = [[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCharacters:arrows length:2]] retain];
}

-(void)dealloc
{
	[set release];
	[super dealloc];
}

- (void)keyUp:(NSEvent *)theEvent
{
	[super keyUp:theEvent];
	if ([[theEvent characters] rangeOfCharacterFromSet:set].location != NSNotFound)
		[[self target] performSelector:[self action]];
}


@end
