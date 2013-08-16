//
//  AppDelegate.h
//  Screenshow
//
//  Created by Vijay Sundaram on 8/14/13.
//  Copyright (c) 2013 Vijay Sundaram. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSStatusItem *statusItem;
    BOOL isLive;
    NSTimer *menubarPulseTimer;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSTimer *menubarPulseTimer;

@end
