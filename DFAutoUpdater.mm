//
//  DFAutoUpdater.m
//  Hesperides
//
//  Created by Thomas Deniau on Mon Jun 07 2004.


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
            NSAlert *newVersionAlert = [[NSAlert alloc] init];
            newVersionAlert.messageText = @"New version available";
            newVersionAlert.informativeText = [NSString stringWithFormat:@"A new version of the sindarin lexicon, %@, is available. Do you want Hesperides to download it now ?", [pad newVersion]];
            [newVersionAlert addButtonWithTitle:@"OK"];
            [newVersionAlert addButtonWithTitle:@"No thanks"];

			if ([newVersionAlert runModal] == NSAlertFirstButtonReturn)
			{
				DFLexiconDownloader *downloader=[[DFLexiconDownloader alloc] initWithVersion:[pad newVersion] dictionaryParser:[[DFController sharedInstance] parser]];
				NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:[pad productDownloadURL]]];
                [[NSBundle mainBundle] loadNibNamed:@"DFLexiconDownloader" owner:downloader topLevelObjects:NULL];
				[[[NSURLDownload alloc] initWithRequest:request delegate:downloader] autorelease];
			}
            [newVersionAlert release];
		}
		else if (! isAutomaticCheck)
		{
            NSAlert *newVersionAlert = [[NSAlert alloc] init];
            newVersionAlert.messageText = @"No new version available";
            newVersionAlert.informativeText = @"No new version of the sindarin lexicon is currently available for download.";
            [newVersionAlert addButtonWithTitle:@"OK"];
            [newVersionAlert runModal];
            [newVersionAlert release];

		}
	}
	else
	{
		if ([[[n userInfo] objectForKey:MacPADNewVersionAvailable] boolValue])
		{
            NSAlert *newVersionAlert = [[NSAlert alloc] init];
            newVersionAlert.messageText = @"New version available";
            newVersionAlert.informativeText = [NSString stringWithFormat:@"A new version of Hesperides, %@, is available. Do you want to download it now ?", [pad newVersion]];
            [newVersionAlert addButtonWithTitle:@"OK"];
            [newVersionAlert addButtonWithTitle:@"No thanks"];

			if ([newVersionAlert runModal] == NSAlertFirstButtonReturn)
			{
				[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[pad productDownloadURL]]];
			}
            
            [newVersionAlert release];
		}
		else
		{
			if (! isAutomaticCheck)
			{
                NSAlert *newVersionAlert = [[NSAlert alloc] init];
                newVersionAlert.messageText = @"No new version available";
                newVersionAlert.informativeText = @"No new version of Hesperides is currently available for download.";
                [newVersionAlert addButtonWithTitle:@"OK"];
                [newVersionAlert runModal];
                [newVersionAlert release];
			}
			padCheckIsLexicon=TRUE;
			[pad performCheck:[NSURL URLWithString:@"https://www.deniau.org/hesperides/lexicon.plist"] withVersion:[(DFController*)[NSApp delegate] lexiconVersion]];
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
