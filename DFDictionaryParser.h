//
//  DFDictionaryParser.h
//  Hesperides
//
//  Created by Thomas Deniau on Mon Jun 07 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.

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

typedef enum _DFLanguage { DFSindarin, DFEnglish } DFLanguage;


@interface DFDictionaryParser : NSObject 
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
