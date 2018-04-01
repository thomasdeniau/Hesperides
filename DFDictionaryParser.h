//
//  DFDictionaryParser.h
//  Hesperides
//
//  Created by Thomas Deniau on Mon Jun 07 2004.

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


#import <Foundation/Foundation.h>

#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>
#include <libxml/parserInternals.h>

@class MacPADSocket;
@class DFWord;

typedef enum _DFLanguage { DFSindarin, DFEnglish, DFUnknown } DFLanguage;


@interface DFDictionaryParser : NSObject <NSXMLParserDelegate> 
{	
	NSArray *index;
	NSArray *engIndex;
	NSArray *sindIndex;
	
	NSArray *dict;	
	MacPADSocket *pad;
	xmlDocPtr doc;
	NSString *lexiconVersion;
	
	xsltStylesheetPtr xslt;
}

+(DFDictionaryParser *)sharedParser;

-(NSString *) lexiconVersion;
-(xmlDocPtr) indexVersion:(NSString *)version withDoc:(xmlDocPtr)theDoc;
-(xmlDocPtr) parsePath:(NSString *)path;
-(xmlDocPtr) dictionary;
-(xsltStylesheetPtr)transformStylesheet;

-(DFWord *)word:(NSString *)key language:(DFLanguage)language;
-(DFWord *)englishWord:(NSString *)key;
-(DFWord *)sindarinWord:(NSString *)key;

@end
