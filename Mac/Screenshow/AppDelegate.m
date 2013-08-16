//
//  AppDelegate.m
//  Screenshow
//
//  Created by Vijay Sundaram on 8/14/13.
//  Copyright (c) 2013 Vijay Sundaram. All rights reserved.
//

#import "AppDelegate.h"

#define kMenubarTitleScreenshowOff (@"◎")
#define kMenubarTitleScreenshowOnPulseOn (@"◉")
#define kMenubarTitleScreenshowOnPulseOff (@"◎")
#define kMenubarPulseTimeInterval (0.7)

@implementation AppDelegate

@synthesize menubarPulseTimer;

- (void)awakeFromNib
{
    // Set up menubar item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setTitle:kMenubarTitleScreenshowOff];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
    [statusItem setAction:@selector(menubarClick)];
    
    isLive = NO;
    
    // Set up hotkey
    EventHotKeyRef gMyHotKeyRef;
    EventHotKeyID gMyHotKeyID;
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&hotkeyHandler, 1, &eventType, (__bridge void *)self, NULL);
    
    gMyHotKeyID.signature='scky';
    gMyHotKeyID.id=1;
    RegisterEventHotKey(kVK_Space, controlKey, gMyHotKeyID,
                        GetApplicationEventTarget(), 0, &gMyHotKeyRef);
}

- (void)menubarPulseOn
{
    [statusItem setTitle:kMenubarTitleScreenshowOnPulseOn];
    menubarPulseTimer = [NSTimer scheduledTimerWithTimeInterval:kMenubarPulseTimeInterval
                                                         target:self
                                                       selector:@selector(menubarPulseOff)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)menubarPulseOff
{
    [statusItem setTitle:kMenubarTitleScreenshowOnPulseOff];
    menubarPulseTimer = [NSTimer scheduledTimerWithTimeInterval:kMenubarPulseTimeInterval
                                                         target:self
                                                       selector:@selector(menubarPulseOn)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)toggleScreenshow
{
    if (!isLive)
    {
        [self menubarPulseOn];
        isLive = YES;
        
        //
        // #STUB: Generate unique screenshow URL
        //
        NSString *screenshowURL = @"https://scrnshw.co/x0wh2n";
        
        // Copy screenshow URL to pasteboard
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        [pasteBoard clearContents];
        if (![pasteBoard setString:screenshowURL forType:NSPasteboardTypeString])
        {
            NSLog(@"[SCREENSHOW ERROR] Failed to copy screenshow URL to pasteboard");
        }
        
        // Programmatically paste screenshow URL from pasteboard into whichever app has focus
        CGEventSourceRef state = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
        
        CGEventRef cmdDown = CGEventCreateKeyboardEvent(state, kVK_Command, true);
        CGEventRef cmdUp = CGEventCreateKeyboardEvent(state, kVK_Command, false);
        CGEventRef vDown = CGEventCreateKeyboardEvent(state, kVK_ANSI_V, true);
        CGEventRef vUp = CGEventCreateKeyboardEvent(state, kVK_ANSI_V, false);
        
        CGEventSetFlags(vDown, kCGEventFlagMaskCommand);
        CGEventSetFlags(vUp, kCGEventFlagMaskCommand);
        
        CGEventTapLocation location = kCGSessionEventTap;
        CGEventPost(location, cmdDown);
        CGEventPost(location, vDown);
        CGEventPost(location, vUp);
        CGEventPost(location, cmdUp);
        
        CFRelease(cmdDown);
        CFRelease(cmdUp);
        CFRelease(vDown);
        CFRelease(vUp);
        CFRelease(state);
        
        //
        // #STUB: Kickoff screenshow of current screen
        //
    }
    else
    {
        [menubarPulseTimer invalidate];
        [statusItem setTitle:kMenubarTitleScreenshowOff];
        isLive = NO;
    }
}

- (void)menubarClick
{
    NSEvent *event = [NSApp currentEvent];
    if ([event modifierFlags] & NSControlKeyMask)
    {
        // Gracefully quit app
        [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
    }
    else
    {
        [self toggleScreenshow];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

OSStatus hotkeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    [(__bridge AppDelegate *)userData toggleScreenshow];
    
    return noErr;
}

@end
