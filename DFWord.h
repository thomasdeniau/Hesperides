//
//  DFWord.h
//  Hesperides
//
//  Created by Thomas Deniau on 13/11/04.
//  Copyright 2004 Nousoft. All rights reserved.
//

// Copyright (c) 2004-2018, Thomas Deniau
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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
