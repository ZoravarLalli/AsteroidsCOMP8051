//
//  CubeModel.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "ShipModel.h"
#import "AsteroidModel.h"

@implementation ShipModel
{
    float velocityPercent;
}

//Each face is defined by distinct vertices, repeated vertices needed for corners.
//Attributes orderd according to Vertex.h (position, color, tex coor, normal)
const static Vertex vertices[] =
{
    //Top left
    {{0,0,-2},{1,1,1,1},{1,1},{-1,1,1}},
    {{-2,0, 2},{1,1,1,1},{0,0},{-1,1,1}},
    {{0,1,1},{1,1,1,1},{1,0},{-1,1,1}},
    //Top right
    {{0,0,-2},{1,1,1,1},{1,1},{1,1,1}},
    {{2,0,2},{1,1,1,1},{0,0},{1,1,1}},
    {{0,1,1},{1,1,1,1},{1,0},{1,1,1}},
    //Bottom left
    {{0,0,-2},{1,1,1,1},{1,1},{0,-1,0}},
    {{-2,0,2},{1,1,1,1},{0,0},{0,-1,0}},
    {{0,0,1},{1,1,1,1},{1,0},{0,-1,0}},
    //Bottom right
    {{0,0,-2},{1,1,1,1},{1,1},{0,-1,0}},
    {{2,0,2},{1,1,1,1},{0,0},{0,-1,0}},
    {{0,0,1},{1,1,1,1},{1,0},{0,-1,0}},
    //Back left
    {{0,1,1},{1,1,1,1},{1,1},{0,0,1}},
    {{-2,0,2},{1,1,1,1},{0,0},{0,0,1}},
    {{0,0,1},{1,1,1,1},{1,0},{0,0,1}},
    //Back right
    {{0,1,1},{1,1,1,1},{1,1},{0,0,1}},
    {{2,0,2},{1,1,1,1},{0,0},{0,0,1}},
    {{0,0,1},{1,1,1,1},{1,0},{0,0,1}},
};

//Indices linking vertices to make the model.
//Each face is made of triangles linked by three vertices.
//Order of vertices matters, counter clockwise order faces the camera
const static GLubyte indices[] =
{
    0,1,2,
    3,5,4,
    6,8,7,
    9,10,11,
    12,13,14,
    15,17,16,
};

//Initiation method inherited from Model.m
- (instancetype) initWithShader:(BaseEffect *) shader
{
    //Initialize cube with shader and vertex data.
    if(self = [super initWithName:"ship"
                           shader:shader
                         vertices:(Vertex *)vertices
                      vertexCount:sizeof(vertices)/sizeof(vertices[0])
                          indices:indices
                       indexCount: sizeof(indices)/sizeof(indices[0])])
    {
        //Load texture from Resources
        [self loadTexture:@"reboot.jpg"];
        //Set initial rotation
        self.rotationX = M_PI/2;
        //Set initial forward vector
        self.forward = GLKVector3Make(0, 1, 0);
        //Set initial velocity
        velocityPercent = 0.0;
        self.lives = 5;
    }
    return self;
}

//Update method interited from Model.m
-(void)updateWithDelta:(NSTimeInterval)delta
{
    //If the thrust button is active, increase velocity, else decrease it
    if(self.thrust)
    {
        if(velocityPercent < 1.0) velocityPercent += 0.15;
    }
    else
    {
        if(velocityPercent > 0) velocityPercent -= 0.01;
    }
    
    //If velocity is greater than 0, add a scaled forward vector to position
    if(velocityPercent > 0)
    {
        GLKVector3 velocity = GLKVector3MultiplyScalar(_forward, velocityPercent);
        self.position = GLKVector3Add(self.position, velocity);
    }
    //Check if ship is beyond bounds of the screen.
    if(self.position.x > _xBound)
    {
        self.position = GLKVector3Make(_xBound * -1, self.position.y, self.position.z);
    }
    else if (self.position.x < _xBound * -1)
    {
        self.position = GLKVector3Make(_xBound, self.position.y, self.position.z);
    }
    else if (self.position.y > _yBound)
    {
        self.position = GLKVector3Make(self.position.x, _yBound * -1, self.position.z);
    }
    else if (self.position.y < _yBound * -1)
    {
        self.position = GLKVector3Make(self.position.x, _yBound, self.position.z);
    }
    
    
    //Check for asteroid collision
    for(AsteroidModel *ast in _asteroids)
    {
        if(self.position.x + (2 * ast.scale) >= ast.position.x
           && self.position.x - (2 * ast.scale) <= ast.position.x
           && self.position.y + (2 * ast.scale) >= ast.position.y
           && self.position.y - (2 * ast.scale) <= ast.position.y)
        {
            [self asteroidHit];
        }
    }
}

//Function to toggle the thrust on or off from user input
-(void) thrustToggle
{
    self.thrust = !self.thrust;
}

//Function to call when colliding with an asteroid
- (void) asteroidHit
{
    if(self.lives > 0)
    {
        self.lives -= 1;
        [self resetPos];

    }
    else
    {
        NSLog(@"ya ded");
    }
}

- (void) resetPos
{
    self.forward = GLKVector3Make(0, -1, 0);
    velocityPercent = 0.0;
    self.rotationY = 0;
    self.position = GLKVector3Make(0, 0, 0);
    self.thrust = false;
}


//Rotate the model from user input.
-(void) rotate : (float) angle
{
    //If/else tree to reset the rotation angle if it goes over a full rotaion in either direction
    if(angle > 0 && self.rotationY > M_PI * 2) self.rotationY += (angle - (M_PI * 2));
    else if(angle < 0 && self.rotationY < M_PI * -2) self.rotationY += (angle + (M_PI * 2));
    else self.rotationY += angle;
    //Set the forward vector based on rotation angle.
    self.forward = GLKVector3Make(sinf(self.rotationY) * -1, cosf(self.rotationY), 0);
}

@end
