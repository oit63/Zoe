//
//  AudioPlayerAppDelegate.h
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"

@interface AudioPlayerAppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate, AudioPlayerDelegate> {
    UIWindow *window;
	IBOutlet UITextField *urlTextField;
	IBOutlet UIActivityIndicatorView *activityIndicatorView;
	IBOutlet UIButton *pauseButton;
	IBOutlet UIButton *playButton;
	
	AudioPlayer *audioPlayer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

/*
 * Loads and plays the audio URL input by the user.
 */
- (IBAction)load;

/*
 * Pauses the currently playing audio.
 */
- (IBAction)pause;

/*
 * Resumes playing the current audio after pause.
 */
- (IBAction)play;

@end

