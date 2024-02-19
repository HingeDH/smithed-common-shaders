#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform float FogStart;
uniform int FogShape;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightColor;
out vec4 maxLightColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord;
out vec3 Pos;
out float transition;
out vec2 texCoord0;
out vec2 texCoord1;
out vec4 normal_spd;
out float part;

flat out int isCustom;
flat out int isGUI;
flat out int isHand;
flat out int noshadow;
#moj_import <objmc_tools.glsl>

#define SPACING 1024.0
#define MAXRANGE (0.5 * SPACING)

const vec4[] subuvs = vec4[](
    vec4(4.0,  0.0,  8.0,  4.0 ), // 4x4x12
    vec4(8.0,  0.0,  12.0, 4.0 ),
    vec4(0.0,  4.0,  4.0,  16.0),
    vec4(4.0,  4.0,  8.0,  16.0),
    vec4(8.0,  4.0,  12.0, 16.0), 
    vec4(12.0, 4.0,  16.0, 16.0), 
    vec4(4.0,  0.0,  7.0,  4.0 ), // 4x3x12
    vec4(7.0,  0.0,  10.0, 4.0 ),
    vec4(0.0,  4.0,  4.0,  16.0),
    vec4(4.0,  4.0,  7.0,  16.0),
    vec4(7.0,  4.0,  11.0, 16.0), 
    vec4(11.0, 4.0,  14.0, 16.0),
    vec4(4.0,  0.0,  12.0, 4.0 ), // 4x8x12
    vec4(12.0,  0.0, 20.0, 4.0 ),
    vec4(0.0,  4.0,  4.0,  16.0),
    vec4(4.0,  4.0,  12.0, 16.0),
    vec4(12.0, 4.0,  16.0, 16.0),
    vec4(16.0, 4.0,  24.0, 16.0)
);

const vec2[] origins = vec2[](
    vec2(40.0, 16.0), // right arm
    vec2(40.0, 32.0),
    vec2(32.0, 48.0), // left arm
    vec2(48.0, 48.0),
    vec2(16.0, 16.0), // torso
    vec2(16.0, 32.0),
    vec2(0.0,  16.0), // right leg
    vec2(0.0,  32.0),
    vec2(16.0, 48.0), // left leg
    vec2(0.0,  48.0)
);

void main() {
    Pos = Position;
    texCoord = UV0;
    overlayColor = texelFetch(Sampler1, UV1, 0);
    lightColor = minecraft_sample_lightmap(Sampler2, UV2);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);

    maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    
    vec3 normal = (ProjMat * ModelViewMat * vec4(Normal, 0.0)).rgb;

    //objmc
    #define ENTITY
    #define HEAD
    #moj_import<objmc_head.glsl>

    if (isCustom != 0) {
        gl_Position = ProjMat * ModelViewMat * (vec4(Pos, 1.0));
        vertexDistance = fog_distance(Pos, FogShape);
    } else {
        #moj_import<spd_vsh.glsl>
    }

}