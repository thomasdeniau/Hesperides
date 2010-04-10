//
//  DFLexiconAccessor.h
//  Hesperides
//
//  Created by Thomas Deniau on 10/04/10.
//  Copyright 2010 Nousoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DFDictionaryParser.h"

@interface DFLexiconAccessor : NSObject {
	DFLanguage language;
	DFDictionaryParser * dictionary;
}

@property (assign) DFLanguage language;
@property (retain) DFDictionaryParser * dictionary;

@end
