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

@implementation DFLexiconDownloader

-(id)initWithVersion:(NSString *)v
{
	if (self=[super init])
	{
		version = [v copy];
	}
	return self;
}

-(void)dealloc
{
	[version release];
	[super dealloc];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename;
{
	NSString *appSupport=[[NSFileManager defaultManager] findFolder:kApplicationSupportFolderType inDomain:kUserDomain];
	[download setDestination:[[appSupport stringByAppendingPathComponent:@"Hesperides"] stringByAppendingPathComponent:filename]
			  allowOverwrite:YES];
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
	[progressBar incrementBy:length/expected];
}

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType;
{
	return YES;
}

- (void)downloadDidFinish:(NSURLDownload *)download;
{
	[statusText setStringValue:[NSString stringWithFormat:@"The version %@ of the sindarin lexicon was successfully downloaded. Please restart Hesperides to use it.",version]];
	[progressBar setDoubleValue:100];
	[download release];
}

@end
