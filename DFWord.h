//
//  DFWord.h
//  Hesperides
//
//  Created by Thomas Deniau on 13/11/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

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
-(NSArray *)xmlDescriptions;
-(NSString *)htmlString;
-(NSArray *) translations;

-(NSString *)identifier;
-(void)addMeaning:(NSString *)meaning;
-(void)addTranslation:(NSString *)translation;

-(int)language;

@end
