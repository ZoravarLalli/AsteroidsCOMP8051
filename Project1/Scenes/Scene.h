
#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/glext.h>
#import "ViewController.h"
@import GLKit;

@interface Scene : NSObject

@property ViewController *_parent;
@property GLKView *_sceneView;
@property float sceneHeight;
@property float sceneWidth;

- (instancetype) loadScene : (GLKView *) view parentController : (ViewController *) parent;
- (void) updateScene : (NSTimeInterval) deltaTime;
- (void) renderScene;

@end
