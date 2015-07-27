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


#import "DFHistoryController.h"
#import "DFController.h"

NSString *DFEntryNameKey = @"DFEntryNameKey";
NSString *DFLanguageKey = @"DFLanguageKey";
NSString *DFHistoryCapacity=@"DFHistoryCapacity";

@implementation DFHistoryController

- (id)init
{
	if (self = [super init])
	{
		currentItem = -1;
		[NSClassFromString(@"DFController") initialize];
		// be sure that that class has been initialized to have the defaults set up correctly
		capacity = [[[NSUserDefaults standardUserDefaults] objectForKey:DFHistoryCapacity] intValue];
	}
	return self;
}

-(void)awakeFromNib
{
	const unichar left[1] = { NSLeftArrowFunctionKey };
	const unichar right[1] = { NSRightArrowFunctionKey };
	[forwardItem setKeyEquivalent:[NSString stringWithCharacters:right length:1]];
	[backItem setKeyEquivalent:[NSString stringWithCharacters:left length:1]];
}

-(void)displayEntry:(NSDictionary *)info
{
	[controller displayWord:[info objectForKey:DFEntryNameKey] language:(DFLanguage)[[info objectForKey:DFLanguageKey] intValue] silent:YES];
}

- (IBAction)back:(id)sender
{
	currentItem++;
	[self displayEntry:[[menu itemAtIndex:currentItem] representedObject]];
}

- (IBAction)forward:(id)sender
{
	currentItem--;
	[self displayEntry:[[menu itemAtIndex:currentItem] representedObject]];
}

- (IBAction)selectEntry:(id)sender
{
	NSMenuItem *item=[sender retain];
	[menu removeItem:item];
	[menu insertItem:item atIndex:0];
	currentItem = 0;
	[self displayEntry:[item representedObject]];
	[item release];
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem
{
	if (anItem == backItem)
	{
		return (currentItem < (capacity - 1));
	}
	else if (anItem == forwardItem)
	{
		return (currentItem > 0);
	}
	else return YES;
}

- (void)addEntry:(NSString *)word language:(DFLanguage)lang;
{
	if ([menu numberOfItems] == capacity) [menu removeItemAtIndex:[menu numberOfItems]-1];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:word,DFEntryNameKey,[NSNumber numberWithInt:lang],DFLanguageKey,NULL];
	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:word action:@selector(selectEntry:) keyEquivalent:@""];
	[item setTarget:self];
	[item setRepresentedObject:info];
	[menu insertItem:item atIndex:0];
	currentItem = 0;
	[item release];
}

@end
