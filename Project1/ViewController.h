//
//  ViewController.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/glext.h>

@import GLKit;
@import AVFoundation;

@interface ViewController : GLKViewController

- (void)playBackgroundMusic:(NSString *)filename;
- (AVAudioPlayer *)preloadSound:(NSString *)filename;
- (void)playPlayerShot;
- (void)playShotImpact;
- (void)playPlayerDeath;
- (void)playThrust;
- (void)pauseThrust;
- (void)leftTouch;
- (void)leftCancel;
- (void)rightTouch;
- (void)rightCancel;
- (void)addNewScore:(int) newScore;

@end
