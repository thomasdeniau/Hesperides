//
//  DFDictionaryParser.m
//  Hesperides
//
//  Created by Thomas Deniau on Mon Jun 07 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.

#import "DFDictionaryParser.h"
#import "MacPADSocket.h"
#import "NSFileManager-DFExtensions.h"

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
	if (!indexedVersion || ![lexiconVersion isEqualToString:indexedVersion])
		[self indexVersion:lexiconVersion withDoc:theDoc];
	
	index=[[defaults objectForKey:DFDictionaryIndex] copy];
	engIndex=[index objectAtIndex:DFEnglish];
	sindIndex = [index objectAtIndex:DFSindarin];
	
	dict=[[defaults objectForKey:DFDictionaryCache] copy];

	return theDoc;
}


-(void)dealloc
{
	[index release];
	[dict release];
	[pad release];
	
	xmlFreeDoc(doc);
	
	[super dealloc];
}

-(id)init
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
		
		// we don't check for errors... assume the dictionary and XSL are correct
	}
	return self;
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
		
		if (nItem && *nItem>'1') 
			// if we have already seen this word
			[[[ttSindIndex objectForKey:shortItemId] objectForKey:@"items"] addObject:itemId];
		else
			// this is the first time we see this word
			[ttSindIndex setObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSMutableArray arrayWithObject:itemId],shortItemId,NULL] 
															 forKeys:[NSArray arrayWithObjects:@"items",@"id",NULL]]
						  forKey:shortItemId];
		
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
				
				if ([ttEngIndex objectForKey:engId] != nil)
				{
					[[[ttEngIndex objectForKey:engId] objectForKey:@"items"] addObject:itemId];
				}
				else
				{
					[ttEngIndex setObject:[NSDictionary dictionaryWithObjectsAndKeys:
												[NSMutableArray arrayWithObject:itemId],@"items",engId,@"id",NULL]
								  forKey:engId];
				}
				
				xmlFree(xmlItem);
			}
		}
		
		xmlFreeDoc(nDoc);
	}
	
	NSArray *tEngIndex=[[[ttEngIndex allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" 
																															  ascending:YES 
																															   selector:@selector(caseInsensitiveCompare:)] autorelease]]] retain];
	NSArray *tSindIndex=[[[ttSindIndex allValues] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" 
																																ascending:YES 
																																 selector:@selector(caseInsensitiveCompare:)] autorelease]]] retain];
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:ttSindIndex,ttEngIndex,NULL] forKey:DFDictionaryCache];
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:tSindIndex,tEngIndex,NULL] forKey:DFDictionaryIndex];
	[[NSUserDefaults standardUserDefaults] setObject:version forKey:DFDictionaryIndexedVersion];
	
	//NSLog(@"Index Built : %d",time(NULL));
			
	return doc;
}


-(NSString *) lexiconVersion;
{
	return lexiconVersion;
}

-(xmlNodePtr) nodeForKey:(NSString *)key language:(DFLanguage)language;
{
	xmlNodePtr newnode=xmlNewNode(NULL,(const xmlChar*)"div0");
	
	NSArray *items=[[[dict objectAtIndex:language] objectForKey:key] objectForKey:@"items"];
	NSEnumerator *itemEnumerator=[items objectEnumerator];
	NSString *itemId;
	
	xmlXPathContextPtr context=xmlXPathNewContext(doc);
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

-(NSDictionary *)infoForKey:(NSString *)key language:(DFLanguage)language
{
	return [[dict objectAtIndex:language] objectForKey:key];
}

@end
