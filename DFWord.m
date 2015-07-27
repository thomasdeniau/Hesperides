//
//  DFWord.m
//  Hesperides
//
//  Created by Thomas Deniau on 13/11/04.
//  Copyright 2004 Nousoft. All rights reserved.
//

// Copyright (c) 2004-2015, Thomas Deniau
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

#import "DFWord.h"
#import "DFDictionaryParser.h"
#import "DFLexiconAccessor.h"
#import <AGRegex/AGRegex.h>
#import "DFController.h"

NSDictionary *substitutions;

@implementation DFWord

+(void)initialize
{
	// same substitutions for all instances...
	substitutions = [[NSDictionary alloc] initWithObjects:
		[NSArray arrayWithObjects:
			[AGRegex regexWithPattern:@"\\(\\s+" options:AGRegexMultiline],
			[AGRegex regexWithPattern:@"\\s+\\)" options:AGRegexMultiline],
			[AGRegex regexWithPattern:@"\\s+," options:AGRegexMultiline],NULL]
												  forKeys:[NSArray arrayWithObjects:@"(",@")",@",",NULL]];
}

-(id)initWithIdentifier:(NSString*)anIdentifier language:(DFLanguage)aLang;
{
	if (self = [super init])
	{
		identifier = [anIdentifier copy];
		language = aLang;
		meanings = [[NSMutableArray alloc] initWithCapacity:4];
		translations = [[NSMutableArray alloc] initWithCapacity:10];
	}
	return self;
}

+(id)wordWithIdentifier:(NSString*)anIdentifier language:(DFLanguage)aLang;
{
	return [[[self alloc] initWithIdentifier:anIdentifier language:aLang] autorelease];
}

- (id) initWithCoder:(NSCoder *) coder {
	if (! [coder allowsKeyedCoding]) 
		[NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];
		
	if (self = [self initWithIdentifier:[coder decodeObjectForKey:@"DFIdentifier"] 
							   language:[coder decodeIntForKey:@"DFLanguage"]])
	{
		[meanings release];
		[translations release];
		
		meanings = [[coder decodeObjectForKey:@"DFMeaning"] copy];
		translations = [[coder decodeObjectForKey:@"DFTranslations"] copy];
	}
		
	return self;
}


-(void)dealloc
{
	[meanings release];
	[translations release];
	[identifier release];
	[super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)coder {
	if( [coder allowsKeyedCoding] ) 
	{
		[coder encodeObject:identifier forKey:@"DFIdentifier"];
		[coder encodeObject:meanings forKey:@"DFMeaning"];
		[coder encodeObject:translations forKey:@"DFTranslations"];
		[coder encodeInt:language forKey:@"DFLanguage"];
	} 
	else [NSException raise:NSInvalidArchiveOperationException format:@"Only supports NSKeyedArchiver coders"];
}

-(NSString *)identifier;
{
	return identifier;
}

-(void)addMeaning:(NSString *)meaning;
{
	[meanings addObject:[meaning copy]];
}

-(void)addTranslation:(NSString *)translation
{
	[translations addObject:[translation copy]];
}

-(NSArray *)translations
{
	return translations;
}

-(xmlNodePtr) node;
{
	xmlNodePtr newnode=xmlNewNode(NULL,(const xmlChar*)"div0");
	
	NSEnumerator *itemEnumerator=[meanings objectEnumerator];
	NSString *itemId;
	
	xmlXPathContextPtr context=xmlXPathNewContext([[DFDictionaryParser sharedParser] dictionary]);
	xmlNodeSetPtr found;
	
	while (itemId=[itemEnumerator nextObject])
	{
		char *query;
		asprintf(&query,"//entry[@id='%s']",[itemId UTF8String]);
		found = xmlXPathEvalExpression((xmlChar *)query,context)->nodesetval;
			
		if (found->nodeNr > 0) xmlAddChild(newnode,xmlCopyNode(found->nodeTab[0],1));
		free(query);
	}
	
	xmlXPathFreeContext(context);
	
	return newnode;
}

-(NSString *)xmlString
{
	xmlBufferPtr buffer=xmlBufferCreate();
	xmlNodeDump(buffer,[[DFDictionaryParser sharedParser] dictionary],[self node],0,1);
	
	NSString *newString=[[NSString alloc] initWithBytes:(const char*)xmlBufferContent(buffer)
													   length:xmlBufferLength(buffer)
													 encoding:NSISOLatin1StringEncoding];	
	xmlBufferFree(buffer);
	return [newString autorelease];
}

-(NSArray *)xmlMeanings
{
	NSMutableArray *result=[NSMutableArray array];
		
	NSEnumerator *itemEnumerator=[meanings objectEnumerator];
	NSString *itemId;
	
	xmlXPathContextPtr context=xmlXPathNewContext([[DFDictionaryParser sharedParser] dictionary]);
	xmlNodeSetPtr found;
	
	while (itemId=[itemEnumerator nextObject])
	{
		char *query;
		asprintf(&query,"//entry[@id='%s']",[itemId UTF8String]);
		found = xmlXPathEvalExpression((xmlChar *)query,context)->nodesetval;
			
		if (found->nodeNr > 0)
		{
			xmlBufferPtr buffer=xmlBufferCreate();				
			xmlNodeDump(buffer,[[DFDictionaryParser sharedParser] dictionary],found->nodeTab[0],0,1);
			
			[result addObject:[[[NSString alloc] initWithBytes:(const char*)xmlBufferContent(buffer)
														  length:xmlBufferLength(buffer)
														encoding:NSISOLatin1StringEncoding] autorelease]];	
			xmlBufferFree(buffer);
		}
		
		free(query);
	}
	
	xmlXPathFreeContext(context);
	
	return result;
}

-(NSString *)htmlString;
{
	const char *params[3] = {"print", "'no'", NULL};
	
	xmlDocPtr nDoc=xmlNewDoc((xmlChar*)"1.0");
	xmlDocPtr result;
	xmlChar *resCharTab=NULL;
	
	NSString *resString;
	
	int resSize=0;
		
	xmlDocSetRootElement(nDoc, [self node]);
	// we create a new document with only a div0 node containing relevant entries
	// to pass it to xslt
	
	result = xsltApplyStylesheet([[DFDictionaryParser sharedParser] transformStylesheet], nDoc, params);
	xmlFreeDoc(nDoc);
	
	xsltSaveResultToString(&resCharTab, &resSize, result, [[DFDictionaryParser sharedParser] transformStylesheet]);
	resString = [[[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:resCharTab length:resSize] encoding:NSISOLatin1StringEncoding] autorelease];

	NSString *key;
	NSEnumerator *anEnumerator = [substitutions keyEnumerator];
	
	while (key = [anEnumerator nextObject])
	{
		resString = [[substitutions objectForKey:key] replaceWithString:key inString:resString];
	}
	
	return resString;
}

-(NSScriptObjectSpecifier *)objectSpecifier
{
	DFLexiconAccessor * parent = (language==DFSindarin)?[[DFController sharedInstance] sindarinAccessor] : [[DFController sharedInstance] englishAccessor];
	NSScriptObjectSpecifier * parentSpecifier = [parent objectSpecifier];
	
	NSNameSpecifier *spec= [[[NSNameSpecifier alloc] initWithContainerClassDescription:[parentSpecifier keyClassDescription]
																	containerSpecifier: parentSpecifier
																				   key: @"words" 
																				  name:identifier] autorelease];
	//NSLog(@"%@",spec);
	return spec;
}

-(int)language
{
	switch(language)
	{
		case DFSindarin: return 'DFls'; break;
		case DFEnglish: return 'DFle'; break;
		case DFUnknown: return 'DFlu'; break;
	}
	return 0;
}

+(DFLanguage)languageFromCode:(int)code
{
	switch(code)
	{
		case 'DFls': return DFSindarin;
		case 'DFle': return DFEnglish;
		default: return DFUnknown;
	}
}

@end
