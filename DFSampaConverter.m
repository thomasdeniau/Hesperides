//
//  DFSampaConverter.m
//  Hesperides
//
//  Created by Thomas Deniau on Wed May 05 2004.


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


// This is legacy code. I keep it in case we suddenly decide not to use the libxslt SAMPA extension.

// actually all this file does is this : 
//  $pron =~ s/((.\/)|(.=)|(._0)|(_.)|(.[`])|(.))/sampa2utf( $1 )/eg;
// perl would be more efficient here ;)

#import "DFSampaConverter.h"

@implementation DFSampaConverter

-(id)init
{
	if (self = [super init])
	{
		re=[[AGRegex alloc] initWithPattern:@"((.\\/)|(.=)|(._0)|(_.)|(.[`])|(.))"];
		sampa=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SampaConvert" ofType:@"plist"]]; 		
	}
	return self;
}

-(void)dealloc
{
	[sampa release];
	[re release];
	[super dealloc];
}

- (NSString *)convertString:(NSString *)str;
{	
	NSEnumerator *e=[re findEnumeratorInString:str];
	NSMutableString *result=[[NSMutableString alloc] init];
	NSString *ret;
	
	int last=0;
	
	AGRegexMatch *occurrence;
	while (occurrence=[e nextObject])
	{
		NSString *key=[occurrence group];
		NSString *rep=[sampa objectForKey:key];
		[result appendString:[str substringWithRange:NSMakeRange(last,[occurrence range].location-last)]];
		[result appendString:(rep?rep:key)];
		last=NSMaxRange([occurrence range]);
	}

	[result appendString:[str substringFromIndex:last]];
	
	ret = [result copy];
	[result release];
	return [ret autorelease];
}

@end
