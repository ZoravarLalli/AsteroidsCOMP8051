
#import "ViewController.h"
#import "GameScene.h"
#import "MenuScene.h"

@interface ViewController ()

@end

typedef enum
{
    MENU,
    GAME,
} GameState;

@implementation ViewController
{
    GameScene *gameScene;
    MenuScene *menuScene;
    GameState state;
    GLKView *view;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setExclusiveTouch:NO];
    
    view = (GLKView *) self.view;
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [EAGLContext setCurrentContext:view.context];
    menuScene = [[MenuScene alloc] init];
    gameScene = [[GameScene alloc] init];
    [self.view addSubview:[menuScene createUI:view controller:self]];
    state = MENU;
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if(state == MENU) [menuScene renderScene];
    else if(state == GAME) [gameScene renderScene];
}

//Open GL update function
- (void) update
{
    if(state == GAME) [gameScene updateScene:self.timeSinceLastUpdate];
}

//Change the scene state, called from game scenes
- (void) loadNewScene
{
    for(UIView *subView in self.view.subviews) [subView removeFromSuperview];
    if(state == MENU)
    {
        [self.view addSubview:[gameScene createUI:view controller:self]];
        state = GAME;
    }
    else if (state == GAME)
    {
        [self.view addSubview:[menuScene createUI:view controller:self]];
        state = MENU;
    }
}

@end
