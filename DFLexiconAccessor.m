//
//  DFLexiconAccessor.m
//  Hesperides
//
//  Created by Thomas Deniau on 10/04/10.
//  Copyright 2010-2018 Thomas Deniau. All rights reserved.
//

#import "DFLexiconAccessor.h"


@implementation DFLexiconAccessor

@synthesize dictionary;
@synthesize language;

-(NSScriptObjectSpecifier *)objectSpecifier
{
	NSPropertySpecifier *spec= [[[NSPropertySpecifier alloc] initWithContainerClassDescription:(NSScriptClassDescription *)[NSApp classDescription]
																	containerSpecifier:nil
																				   key:((language==DFSindarin)?@"sindarinAccessor":@"englishAccessor")] autorelease];
	NSLog(@"%@",spec);
	return spec;
}

- (NSArray *) words
{
	return [[[dictionary valueForKey:@"dict"] objectAtIndex:language] allValues];
}

- (DFWord *) valueInWordsWithName:(NSString *) name
{
	return [dictionary word:name language:language];
}

@end
