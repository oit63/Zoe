//
//  AudioPlayerAppDelegate.m
//

#import "AudioPlayerAppDelegate.h"

@implementation AudioPlayerAppDelegate

@synthesize window;

void interruptionListener (void *inClientData, UInt32 inInterruptionState);

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// We need to initiate an audio session to play nice with Core Audio.
	// This will prevent the device from sleeping when locked, and allows
	// us to handle incoming phone calls and text messages gracefully.
	AudioSessionInitialize (
							NULL,                  // use the default (main) run loop
							NULL,                  // use the default run loop mode
							interruptionListener,  // a reference to your interruption callback
							self                   // userData
							);
	
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
		
	[urlTextField addTarget:self action:@selector(load) forControlEvents:UIControlEventEditingDidEndOnExit];
	urlTextField.text = @"http://";
	[urlTextField becomeFirstResponder];
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
	[urlTextField release];
	[activityIndicatorView release];
	[pauseButton release];
	[playButton release];
	[audioPlayer release];
    [super dealloc];
}

- (void)showStopped {
	[UIView beginAnimations:nil context:nil];
	[activityIndicatorView stopAnimating];
	pauseButton.alpha = 0;
	playButton.alpha = 0;
	[UIView commitAnimations];
}

- (void)showLoading {
	[UIView beginAnimations:nil context:nil];
	[activityIndicatorView startAnimating];
	pauseButton.alpha = 0;
	playButton.alpha = 0;
	[UIView commitAnimations];
}

- (void)showPlaying {
	[UIView beginAnimations:nil context:nil];
	[activityIndicatorView stopAnimating];
	pauseButton.alpha = 1;
	playButton.alpha = 0;
	[UIView commitAnimations];
}

- (void)showPaused {
	[UIView beginAnimations:nil context:nil];
	[activityIndicatorView stopAnimating];
	pauseButton.alpha = 0;
	playButton.alpha = 1;
	[UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}

- (IBAction)load {
	AudioSessionSetActive(YES);
	[audioPlayer cancel];
	[audioPlayer release];
	audioPlayer = [[AudioPlayer alloc] initPlayerWithURL:[NSURL URLWithString:urlTextField.text] delegate:self];
	[urlTextField resignFirstResponder];
	[self showLoading];
}

- (IBAction)pause {
	audioPlayer.paused = YES;
	[self showPaused];
}

- (IBAction)play {
	audioPlayer.paused = NO;
	[self showPlaying];
}

- (void)audioPlayerDownloadFailed:(AudioPlayer *)audioPlayer {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Audio download failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert autorelease];
	[self showStopped];
}

- (void)audioPlayerPlaybackStarted:(AudioPlayer *)audioPlayer {
	[self showPlaying];
}

- (void)audioPlayerPlaybackFinished:(AudioPlayer *)audioPlayer {
	AudioSessionSetActive(NO);
	[self showStopped];
}

void interruptionListener(void *userData, UInt32  interruptionState) {
	AudioPlayerAppDelegate *self = userData;
	if (interruptionState == kAudioSessionBeginInterruption) {
		[self pause];
		AudioSessionSetActive(NO);
	} else if (interruptionState == kAudioSessionEndInterruption) {
		AudioSessionSetActive(YES);
	}
}

@end
