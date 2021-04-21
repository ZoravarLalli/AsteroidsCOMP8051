
#import "PowerupModel.h"

@implementation PowerupModel

//Initiation method inherited from Model.m
- (instancetype) initWithShader:(ShaderController *) shader ship : (ShipModel *) ship
{
    //Initialize model with shader and vertex data.
    if(self = [super initWithName:"powerup"
                           shader:shader
                         vertices:(Vertex *)vertices
                      vertexCount:sizeof(vertices)/sizeof(vertices[0])])
    {
        //Set texture from Resources folder
        [self loadTexture:@"Star_03.png"];
        //Set random forward vector
        double randX = ((double)arc4random_uniform(51) - 25)/25;
        double randY = ((double)arc4random_uniform(51) - 25)/25;
        self.forward = GLKVector3Make(randX, randY, 0);
        self.destroy = false;
        self._ship = ship;
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
    if(self.position.x > _xBound) self.destroy = true;
    else if (self.position.x < _xBound * -1) self.destroy = true;
    else if (self.position.y > _yBound) self.destroy = true;
    else if (self.position.y < _yBound * -1) self.destroy = true;
    
    //Check for enemy collision
    if(__ship != nil
       && self.position.x + (3.2) >= __ship.position.x
       && self.position.x - (3.2) <= __ship.position.x
       && self.position.y + (3) >= __ship.position.y
       && self.position.y - (3) <= __ship.position.y)
    {
        __ship.powered = true;
        self.destroy = true;
    }
}

//Each face is defined by distinct vertices, repeated vertices needed for corners.
//Attributes orderd according to Vertex.h (position, color, tex coor, normal)
const static Vertex vertices[] = {
    //Front
    {{1,-1,1},{1,0,0,1},{1,0},{0,0,1}},
    {{1,1,1},{0,1,0,1},{1,1},{0,0,1}},
    {{-1,1,1},{0,0,1,1},{0,1},{0,0,1}},
    
    {{-1,1,1},{0,0,1,1},{0,1},{0,0,1}},
    {{-1,-1,1},{0,0,0,1},{0,0},{0,0,1}},
    {{1,-1,1},{1,0,0,1},{1,0},{0,0,1}},
};

@end
