//
//  CubeModel.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "AsteroidModel.h"

@implementation AsteroidModel

//Each face is defined by distinct vertices, repeated vertices needed for corners.
//Attributes orderd according to Vertex.h (position, color, tex coor, normal)
const static Vertex vertices[] = {
    //Front
    {{1,-1,1},{1,0,0,1},{1,0},{0,0,1}},
    {{1,1,1},{0,1,0,1},{1,1},{0,0,1}},
    {{-1,1,1},{0,0,1,1},{0,1},{0,0,1}},
    {{-1,-1,1},{0,0,0,1},{0,0},{0,0,1}},
    //Back
    {{-1,-1,-1},{0,0,1,1},{1,0},{0,0,-1}},
    {{-1,1,-1},{0,1,0,1},{1,1},{0,0,-1}},
    {{1,1,-1},{1,0,0,1},{0,1},{0,0,-1}},
    {{1,-1,-1},{0,0,0,1},{0,0},{0,0,-1}},
    //Left
    {{-1,-1,1},{1,0,0,1},{1,0},{-1,0,0}},
    {{-1,1,1},{0,1,0,1},{1,1},{-1,0,0}},
    {{-1,1,-1},{0,0,1,1},{0,1},{-1,0,0}},
    {{-1,-1,-1},{0,0,0,1},{0,0},{-1,0,0}},
    //Right
    {{1,-1,-1},{1,0,0,1},{1,0},{1,0,0}},
    {{1,1,-1},{0,1,0,1},{1,1},{1,0,0}},
    {{1,1,1},{0,0,1,1},{0,1},{1,0,0}},
    {{1,-1,1},{0,0,0,1},{0,0},{1,0,0}},
    //Top
    {{1,1,1},{1,0,0,1},{1,0},{0,1,0}},
    {{1,1,-1},{0,1,0,1},{1,1},{0,1,0}},
    {{-1,1,-1},{0,0,1,1},{0,1},{0,1,0}},
    {{-1,1,1},{0,0,0,1},{0,0},{0,1,0}},
    //Bottom
    {{1,-1,-1},{1,0,0,1},{1,0},{0,-1,0}},
    {{1,-1,1},{0,1,0,1},{1,1},{0,-1,0}},
    {{-1,-1,1},{0,0,1,1},{0,1},{0,-1,0}},
    {{-1,-1,-1},{0,0,0,1},{0,0},{0,-1,0}},
};

//Indices linking vertices to make the model.
//Each face is made of triangles linked by three vertices.
//Order of vertices matters, counter clockwise order faces the camera
const static GLubyte indices[] = {
    //Front
    0,1,2,
    2,3,0,
    //Back
    4,5,6,
    6,7,4,
    //Right
    8,9,10,
    10,11,8,
    //Left
    12,13,14,
    14,15,12,
    //Top
    16,17,18,
    18,19,16,
    //Bottom
    20,21,22,
    22,23,20
};

//Initiation method inherited from Model.m
- (instancetype) initWithShader:(BaseEffect *) shader
{
    //Initialize cube with shader and vertex data.
    if(self = [super initWithName:"asteroid"
                           shader:shader
                         vertices:(Vertex *)vertices
                      vertexCount:sizeof(vertices)/sizeof(vertices[0])
                          indices:indices
                       indexCount: sizeof(indices)/sizeof(indices[0])])
    {
        //Set texture from Resource folder
        [self loadTexture:@"green.png"];
        double randX = ((double)arc4random_uniform(51) - 25)/25;
        double randY = ((double)arc4random_uniform(51) - 25)/25;
        self.forward = GLKVector3Make(randX, randY, 0);
        self.destroy = false;
        self.size = 3;
        [self scaleWithSize];
    }
    return self;
}

//Initiation method inherited from Model.m
- (instancetype) initWithShader:(BaseEffect *) shader andSize:(int)size;
{
    //Initialize cube with shader and vertex data.
    if(self = [super initWithName:"asteroid"
                           shader:shader
                         vertices:(Vertex *)vertices
                      vertexCount:sizeof(vertices)/sizeof(vertices[0])
                          indices:indices
                       indexCount: sizeof(indices)/sizeof(indices[0])])
    {
        //Set texture from Resource folder
        [self loadTexture:@"green.png"];
        double randX = ((double)arc4random_uniform(51) - 25)/25;
        double randY = ((double)arc4random_uniform(51) - 25)/25;
        self.forward = GLKVector3Make(randX, randY, 0);
        self.destroy = false;
        self.size = size;
        [self scaleWithSize];
    }
    return self;
}

//Update method interited from Model.m
-(void)updateWithDelta:(NSTimeInterval)delta
{
    //Set velocity and translate position.
    GLKVector3 velocity = GLKVector3MultiplyScalar(_forward, 0.25);
    self.position = GLKVector3Add(self.position, velocity);
    
    //Check if asteroid is beyond bounds of the screen.
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
}


- (void) scaleWithSize
{
    if (self.size == 1) {
        self.scale = 0.7f;
    }
    if (self.size == 2) {
        self.scale = 1.0f;
    }
    if (self.size >= 3) {
        self.scale = 1.5f;
    }
}

@end
