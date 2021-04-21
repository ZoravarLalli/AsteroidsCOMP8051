
#import "BackgroundModel.h"

@implementation BackgroundModel

//Initiation method inherited from Model.m
- (instancetype) initWithShader:(ShaderController *) shader
{
    //Initialize model with shader and vertex data.
    if(self = [super initWithName:"bg"
                           shader:shader
                         vertices:(Vertex *)vertices
                      vertexCount:sizeof(vertices)/sizeof(vertices[0])])
    {
        //Set texture from Resources folder
        [self loadTexture:@"bg.jpg"];
    }
    return self;
}

//Update method interited from Model.m
-(void)updateWithDelta:(NSTimeInterval)delta
{
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
