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
