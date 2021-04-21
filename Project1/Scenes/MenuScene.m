//
//  MenuScene.m
//  Project1
//
//  Created by Kris Olsson on 2021-04-20.
//

#import "MenuScene.h"
#import "ShaderController.h"
#import "BackgroundModel.h"
#import "ViewController.h"

@implementation MenuScene
{
    ViewController *_controller;
    ShaderController *_shader; //Shader controller
    BackgroundModel *background; //Quad for the background
    UIView *menuView;
    float height;
    float width;
}

- (UIView *) createUI : (UIView *) parent controller : (ViewController *) controller
{
    menuView = [[UIView alloc]initWithFrame:parent.frame];
    width = menuView.frame.size.width;
    height = menuView.frame.size.height;
    
    UIImageView *titleContainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_backing.png"]];
    [titleContainer setFrame:CGRectMake(10, 25, width - 20, 75)];
    [menuView addSubview:titleContainer];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleContainer.frame.size.width, titleContainer.frame.size.height)];
    [titleText setText:@"Asteroids 2.5D"];
    [titleText setTextAlignment:NSTextAlignmentCenter];
    [titleText setTextColor:[UIColor whiteColor]];
    titleText.font = [UIFont fontWithName:@"Copperplate" size:32];
    [titleContainer addSubview:titleText];
    
    UIButton *startButton = [[UIButton alloc] initWithFrame:CGRectMake(width/2 - 50, height - 60, 100, 50)];
    [startButton setImage:[UIImage imageNamed:@"text_backing.png"] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchDown];
    [startButton setEnabled:true];
    [menuView addSubview:startButton];
    
    UILabel *startButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, startButton.frame.size.width, startButton.frame.size.height)];
    [startButtonLabel setText:@"Start"];
    [startButtonLabel setTextAlignment:NSTextAlignmentCenter];
    [startButtonLabel setTextColor:[UIColor whiteColor]];
    startButtonLabel.font = [UIFont fontWithName:@"Copperplate" size:28];
    [startButton addSubview:startButtonLabel];
    
    self.view = menuView;
    _controller = controller;
    [self setupScene];
    
    return menuView;
}

- (void) setupScene
{
    //Enable some rendering options
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //Initiate shader
    _shader = [[ShaderController alloc] initWithVertexShader:@"VertexShader.glsl" fragmentShader:@"FragmentShader.glsl"];

    //Setup projection view
    _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), width/height, 1, 150);
    
    //Set up background quad
    background = [[BackgroundModel alloc] initWithShader:_shader];
    background.scale = 7.0f * (height/width);
    [background loadTexture:@"bg2.png"];
}

- (void) renderScene
{
    //Set background color
    glClearColor(0/255.0, 0/255.0, 0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Set camera perspective
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -30);
    
    //Render background model
    [background renderWithParentModelViewMatrix:viewMatrix];
}

- (void) startGame : (id) selector
{
    [_controller loadNewScene];
}

@end
