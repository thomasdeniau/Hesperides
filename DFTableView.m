//
//  DFTableView.m
//  Hesperides
//
//  Created by Thomas Deniau on Sun Jun 20 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

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
