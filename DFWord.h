//
//  DFWord.h
//  Hesperides
//
//  Created by Thomas Deniau on 13/11/04.
//  Copyright 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public 
// License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
// Hesperides comes with ABSOLUTELY NO WARRANTY.

#import <Cocoa/Cocoa.h>
#import "DFDictionaryParser.h"

@interface DFWord : NSObject {
	NSString *identifier;
	NSMutableArray *meanings;
	NSMutableArray *translations;
	
	DFLanguage language;
}

-(id)initWithIdentifier:(NSString*)anIdentifier language:(DFLanguage)aLang;
+(id)wordWithIdentifier:(NSString*)anIdentifier language:(DFLanguage)aLang;

-(NSString *)xmlString;
-(NSArray *)xmlMeanings;
-(NSString *)htmlString;
-(NSArray *) translations;

-(NSString *)identifier;
-(void)addMeaning:(NSString *)meaning;
-(void)addTranslation:(NSString *)translation;

-(int)language;
+(DFLanguage)languageFromCode:(int)code;

@end
