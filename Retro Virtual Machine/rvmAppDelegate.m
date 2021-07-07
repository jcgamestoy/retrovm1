//
//  rvmAppDelegate.m
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 01/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmAppDelegate.h"
//#import "rvmLuajit.h"

#import "rvmMonitorWindowController.h"
//#import "rvmJoystickController.h"

#import "rvmMainWindowController.h"
#import "rvmInputManager.h"

#import "rvmAboutWindowController.h"

//#import <Alumen/Alumen.h>
//#import "rvmArchitecuresDocumentController.h"

NSData *motorSound,*seekSound;

@interface rvmAppDelegate ()
{
  rvmMainWindowController *main;
  NSMutableArray *windows;
  //rvmJoystickController *joyController;
  rvmInputManager *inputM;
  NSOpenPanel *openP;
  NSSavePanel *saveP;
  rvmAboutWindowController *about;
}

@end

@implementation rvmAppDelegate

-(id)init
{
  self=[super init];
  
  if(self)
  {
    motorSound=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Motor192" ofType:@"raw"]];
    seekSound=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Resources/Disk Sounds/Seek192" ofType:@"raw"]];
  }
  
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
  
  //Fix Yosemite bug.
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSNavPanelExpandedSizeForOpenMode"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSNavPanelExpandedSizeForSaveMode"];
}

-(void)awakeFromNib
{
  
  windows=[NSMutableArray array];
  
  main=[[rvmMainWindowController alloc] initWithWindowNibName:@"rvmMainWindowController"];
  
  
  [main.window makeKeyWindow];
  
  inputM=[rvmInputManager manager];
  __block rvmAppDelegate *ap=self;
  inputM.onJoyPlugged=^(rvmGamepad*g) {
    [[ap keyMonitor] joyPlugged:g];
  };
  
  inputM.onJoyUnplugged=^(rvmGamepad*g) {
    [[ap keyMonitor] joyUnplugged:g];
  };
  
  inputM.onJoy=^(rvmGamepad* g,uint e,uint v) {
    [[[ap keyMonitor] machine] joy:g element:e value:v];
  };
  
  about=[[rvmAboutWindowController alloc] initWithWindowNibName:@"rvmAboutWindowController"];
}

-(rvmMonitorWindowController*)keyMonitor
{
  id w=[[NSApplication sharedApplication] keyWindow];
  if([[w windowController] class]==[rvmMonitorWindowController class])
  {
    return [w windowController];
  }
  return nil;
}

-(rvmMonitorWindowController*)newWindow:(id)sender machine:(id)machine;
{
  rvmMonitorWindowController *wc;
  for(rvmMonitorWindowController *wcc in windows)
  {
    if(wcc.machine==machine)
    {
      wc=wcc;
      break;
    }
  }
  
  if(!wc)
  {
    wc=[[rvmMonitorWindowController alloc] initWithWindowNibName:@"rvmMonitorWindowController"];
    wc.machine=machine;
    
    [windows addObject:wc];
  }
  
  [wc showWindow:nil];
  [wc resume];
  [wc.window makeKeyWindow];
  //[main.machines machineRunning:sender];
  //[wc resume];
  
  
  return wc;
}

//- (IBAction)onHardReset:(id)sender {
//  NSWindow *w=[[NSApplication sharedApplication] keyWindow];
//  rvmMonitorWindowController *mc=(rvmMonitorWindowController*)w.windowController;
//  [mc hardReset];
//}

//- (IBAction)onDebug:(id)sender {
//  NSWindow *w=[[NSApplication sharedApplication] keyWindow];
//  rvmMonitorWindowController *mc=(rvmMonitorWindowController*)w.windowController;
//  
//  //[mc debug];
//}

//- (IBAction)onWarp:(id)sender {
//  NSWindow *w=[[NSApplication sharedApplication] keyWindow];
//  rvmMonitorWindowController *mc=(rvmMonitorWindowController*)w.windowController;
//  
//  [mc toggleWarp];
//}

-(void)removeWindow:(NSWindow*)w
{
  //[windows removeObject:w.windowController];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
  [main showWindow:nil];
  [main.window makeKeyWindow];
  
  return YES;
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
  NSLog(@"Openning... %@",filename);
  
  return YES;
}

- (IBAction)onWindowMachinesMenu:(id)sender {
  [main showWindow:nil];
  [main.window makeKeyWindow];
}

-(void)waitAllWindowsClose
{
  bool r=NO;
  for(rvmMonitorWindowController *wc in windows)
  {
    if(wc.window.isVisible)
    {
      r=YES;
    }
  }
  
  if(r)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,100*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
      [self waitAllWindowsClose];
    });
  else
    [NSApp replyToApplicationShouldTerminate:YES];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
  for(rvmMonitorWindowController *wc in windows)
  {
    if(wc.window.isVisible)
    {
      id d=wc.machine.doc;
      [d saveFile];
      [d updateChangeCount:NSChangeDone];
      [d saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:(__bridge void *)(wc)];
    }
  }
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,100*NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
    [self waitAllWindowsClose];
  });
  
  return NSTerminateLater;
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
  NSWindowController *wc=(__bridge NSWindowController *)(contextInfo);
  [wc close];
}

-(IBAction)onMachineStopped:(id)sender
{
  [main.machines machineStopped:sender];
}

-(NSOpenPanel*)openPanel
{
  if(!openP)
  {
    openP=[NSOpenPanel openPanel];
    //openP.maxSize=NSMakeSize(10000.0, 500.0);
  }

  return openP;
}

-(NSSavePanel*)savePanel
{
  if(!saveP)
  {
    saveP=[NSSavePanel savePanel];
  }
  
  return saveP;
}

-(IBAction)onAbout:(id)sender
{
  [about.window orderFront:self];
}

@end
