//
//  rvmPlus2DatacorderViewController.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 14/05/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmPlus2DatacorderViewController.h"
#import "rvmTAPDecoder.h"
#import "rvmTZXDecoder.h"
#import "rvmPZXDecoder.h"
#import "rvmCSWDecoder.h"
#import "rvmAppDelegate.h"

@interface rvmPlus2DatacorderViewController ()
@property (weak) IBOutlet NSButton *writeCheck;

@end

@implementation rvmPlus2DatacorderViewController

-(void)awakeFromNib
{
  //_background.backgroundColor=[NSColor colorWithPatternImage:[NSImage imageNamed:@"mainPattern"]];
  _recB.imageName=@"recB";
  _playB.imageName=@"playB";
  _rewB.imageName=@"rewB";
  _fwdB.imageName=@"fwdB";
  _ejB.imageName=@"ejectB";
  _psB.imageName=@"pauseB";
  
  [self animateOut];
  
  [_browserList setTarget:self];
  [_browserList setDoubleAction:NSSelectorFromString(@"onBrowserDoubleClick:")];
  
  _cswNew.onClick=^(rvmAlphaButton *sender) {
    [self->_tapeNewPop close];
    [self newCassete:@"csw"];
  };
  
  _tapNew.onClick=^(rvmAlphaButton *sender) {
    [self->_tapeNewPop close];
    [self newCassete:@"tap"];
  };
  
  _pzxNew.onClick=^(rvmAlphaButton *sender) {
    [self->_tapeNewPop close];
    [self newCassete:@"pzx"];
  };
  
  _tzxNew.onClick=^(rvmAlphaButton *sender) {
    [self->_tapeNewPop close];
    [self newCassete:@"tzx"];
  };
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)animateIn
{
  [_datacorder animateIn];
  _recB.controlView.layer.opacity=1;
  _playB.controlView.layer.opacity=1;
  _rewB.controlView.layer.opacity=1;
  _fwdB.controlView.layer.opacity=1;
  _ejB.controlView.layer.opacity=1;
  _psB.controlView.layer.opacity=1;
}

-(void)animateOut
{
  [_datacorder animateOut];
  _recB.controlView.layer.opacity=0;
  _playB.controlView.layer.opacity=0;
  _rewB.controlView.layer.opacity=0;
  _fwdB.controlView.layer.opacity=0;
  _ejB.controlView.layer.opacity=0;
  _psB.controlView.layer.opacity=0;
}

-(void)onInsertMedia:(id)sender
{
  [self loadMedia:0];
}

-(void)onEject:(id)sender
{
  _ejB.state=NSOffState;
  [_datacorder onStop:self];
  [_datacorder makeEjectSound];
  //_machine.tapeDecoder=nil;
  _datacorder.decoder=nil;
  [_browserList reloadData];
  [_datacorder hideCassette];
  _datacorder.delta=0;
  [_writeCheck setEnabled:NO];
  [_tapeView setCassetteImage:nil length:0 name:nil];
}

//-(void)loadTape
-(void)loadMedia:(int)tag
{
  _ejB.state=NSOffState;
  NSOpenPanel *op=[(rvmAppDelegate*)[[NSApplication sharedApplication] delegate] openPanel];
  [_datacorder onStop:self];
  [_datacorder makeEjectSound];
  //_machine.tapeDecoder=nil;
  _datacorder.decoder=nil;
  [_browserList reloadData];
  [_datacorder hideCassette];
  _datacorder.delta=0;
  [_writeCheck setEnabled:NO];
  [_tapeView setCassetteImage:nil length:0 name:nil];
  
  NSArray *decoders=[self tapeDecoders];
  [op setAllowedFileTypes:decoders[0]];
  [op setCanChooseFiles:YES];
  [op setCanChooseDirectories:NO];
  [op setAllowsMultipleSelection:NO];
  [op beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
    if(result==NSOKButton)
    {
      [self loadMediaFile:op.URL sound:NO];
    } else
      [self->_browserList reloadData];
  }];
}

-(void)loadMediaFile:(NSURL*)filename sound:(BOOL)b
{
  @synchronized (_machine)
  {
    NSArray *decoders=[self tapeDecoders];
    
    [_writeCheck setEnabled:YES];
    
    NSString *ext=[[filename.path lowercaseString] pathExtension];
    
    NSInteger ind=[decoders[0] indexOfObject:ext];
    _machine.tapeDecoder=[decoders[1][ind] new];
    
    
    [_machine.tapeDecoder load:filename.path];
    
    
    [_writeCheck setState:NSOnState];
    _datacorder.decoder.writeProtected=YES;
    
    _datacorder.decoder=_machine.tapeDecoder;
    _machine.tapeDecoder.cassetteView=_datacorder;
    _datacorder.length=[_machine.tapeDecoder length];
    _datacorder.cassetteTitle=filename.path.lastPathComponent.stringByDeletingPathExtension;
    [_datacorder setBlock:0];
    [_browserList reloadData];
    
    if(b) [_datacorder makeEjectSound];
  }
}

-(NSArray*)tapeDecoders
{
  return @[@[@"tap",@"tzx",@"pzx",@"csw"],@[[rvmTAPDecoder class],[rvmTZXDecoder class],[rvmPZXDecoder class],[rvmCSWDecoder class]]];
}

- (IBAction)onBrowser:(id)sender {
  [_datacorder onStop:self];
  NSButton *b=sender;
  if(b.state==NSOnState)
  {
    [_browser showRelativeToRect:b.bounds ofView:b preferredEdge:NSMaxYEdge];
    [_tapeView setCassetteImage:_machine.tapeDecoder.image length:_machine.tapeDecoder.length name:_machine.tapeDecoder.path.lastPathComponent.stringByDeletingPathExtension];
  }
  b.state=NO;
}

-(IBAction)onBrowserDoubleClick:(id)sender
{
  NSOutlineView *ov=sender;
  
  uint i=[[ov itemAtRow:[ov selectedRow]][@"index"] intValue];
  
  [_datacorder go:i];
  [_browser close];
}

- (IBAction)onNewCassette:(id)sender {
  NSButton *b=sender;
  
  [_tapeNewPop showRelativeToRect:b.bounds ofView:b preferredEdge:NSMinXEdge];
}

-(void)newCassete:(NSString*)type
{
  NSSavePanel *op=[(rvmAppDelegate*)[NSApp delegate] savePanel];
  [_datacorder onStop:self];
  [_datacorder makeEjectSound];
  //_machine.tapeDecoder=nil;
  _datacorder.decoder=nil;
  [_browserList reloadData];
  [_datacorder hideCassette];
  _datacorder.delta=0;
  [_writeCheck setEnabled:NO];
  
  //[op setAllowedFileTypes:@[@"pzx",@"tzx"]];
  //[op setAllowedFileTypes:@[@"pzx",@"tap",@"csw",@"tzx"]];
  [op setAllowedFileTypes:@[type]];

  [op beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result)
   {
     if(result==NSOKButton)
     {
       @synchronized (self->_machine)
       {
         NSString *ext=[[op.URL.path lowercaseString] pathExtension];
         
         if([ext isEqualToString:@"tap"])
           self->_machine.tapeDecoder=[rvmTAPDecoder new];
         else if([ext isEqualToString:@"tzx"])
           self->_machine.tapeDecoder=[rvmTZXDecoder new];
         else if([ext isEqualToString:@"csw"])
           self->_machine.tapeDecoder=[rvmCSWDecoder new];
         else
           self->_machine.tapeDecoder=[rvmPZXDecoder new];
         
         [self->_writeCheck setEnabled:YES];
         [self->_writeCheck setState:NSOffState];

     
         self->_datacorder.decoder=self->_machine.tapeDecoder;
         self->_datacorder.decoder.writeProtected=NO;
         self->_machine.tapeDecoder.cassetteView=self->_datacorder;
         self->_datacorder.length=[self->_machine.tapeDecoder length];
         self->_datacorder.cassetteTitle=op.URL.path.lastPathComponent.stringByDeletingPathExtension;
         //_datacorder.blockTitle=[NSString stringWithFormat:@"%s",_machine.tapeDecoder.decoder->blockName];
         //_datacorder.blockTitle=[_machine.tapeDecoder go:0];
         [self->_datacorder setBlock:0];
         self->_datacorder.decoder.path=op.URL.path;
       }
     }
    [self->_tapeView setCassetteImage:self->_machine.tapeDecoder.image length:self->_machine.tapeDecoder.length name:self->_machine.tapeDecoder.path.lastPathComponent.stringByDeletingPathExtension];
    [self->_browserList reloadData];
   }];
}
@end
