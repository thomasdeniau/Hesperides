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
	
	lexiconVersion = [[self mostRecent:[dic allKeys]] retain];
	path=[dic objectForKey:lexiconVersion];
		NSLog(@"%d",time(NULL));
	if (! path) return NULL;
	else return xmlParseFile([path UTF8String]);
}


-(void)dealloc
{
	[sindarinDict release];
	[engDict release];
	[sindIndex release];
	[engIndex release];
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
		
		xmlChar *entryPath = (xmlChar *) "//entry";
		xmlChar *transPath = (xmlChar *) "//sense/trans[@lang = 'en']/def/index";
				
		xmlNodeSetPtr items;
		xmlXPathContextPtr context;
		int i;
		
		NSArray *dicts= [[[NSBundle mainBundle] pathsForResourcesOfType:@"xml" inDirectory:nil] arrayByAddingObjectsFromArray:
			[fm filesWithPathExtension:@"xml" inDomain:kApplicationSupportFolderType subFolder:@"Hesperides"]];
		
		defaultLoader = xmlGetExternalEntityLoader();
		xmlSubstituteEntitiesDefault(1);
		xmlLoadExtDtdDefaultValue = 1;
		xmlSetExternalEntityLoader(xmlMyExternalEntityLoader);
		
		doc=[self mostRecentDict:dicts];
		
			NSLog(@"%d",time(NULL));
			
		// we don't check for errors... assume the dictionary and XSL are correct
		
#pragma mark -- Tree generation --
		
		context = xmlXPathNewContext(doc);
		items = xmlXPathEvalExpression(entryPath,context)->nodesetval;
		xmlXPathFreeContext(context);
		
		sindarinDict = [[NSMutableDictionary alloc] initWithCapacity:items->nodeNr];
		engDict = [[NSMutableDictionary alloc] initWithCapacity:items->nodeNr*2]; // avg 2 translations/word
	
		sindIndex=[[NSMutableArray alloc] initWithCapacity:items->nodeNr];
		NSMutableArray *tEngIndex=[[NSMutableArray alloc] initWithCapacity:items->nodeNr];
	
		for (i=0; i<items->nodeNr;i++)
		{
			xmlNodePtr item=items->nodeTab[i];
			xmlDocPtr nDoc=xmlNewDoc((const xmlChar*)"1.0");
			xmlNodeSetPtr trans;
			int j;
			
			item->next = NULL;
			item->prev=NULL;
			// isolate this node
			
			xmlChar* xmlItem = xmlGetProp(item,(const xmlChar*)"id");
			xmlChar *nItem = xmlGetProp(item,(const xmlChar*)"n");
			
			NSString* itemId=[NSString stringWithUTF8String:(const char*)xmlItem];
			
			// strip out .1, .2, etc.
			if (nItem && [itemId length]>2 && [itemId characterAtIndex:[itemId length]-2]=='.') 
				itemId=[itemId substringToIndex:[itemId length]-2];
			
			
			if (nItem && *nItem>'1') 
				// if we have already seen this word
				xmlAddChild((xmlNodePtr)[[sindarinDict objectForKey:itemId] bytes],item);
			// just add this meaning of the word to an existing div0 node stored in sindarinDict
			else
				// this is the first time we see this word
			{
				xmlNodePtr newnode=xmlNewNode(NULL,(const xmlChar*)"div0");
				xmlAddChild(newnode,item);
				[sindIndex addObject:[NSDictionary dictionaryWithObject:itemId forKey:@"id"]];
				[sindarinDict setObject:[NSData dataWithBytesNoCopy:newnode length:sizeof(newnode)] forKey:itemId];
			}
			
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

					if ([engDict objectForKey:engId] != nil)
					{
						xmlAddChild((xmlNodePtr)[[engDict objectForKey:engId] bytes],xmlCopyNode(item,1));
					}
					else
					{
						xmlNodePtr newnode=xmlNewNode(NULL,(const xmlChar*)"div0");
						xmlAddChild(newnode,xmlCopyNode(item,1));
						[tEngIndex addObject:[NSDictionary dictionaryWithObject:engId forKey:@"id"]];
						[engDict setObject:[NSData dataWithBytesNoCopy:newnode length:sizeof(newnode)] forKey:engId];
					}

					xmlFree(xmlItem);
				}
			}
			
			xmlFreeDoc(nDoc);
		}
		engIndex=[[tEngIndex sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" 
																											   ascending:YES 
																												selector:@selector(caseInsensitiveCompare:)] autorelease]]] retain];
		// sort it, and, by the way, make it immutable
		[tEngIndex release];
			NSLog(@"%d",time(NULL));
	}
	return self;
}


-(NSString *) lexiconVersion;
{
	return lexiconVersion;
}

-(xmlNodePtr) nodeForKey:(NSString *)key language:(DFLanguage)language;
{
	return (xmlNodePtr)[[((language == DFSindarin) ? sindarinDict : engDict) objectForKey:key] bytes];
}

@end
