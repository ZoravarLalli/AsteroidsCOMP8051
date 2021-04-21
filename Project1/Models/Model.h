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

@class ShaderController;

@interface Model : NSObject

@property (nonatomic, strong) ShaderController *shader;
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic) float rotationX;
@property (nonatomic) float rotationY;
@property (nonatomic) float rotationZ;
@property (nonatomic) float scale;
@property (nonatomic) GLuint texture;

- (instancetype)initWithName:(char *)name
                      shader:(ShaderController *)shader
                    vertices:(Vertex *)vertices
                 vertexCount:(unsigned int)vertexCount;
- (void) renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix;
- (void) updateWithDelta:(NSTimeInterval)delta;
- (void) loadTexture:(NSString *)filename;

@end
