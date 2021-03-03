//
//  Model.m
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import "Model.h"
#import "BaseEffect.h"

@implementation Model
{
    char *_name;
    GLuint _vao;
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    unsigned int _vertexCount;
    unsigned int _indexCount;
    BaseEffect *_shader;
}

//Initiation function
- (instancetype)initWithName:(char *)name
                      shader:(BaseEffect *)shader
                    vertices:(Vertex *)vertices
                 vertexCount:(unsigned int)vertexCount
                     indices:(GLubyte *)indices
                  indexCount:(unsigned int)indexCount
{
    if(self == [super init])
    {
        //Set input variables
        _name = name;
        _vertexCount = vertexCount;
        _indexCount = indexCount;
        _shader = shader;
        
        //Set initial transform values
        self.position = GLKVector3Make(0, 0, 0);
        self.rotationX = 0;
        self.rotationY = 0;
        self.rotationZ = 0;
        self.scale = 1.0;
        
        //Generate and bind vertex array
        glGenVertexArraysOES(1, &_vao);
        glBindVertexArrayOES(_vao);
        
        //Generate vertex buffer
        glGenBuffers(1, &_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(Vertex), vertices, GL_STATIC_DRAW);
        
        //Generate index buffer
        glGenBuffers(1, &_indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(GLubyte), indices, GL_STATIC_DRAW);
        
        //Enable vertex attributes
        glEnableVertexAttribArray(VertexAttribPosition);
        glVertexAttribPointer(VertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Position));
        glEnableVertexAttribArray(VertexAttribColor);
        glVertexAttribPointer(VertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Color));
        glEnableVertexAttribArray(VertexAttribTexCoord);
        glVertexAttribPointer(VertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, TexCoord));
        glEnableVertexAttribArray(VertexAttribNormal);
        glVertexAttribPointer(VertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid *)offsetof(Vertex, Normal));
        
        //Unbind vertex objects, bind vertex and index buffers.
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }
    return self;
}

//Set local model matrix
- (GLKMatrix4) modelMatrix
{
    //Identiy matrix
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    //Apply translation matrix
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
    //Apply rotation angle to each axis
    modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationX, 1, 0, 0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationZ, 0, 0, 1);
    //Apply scaling matrix
    modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, self.scale);
    return modelMatrix;
}

//Called to render the model on each update
- (void) renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix;
{
    //Translate model local position to world position
    GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, [self modelMatrix]);
    //Set the model view for the shader
    _shader.modelViewMatrix = modelViewMatrix;
    //Set the texture for the shader
    _shader.texture = self.texture;
    //Send texture and model data for shading.
    [_shader prepareToDraw];
    
    //Bind the vertex array object, draw the faces, unbind object.
    glBindVertexArrayOES(_vao);
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_BYTE, 0);
    glBindVertexArrayOES(0);
}

//Update function to be inherited, does nothing here
- (void) updateWithDelta:(NSTimeInterval)delta
{
}

//Loads a texture from Resource file
- (void) loadTexture:(NSString *)filename
{
    //Resource path for texture
    NSString *path = [[NSBundle mainBundle] pathForResource:filename
                                                     ofType:nil];
    //Sets origin of the texture to the bottom left of a face (0,0).
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@YES};
    //Stores error output
    NSError *error;
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path
                                                               options:options
                                                                 error:&error];
    //Check for errors after loading texture.
    if(info == nil)
    {
        NSLog(@"Error loading file: %@", error.localizedDescription);
    }
    else
    {
        self.texture = info.name;
    }
}

@end
