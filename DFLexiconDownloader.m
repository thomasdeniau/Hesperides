//
//  DFLexiconDownloader.m
//  Hesperides
//
//  Created by Thomas Deniau on Wed May 05 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.


#import "DFLexiconDownloader.h"
#import "NSFileManager-DFExtensions.h"
#import "DFDictionaryParser.h"

@implementation DFLexiconDownloader

-(id)initWithVersion:(NSString *)v dictionaryParser:(DFDictionaryParser*)aParser
{
	if (self=[super init])
	{
		version = [v copy];
		parser = [aParser retain];
	}
	return self;
}

-(void)dealloc
{
	[version release];
	[parser release];
	[filename release];
	[super dealloc];
}

-(NSString *)downloadPath
{
	NSString *appSupport=[[NSFileManager defaultManager] findFolder:kApplicationSupportFolderType inDomain:kUserDomain];
	return [[appSupport stringByAppendingPathComponent:@"Hesperides"] stringByAppendingPathComponent:filename];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)aFilename;
{
	filename = [aFilename copy];
	[download setDestination:[self downloadPath] allowOverwrite:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	expected=[response expectedContentLength];
}

- (void)downloadDidBegin:(NSURLDownload *)download;
{
	[download retain];
	[statusText setStringValue:[NSString stringWithFormat:@"I am currently downloading version %@ of the sindarin lexicon…",version]];
	[progressBar setDoubleValue:0];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
{
	[statusText setStringValue:[error localizedDescription]];
	[progressBar setDoubleValue:0];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length;
{
	[progressBar incrementBy:length/expected*0.7];
}

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType;
{
	return YES;
}

- (void)downloadDidFinish:(NSURLDownload *)download;
{
	xmlDocPtr doc;
	[download release];
	[statusText setStringValue:@"Indexing the new lexicon..."];
	doc=[parser parsePath:[self downloadPath]];
	[parser indexVersion:version withDoc:doc];
	xmlFreeDoc(doc);
	[progressBar setDoubleValue:100.];
	[statusText setStringValue:[NSString stringWithFormat:@"The version %@ of the sindarin lexicon was successfully downloaded. Please restart Hesperides to use it.",version]];
}

@end
