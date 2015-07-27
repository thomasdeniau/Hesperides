//
//  DFDictionaryParser.m
//  Hesperides
//
//  Created by Thomas Deniau on Mon Jun 07 2004.


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


#import "DFDictionaryParser.h"
#import "MacPADSocket.h"
#import "NSFileManager-DFExtensions.h"
#import "DFWord.h"
#import "sampa.h"

NSString *DFDictionaryIndexedVersion=@"DFDictionaryIndexedVersion";
NSString *DFDictionaryCache = @"DFDictionaryCache";
NSString *DFDictionaryIndex = @"DFDictionaryIndex";

xmlExternalEntityLoader defaultLoader = NULL;

xmlParserInputPtr xmlMyExternalEntityLoader(const char *URL, const char *ID, xmlParserCtxtPtr ctxt) 
{
	NSString *path = [NSString stringWithUTF8String:URL];
	
	if ([[path lastPathComponent] isEqual:@"xmldict.dtd"])
	{
		return defaultLoader([[[NSBundle mainBundle] pathForResource:@"xmldict" ofType:@"dtd"] UTF8String],ID,ctxt);
	}
	
	else return defaultLoader(URL,ID,ctxt);
	
}

static id sharedParser=nil;

@implementation DFDictionaryParser

#pragma mark -- Version extraction & comparison --

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqual:@"edition"])
	{
		lexiconVersion = [[attributeDict objectForKey:@"n"] retain];
		[parser abortParsing];
	}
}

-(NSString *)mostRecent:(NSArray *)versions
{
	if (![versions count]) return nil;
	
	unsigned int i;
	int maxI=0;
	
	for (i=1;i<[versions count];i++)
	{
		if ([pad compareVersion:[versions objectAtIndex:maxI] toVersion:[versions objectAtIndex:i]]==NSOrderedDescending)
			maxI=i;
	}
	
	return [versions objectAtIndex:maxI];
}

-(xmlDocPtr)parsePath:(NSString *)path
{
	xmlSubstituteEntitiesDefault(1);
	xmlLoadExtDtdDefaultValue = 1;
	xmlSetExternalEntityLoader(xmlMyExternalEntityLoader);
	
	return xmlParseFile([path UTF8String]);
}

-(xmlDocPtr)mostRecentDict:(NSArray *)dicts
{
	NSString *path;
	NSEnumerator *e=[dicts objectEnumerator]; 
	NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithCapacity:[dicts count]];
	
	while (path=[e nextObject])
	{
		NSXMLParser *parser=[[NSXMLParser alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];
		// we're not gonna parse ALL the dict just to get the version !!! so NSXMLParser, abort as soon as possible
		[parser setDelegate:self];
		[parser parse]; // just to get version
		if (lexiconVersion)
		{
			[dic setObject:path forKey:lexiconVersion];
			[lexiconVersion release];
		}
	}
	
	lexiconVersion = [self mostRecent:[dic allKeys]];
	path = [dic objectForKey:lexiconVersion];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (! path) return NULL;
	
	xmlDocPtr theDoc = [self parsePath:path];
	
	NSString *indexedVersion = [defaults objectForKey:DFDictionaryIndexedVersion];
	if (!indexedVersion || ![lexiconVersion isEqualToString:indexedVersion] 
		|| ! [[defaults objectForKey:DFDictionaryCache] isKindOfClass:[NSData class]]
		// old version of Hesperides -> NSDictionary instead of DFWord
		)
		[self indexVersion:lexiconVersion withDoc:theDoc];
	
	index=[[defaults objectForKey:DFDictionaryIndex] copy];
	engIndex=[index objectAtIndex:DFEnglish];
	sindIndex = [index objectAtIndex:DFSindarin];
	
	dict=[[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:DFDictionaryCache]] retain];

	return theDoc;
}


-(void)dealloc
{
	[index release];
	[dict release];
	[pad release];
	
	xmlFreeDoc(doc);
	
	xsltFreeStylesheet(xslt);
	xsltCleanupGlobals();
	xmlCleanupParser();

	[super dealloc];
}

+(id)sharedParser
{
	if (! sharedParser) return [[self alloc] init];
	else return sharedParser;
}

-(id)init
{
	if (! sharedParser)
	{
		if (self = [super init])
		{
		
			NSFileManager *fm=[NSFileManager defaultManager];
			
			pad = [[MacPADSocket alloc] init];
			
#pragma mark -- Parse Dic --
			
			defaultLoader = xmlGetExternalEntityLoader();
			
			NSArray *dicts= [[[NSBundle mainBundle] pathsForResourcesOfType:@"xml" inDirectory:nil] arrayByAddingObjectsFromArray:
				[fm filesWithPathExtension:@"xml" inDomain:kApplicationSupportFolderType subFolder:@"Hesperides"]];
			
			//NSLog(@"Loading index : %d",time(NULL));
			doc=[self mostRecentDict:dicts];		
			//NSLog(@"Index loaded : %d",time(NULL));

			xsltRegisterSampaModule();
									
			NSString *xslPath=[[NSBundle mainBundle] pathForResource:@"entry" ofType:@"xsl"];
			xslt=xsltParseStylesheetFile((xmlChar*)[xslPath UTF8String]);

			// we don't check for errors... assume the dictionary and XSL are correct
		}
		sharedParser = self;
	}
	else [self dealloc];
	
	return sharedParser;
}

-(xmlDocPtr) indexVersion:(NSString *)version withDoc:(xmlDocPtr)theDoc;
{
	//NSLog(@"Building index : %d",time(NULL));
	
	xmlChar *entryPath = (xmlChar *) "//entry";
	xmlChar *transPath = (xmlChar *) "//sense/trans[@lang = 'en']/def/index";
			
	xmlNodeSetPtr items;
	xmlXPathContextPtr context;
	int i;
			
	context = xmlXPathNewContext(theDoc);
	items = xmlXPathEvalExpression(entryPath,context)->nodesetval;
	xmlXPathFreeContext(context);
			
	NSMutableDictionary *ttSindIndex=[[NSMutableDictionary alloc] initWithCapacity:items->nodeNr];
	NSMutableDictionary *ttEngIndex=[[NSMutableDictionary alloc] initWithCapacity:items->nodeNr]; 
			
	NSMutableArray *tEngArray = [[NSMutableArray alloc] initWithCapacity:items->nodeNr];
	NSMutableArray *tSindArray = [[NSMutableArray alloc] initWithCapacity:items->nodeNr];
	
	
	for (i=0; i<items->nodeNr;i++)
	{
		xmlNodePtr item=items->nodeTab[i];
		xmlDocPtr nDoc=xmlNewDoc((const xmlChar*)"1.0");
		xmlNodeSetPtr trans;
		int j;
		
		xmlChar* xmlItem = xmlGetProp(item,(const xmlChar*)"id");
		xmlChar *nItem = xmlGetProp(item,(const xmlChar*)"n");
		
		NSString* itemId=[NSString stringWithUTF8String:(const char*)xmlItem], *shortItemId=itemId;
		
		// strip out .1, .2, etc.
		if (nItem && [itemId length]>2 && [itemId characterAtIndex:[itemId length]-2]=='.') 
			shortItemId=[itemId substringToIndex:[itemId length]-2];
		
		
		if (!nItem ||  (*nItem=='1'))
		{
			// not seen word yet
			[ttSindIndex setObject:[DFWord wordWithIdentifier:shortItemId language:DFSindarin] forKey:shortItemId]; 
			[tSindArray addObject:[NSDictionary dictionaryWithObject:shortItemId forKey:@"identifier"]];
		}
		
		[[ttSindIndex objectForKey:shortItemId] addMeaning:itemId];
		
		xmlFree(xmlItem);
		xmlFree(nItem);
		
#pragma mark -- English Index --
				
		// we now have to check for english translations and fill engIndex with references
		// to the relevant sindarin words
		
		// execute xpath to locate translations
		xmlDocSetRootElement(nDoc, xmlCopyNode(item,1));
		context=xmlXPathNewContext(nDoc);
		trans = xmlXPathEvalExpression(transPath,context)->nodesetval;
		xmlXPathFreeContext(context);
		
		if (trans)
		{
			for(j=0;j<trans->nodeNr;j++)
			{
				xmlNodePtr eItem = trans->nodeTab[j];
				xmlItem = xmlGetProp(eItem,(const xmlChar*)"level1"); // xmlItem is the xmlChar* containing the translation
				NSString *engId=[NSString stringWithUTF8String:(const char*)xmlItem];
				
				if (! [ttEngIndex objectForKey:engId])
				{
					[ttEngIndex setObject:[DFWord wordWithIdentifier:engId language:DFEnglish] forKey:engId];
					[tEngArray addObject:[NSDictionary dictionaryWithObject:engId forKey:@"identifier"]];
				}

				[[ttEngIndex objectForKey:engId] addMeaning:itemId];
				[[ttEngIndex objectForKey:engId] addTranslation:shortItemId];
				[[ttSindIndex objectForKey:shortItemId] addTranslation:engId];
				
				xmlFree(xmlItem);
			}
		}
		
		xmlFreeDoc(nDoc);
	}
		
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObjects:ttSindIndex,ttEngIndex,NULL]] forKey:DFDictionaryCache];
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:tSindArray,tEngArray,NULL] forKey:DFDictionaryIndex];
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:DFDictionaryIndexedVersion];
	
	[tEngArray release];
	[tSindArray release];
	
	[ttSindIndex release];
	[ttEngIndex release];
	
	//NSLog(@"Index Built : %d",time(NULL));
			
	return doc;
}


-(NSString *) lexiconVersion;
{
	return lexiconVersion;
}


-(xmlDocPtr) dictionary;
{
	return doc;
}

-(xsltStylesheetPtr)transformStylesheet
{
	return xslt;
}


-(DFWord *)word:(NSString *)key language:(DFLanguage)language
{
	return [[dict objectAtIndex:language] objectForKey:key];
}

-(DFWord *)englishWord:(NSString *)key
{
	return [self word:key language:DFEnglish];
}

-(DFWord *)sindarinWord:(NSString *)key
{
	return [self word:key language:DFSindarin];
}

@end
