//
//  Model.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import "Vertex.h"

@import GLKit;

@class BaseEffect;

@interface Model : NSObject

@property (nonatomic, strong) BaseEffect *shader;
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic) float rotationX;
@property (nonatomic) float rotationY;
@property (nonatomic) float rotationZ;
@property (nonatomic) float scale;
@property (nonatomic) GLuint texture;

- (instancetype)initWithName:(char *)name
                      shader:(BaseEffect *)shader
                    vertices:(Vertex *)vertices
                 vertexCount:(unsigned int)vertexCount
                     indices:(GLubyte *)indices
                  indexCount:(unsigned int)indexCount;
- (void) renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix;
- (void) updateWithDelta:(NSTimeInterval)delta;
- (void) loadTexture:(NSString *)filename;

@end
