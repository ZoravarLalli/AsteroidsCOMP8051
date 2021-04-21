
#import "Scene.h"

//Parent class for scene objects, load the base GLK View.
@implementation Scene

- (instancetype) loadScene : (GLKView *) view parentController : (ViewController *) parent
{
    //Setup scene view, height, and width
    self._sceneView = view;
    self._parent = parent;
    __sceneView.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    __sceneView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [EAGLContext setCurrentContext:self._sceneView.context];
    self.sceneHeight = self._sceneView.frame.size.height;
    self.sceneWidth = self._sceneView.frame.size.width;
    return self;
}

- (void) updateScene : (NSTimeInterval) deltaTime {}
- (void) renderScene {}

@end
