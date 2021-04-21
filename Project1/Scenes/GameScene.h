
#import "Scene.h"

@import AVFoundation;

@interface GameScene : Scene

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
