/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.
 
 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"
#import "VideoPlayer.h"
#import "VideoAnalyticsProvider.h"
#import "ADBMobile.h"

@interface ViewController ()
@property(retain, nonatomic) IBOutlet UILabel *pubLabel;
@property(nonatomic, retain) VideoPlayer *videoPlayer;
@property(nonatomic, retain) VideoAnalyticsProvider *videoAnalyticsProvider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Also activate the logging features of the AppMeasurement library.
    // NOTE: remove this in production code.
    [ADBMobile setDebugLogging:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    _pubLabel.hidden = YES;

    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"clickbaby" ofType:@"mp4"];
    if (!videoPath) {
        NSLog(@"Cannot find the video file.");
        return;
    }

    NSURL *streamUrl = [NSURL fileURLWithPath:videoPath];
    self.videoPlayer = [[[VideoPlayer alloc] initWithContentURL:streamUrl] autorelease];

    [self.videoPlayer prepareToPlay];
    [self.videoPlayer.view setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:self.videoPlayer.view];
    self.videoPlayer.shouldAutoplay = NO;
    [self.view bringSubviewToFront:_pubLabel];

    [self _installNotificationHandlers];

    if (self.videoAnalyticsProvider) {
        [self.videoAnalyticsProvider tearDown];
        [self.videoAnalyticsProvider release];
    }

    // Setup video-tracking.    
    self.videoAnalyticsProvider = [[VideoAnalyticsProvider alloc] initWithPlayer:self.videoPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    // End the life-cycle of the VideoAnalytics provider.

    // Release all allocated resources.
    [_videoAnalyticsProvider release];
    _videoAnalyticsProvider = nil;
    [_videoPlayer release];
    _videoPlayer = nil;

    [super viewWillDisappear:animated];
}


- (void)dealloc {
    [_pubLabel release];
    _pubLabel = nil;
    [super dealloc];
}

- (void)_installNotificationHandlers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAdStart:)
                                                 name:PLAYER_EVENT_AD_START
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAdComplete:)
                                                 name:PLAYER_EVENT_AD_COMPLETE
                                               object:nil];
}

- (void)onAdStart:(NSNotification *)notification {
    _pubLabel.hidden = NO;
}

- (void)onAdComplete:(NSNotification *)notification {
    _pubLabel.hidden = YES;
}

@end
