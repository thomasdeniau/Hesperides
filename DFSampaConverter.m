//
//  DFSampaConverter.m
//  Hesperides
//
//  Created by Thomas Deniau on Wed May 05 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.

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
