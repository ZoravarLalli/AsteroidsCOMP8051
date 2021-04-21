#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface MenuScene : NSObject
@property UIView *view;
- (UIView *) createUI : (UIView *) parent controller : (ViewController *) controller;
- (void) setupScene;
- (void) renderScene;

@end

