//
//  DFLexiconDownloader.m
//  Hesperides
//
//  Created by Thomas Deniau on Wed May 05 2004.


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
