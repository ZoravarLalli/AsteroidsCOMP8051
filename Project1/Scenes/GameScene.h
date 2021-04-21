#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"

@import AVFoundation;

@interface GameScene : NSObject
@property UIView *view;
- (UIView *) createUI : (UIView *) parent controller : (ViewController *) controller;
- (void) updateScene : (NSTimeInterval) deltaTime;
- (void) setupScene;
- (void) renderScene;
- (void)playBackgroundMusic:(NSString *)filename;
- (AVAudioPlayer *)preloadSound:(NSString *)filename;
- (void)playPlayerShot;
- (void)playShotImpact;
- (void)playPlayerDeath;
- (void)playThrust;
- (void)pauseThrust;
- (void)addNewScore:(int) newScore;

@end
