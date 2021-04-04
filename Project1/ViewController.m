//
//  ViewController.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "ViewController.h"
#import "Vertex.h"
#import "BaseEffect.h"
#import "ShipModel.h"
#import "ProjectileModel.h"
#import "AsteroidModel.h"

@interface ViewController ()

@end

@implementation ViewController
{
    BaseEffect *_shader; //Shader controller
    ShipModel *_ship; //Ship model
    NSMutableArray *_projectiles; //Array for projectiles
    NSMutableArray *_asteroids; //Array for asteroids
    float timeSinceLastAsteroid;
    UILabel *livesleft;
    UILabel *gameOver;
    UILabel *score;
}

//Called when the view is loaded
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Set OpenGL view
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    //Setup for Gesture listeners
    UIPanGestureRecognizer *panSingleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSinglePanGesture: )];
    panSingleGesture.maximumNumberOfTouches = 1;
    panSingleGesture.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panSingleGesture];
    
    //Setup for buttons
    UIButton *fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fireButton.frame = CGRectMake(10, view.frame.size.height-60,50,50);
    [fireButton setTitle:@"F" forState:UIControlStateNormal];
    [fireButton setBackgroundColor:[UIColor redColor]];
    [fireButton addTarget:self action:@selector(fireHandler:) forControlEvents:UIControlEventTouchDown];
    [fireButton setEnabled:YES];
    [self.view addSubview:fireButton];
    
    UIButton *thrustButton = [UIButton buttonWithType:UIButtonTypeCustom];
    thrustButton.frame = CGRectMake(10,view.frame.size.height-120,50,50);
    [thrustButton setTitle:@"T" forState:UIControlStateNormal];
    [thrustButton setBackgroundColor:[UIColor greenColor]];
    [thrustButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [thrustButton addTarget:self action:@selector(thrustTouch:) forControlEvents:UIControlEventTouchDown];
    [thrustButton addTarget:self action:@selector(thrustTouch:) forControlEvents:UIControlEventTouchUpInside];
    [thrustButton addTarget:self action:@selector(thrustCancel:) forControlEvents:UIControlEventTouchUpOutside];
    [thrustButton setEnabled:YES];
    [self.view addSubview:thrustButton];
    
    livesleft = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 100, 25)];
    [livesleft setText:@"Lives: 5"];
    [livesleft setBackgroundColor:[UIColor blackColor]];
    [livesleft setTextColor:[UIColor whiteColor]];
    [self.view addSubview:livesleft];
    
    gameOver = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2-25, 100, 25)];
    [gameOver setText:@"Game Over"];
    [gameOver setBackgroundColor:[UIColor blackColor]];
    [gameOver setTextColor:[UIColor whiteColor]];
    [gameOver setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:gameOver];
    [gameOver setHidden:true];
    
    score = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.view.frame.size.height/2+25, 100, 25)];
    [score setText:@"Score: 0"];
    [score setBackgroundColor:[UIColor blackColor]];
    [score setTextColor:[UIColor whiteColor]];
    [score setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:score];
    [score setHidden:true];
    
    [EAGLContext setCurrentContext:view.context];
    [self setupScene];
}

//Additional setup code
- (void) setupScene
{
    //Initiate shader
    _shader = [[BaseEffect alloc] initWithVertexShader:@"VertexShader.glsl" fragmentShader:@"FragmentShader.glsl"];
    
    //Initiate ship model
    _ship = [[ShipModel alloc] initWithShader:_shader];
    
    //Setup projection view
    _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);
    
    //Initialize projectile array
    _projectiles = [[NSMutableArray alloc] initWithCapacity:10];
    
    //Initialize asteroid array
    _asteroids = [[NSMutableArray alloc] initWithCapacity:10];
    
    //Initialize asteroid timer
    timeSinceLastAsteroid = 0.0;
}

//Called to draw on each frame
- (void) glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    //Set background color
    glClearColor(0/255.0, 180.0/255.0, 180.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Enable some rendering options
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //Set camera perspective
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -30);
    
    if(_ship.lives > 0)
    {
        [livesleft setText:[NSString stringWithFormat:@"Lives: %d", _ship.lives]];
        //Set view matrix for ship to be drawn
        [_ship renderWithParentModelViewMatrix:viewMatrix];
        _ship.xBound = self.view.frame.size.width/20;
        _ship.yBound = self.view.frame.size.height/20;
        _ship.asteroids = _asteroids;
    }
    else if(gameOver.isHidden)
    {
        [livesleft setText:[NSString stringWithFormat:@"Lives: %d", _ship.lives]];
        [gameOver setHidden:false];
        [score setHidden:false];
    }
    
        
    //Iterate for projectiles and draw each.
    for(id proj in _projectiles)
    {
        [proj renderWithParentModelViewMatrix:viewMatrix];
    }
    
    //Iterate for asteroids and draw each.
    for(id ast in _asteroids)
    {
        [ast renderWithParentModelViewMatrix:viewMatrix];
    }
}

//Open GL update function
- (void) update
{
    //Call ship's update
    [_ship updateWithDelta:self.timeSinceLastUpdate];
    
    //Call each projectile's update
    for(ProjectileModel *proj in [_projectiles reverseObjectEnumerator])
    {
        [proj updateWithDelta:self.timeSinceLastUpdate];
        if(proj.destroy) [_projectiles removeObject:proj];
    }
    
    //Call each asteroid's update
    for(AsteroidModel *ast in [_asteroids reverseObjectEnumerator])
    {
        [ast updateWithDelta:self.timeSinceLastUpdate];
        if(ast.destroy) [_asteroids removeObject:ast];
    }
    
    //Increment asteroid timer and spawn
    timeSinceLastAsteroid += self.timeSinceLastUpdate;
    if(timeSinceLastAsteroid >= 5) [self spawnAsteroid];    
}

//Pan handler for rotating the ship
- (void) handleSinglePanGesture:(UIPanGestureRecognizer *) sender
{
    if(sender.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [sender velocityInView:sender.view];
        float x = velocity.x/sender.view.frame.size.width;
        float y = velocity.y/sender.view.frame.size.height;
        [_ship rotate:(y + x)/10];
    }
}

//Handler for fire button
- (void) fireHandler : (id) sender
{
    //Create new projectile model, set forward and position vectors, and add to array
    ProjectileModel *newProjectile = [[ProjectileModel alloc] initWithShader:_shader];
    newProjectile.forward = _ship.forward;
    newProjectile.position = _ship.position;
    newProjectile.asteroids = _asteroids;
    newProjectile.xBound = self.view.frame.size.width/20;
    newProjectile.yBound = self.view.frame.size.height/20;
    [_projectiles addObject:newProjectile];
}

//Handler for touching thrust button
- (void) thrustTouch : (id) sender
{
    [_ship thrustToggle];
}

//Handler for canceling thrust
- (void) thrustCancel : (id) sender
{
    _ship.thrust = false;
}

- (void) spawnAsteroid
{
    //Reset timer, create new asteroid, set data and add to array
    timeSinceLastAsteroid = 0.0;
    if([_asteroids count] >= 10) return;
    AsteroidModel *newAsteroid = [[AsteroidModel alloc] initWithShader:_shader];
    newAsteroid.xBound = self.view.frame.size.width/20;
    newAsteroid.yBound = self.view.frame.size.height/20;
    double randX = ((double)arc4random_uniform(newAsteroid.xBound) - newAsteroid.xBound/2);
    double randY = ((double)arc4random_uniform(newAsteroid.yBound) - newAsteroid.yBound/2);
    newAsteroid.position = GLKVector3Make(randX, randY, 0);
    [_asteroids addObject:newAsteroid];
}

@end
