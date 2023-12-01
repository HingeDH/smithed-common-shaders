#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>
#moj_import <emissive_utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightColor;
in vec4 overlayColor;
in vec2 texCoord;
in vec3 Pos;
in float transition;

flat in int isCustom;
flat in int isGUI;
flat in int isHand;
flat in int noshadow;

in vec4 maxLightColor;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord);
    float alpha = textureLod(Sampler0, texCoord, 0.0).a * 255.;

    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    //custom lighting
    #define ENTITY
    #define HEAD
    #moj_import<objmc_light.glsl>

    if (color.a < 0.01) discard;

    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;
    color.a *= vertexColor.a;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}