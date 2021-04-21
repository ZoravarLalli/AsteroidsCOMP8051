
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

//Pan handler for rotating the ship
//- (void) handleSinglePanGesture:(UIPanGestureRecognizer *) sender
//{
//    if(sender.state == UIGestureRecognizerStateChanged)
//    {
//        CGPoint velocity = [sender velocityInView:sender.view];
//        float x = velocity.x/sender.view.frame.size.width;
//        float y = velocity.y/sender.view.frame.size.height;
//        [_ship rotate:(y + x)/10];
//    }
//}

//Handler for fire button
- (void) fireHandler : (id) sender
{
    // Play shot audio
    [self playPlayerShot];
    
    //Create new projectile model, set forward and position vectors, and add to array
    ProjectileModel *newProjectile = [[ProjectileModel alloc] initWithShader:_shader];
    newProjectile.forward = _ship.forward;
    newProjectile.position = _ship.position;
    newProjectile.asteroids = _asteroids;
    newProjectile.enemy = enemy;
    newProjectile.xBound = self.view.frame.size.width/20;
    newProjectile.yBound = self.view.frame.size.height/20;
    newProjectile.rotationY = _ship.rotationY;
    [_projectiles addObject:newProjectile];
}

//Handler for touching thrust button
- (void) thrustTouch : (id) sender
{
    [self playThrust]; // Start rocket sound player
    [_ship thrustToggle];
    //NSLog(@"START THRUST");
}

//Handler for canceling thrust
- (void) thrustCancel : (id) sender
{
    [self pauseThrust]; // Pause rocket sound player
    _ship.thrust = false;
    //NSLog(@"PAUSE THRUST");
}

// Handler for tocuhing left button
- (void) leftTouch : (id) sender
{
    [_ship setRotateLeft:true];
    //NSLog(@"START LEFT");
>>>>>>> master
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
