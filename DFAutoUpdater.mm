//
//  DFAutoUpdater.m
//  Hesperides
//
//  Created by Thomas Deniau on Mon Jun 07 2004.
//  Copyright (c) 2004 Nousoft. All rights reserved.
//

// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. Hesperides comes with ABSOLUTELY NO WARRANTY.

#import "DFAutoUpdater.h"
#import "MacPADSocket.h"
#import "DFLexiconDownloader.h"
#import "DFController.h"

@implementation DFAutoUpdater

-(id)init
{
	if (self = [super init])
	{
		pad = [[MacPADSocket alloc] init];
		[pad setDelegate:self];
	}
	return self;
}

-(void)dealloc
{
	[pad release];
	[super dealloc];
}

-(void)macPADCheckFinished:(NSNotification *)n
{
	if (padCheckIsLexicon)
	{
		if ([[[n userInfo] objectForKey:MacPADNewVersionAvailable] boolValue])
		{
			if (NSRunAlertPanel(@"New version available", 
								@"A new version of the sindarin lexicon, %@, is available. Do you want Hesperides to download it now ?",
								@"OK", @"No, thanks", nil, [pad newVersion]) == NSOKButton)
			{
				DFLexiconDownloader *downloader=[[DFLexiconDownloader alloc] initWithVersion:[pad newVersion] dictionaryParser:[[DFController sharedInstance] parser]];
				NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[pad productDownloadURL]]];
				[NSBundle loadNibNamed:@"DFLexiconDownloader" owner:downloader];
				[[[NSURLDownload alloc] initWithRequest:request delegate:downloader] autorelease];
			}
		}
		else if (! isAutomaticCheck)
		{
			NSRunAlertPanel(@"No new version available", @"No new version of the sindarin lexicon is currently available for download.",@"OK", nil, nil);
		}
	}
	else
	{
		if ([[[n userInfo] objectForKey:MacPADNewVersionAvailable] boolValue])
		{
			if (NSRunAlertPanel(@"New version available", 
								@"A new version of Hesperides, %@, is available. Do you want to download it now ?",
								@"OK", @"No, thanks", nil, [pad newVersion]) == NSOKButton)
			{
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[pad productDownloadURL]]];
			}
		}
		else
		{
			if (! isAutomaticCheck)
			{
				NSRunAlertPanel(@"No new version available", @"No new version of Hesperides is currently available for download.",@"OK", nil, nil);
			}
			padCheckIsLexicon=TRUE;
			[pad performCheck:[NSURL URLWithString:@"http://www.nousoft.org/lexicon.plist"] withVersion:[[NSApp delegate] lexiconVersion]];
		}
	}
}

-(IBAction)checkForUpdates:(id)sender;
{
	isAutomaticCheck=! [sender isKindOfClass:[NSMenuItem class]];
	padCheckIsLexicon=FALSE;
	[pad performCheck];
}


@end
