//
//  DFLexiconDownloader.h
//  Hesperides
//
//  Created by Thomas Deniau on Wed May 05 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.

#import <Cocoa/Cocoa.h>
#include <libxml/parser.h>

@class DFDictionaryParser;

@interface DFLexiconDownloader : NSWindowController
{
    IBOutlet id progressBar;
    IBOutlet id statusText;
	
	unsigned int expected;
	
	NSString *version;
	NSString *filename;
	DFDictionaryParser *parser;
}

-(id)initWithVersion:(NSString *)v dictionaryParser:(DFDictionaryParser*)aParser;
-(NSString *)downloadPath;

@end
