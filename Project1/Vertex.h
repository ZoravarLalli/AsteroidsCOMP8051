//
//  Vertext.h
//  Project1
//
//  Created by Kris Olsson on 2021-02-24.
//

//Attributes of each vertex defined in Models
typedef enum
{
    VertexAttribPosition = 0,
    VertexAttribColor,
    VertexAttribTexCoord,
    VertexAttribNormal,
}VertexAttributes;

typedef struct
{
    GLfloat Position[3]; //Each position has x, y, z for co-ordinates
    GLfloat Color[4]; // Color has rgb and alpha values
    GLfloat TexCoord[2]; //x-y co-ordinates for texture mapping
    GLfloat Normal[3]; //3D Vector for normal of a face
}Vertex;
