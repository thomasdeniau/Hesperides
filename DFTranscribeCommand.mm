//
//  DFTranscribeCommand.m
//  Hesperides
//
//  Created by Thomas Deniau on 27/11/04.
//  Copyright 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
// License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
// Hesperides comes with ABSOLUTELY NO WARRANTY.

#import "DFTranscribeCommand.h"
#import "DFController.h"
#import "DFWord.h"

@implementation DFTranscribeCommand

-(id)performDefaultImplementation
{
	NSDictionary *args=[self evaluatedArguments];
	[[DFController sharedInstance] transcribeWord:[args objectForKey:@"word"] 
									 fromLanguage:[DFWord languageFromCode:[[args objectForKey:@"from language"] intValue]]];
	return nil;
}

@end
