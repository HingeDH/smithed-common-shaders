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
in vec2 texCoord2;
in vec3 Pos;
in float transition;

flat in int isCustom;
flat in int isGUI;
flat in int isHand;
flat in int noshadow;

in vec4 maxLightColor;
in float zpos;

in vec4 iPositionV0;
in vec4 iPositionV1;
in vec4 iPositionV2;

flat in vec3 iNormal;

out vec4 fragColor;

void main() {
    vec2 mTexCoord = texCoord;
    vec2 samplerSize = vec2(textureSize(Sampler0, 0));
    vec2 oneTexel = 1./samplerSize;
    ivec4 marker_s32_0 = ivec4(textureLod(Sampler0, mTexCoord + vec2(32.0, 0.0) * oneTexel, 0.0) * 255. + 0.5);

    if (marker_s32_0.a == 242 && 0 < marker_s32_0.b && marker_s32_0.b < 4) {
        vec2 backgroundTexCoord = mTexCoord + vec2(16.0, 0.0) * oneTexel;

        if (marker_s32_0.b < 2)
            mTexCoord = backgroundTexCoord;
        else {
            vec3 corner0 = iPositionV0.xyz / iPositionV0.w;
            vec3 corner1 = iPositionV1.xyz / iPositionV1.w;
            vec3 corner2 = iPositionV2.xyz / iPositionV2.w;

            vec3 Tangent = normalize(corner1 - corner2);
            vec3 Bitangent = normalize(corner0 - corner2);
            vec3 Normal = normalize(cross(Tangent, Bitangent));

            float n = sign(dot(Normal, iNormal));

            if (n == -1.0) {
                vec3 v = Tangent;
                Tangent = -Bitangent;
                Bitangent = -v;
                Normal = -Normal;
            }

            mat3 TBN = mat3(Tangent, Bitangent, Normal);

            vec3 center = ((corner0 + corner1) * .5) * TBN;
            center.y *= -1.0;
            vec2 scleraSize = 16. * vec2(marker_s32_0) / 255.;
            vec2 pupilOffset = 0.0625 * round(normalize(center.xy) * min(scleraSize, scleraSize * length(center.xy) / abs(center.z)));

            vec2 uvMin;
            vec2 pupilUV = modf(mTexCoord * samplerSize / 16., uvMin);

            pupilUV += pupilOffset;
            pupilUV = uvMin + fract(pupilUV);
            vec2 pupilTexCoord = pupilUV * 16. / samplerSize;
            float pupilMask = textureLod(Sampler0, (pupilUV * 16.0 + vec2(32.0, 0.0)) / samplerSize, 0.0).b;

            mTexCoord = pupilMask*255. < 2.5
                ? backgroundTexCoord
                : pupilTexCoord;
        }
    }
    vec4 color = mix(texture(Sampler0, mTexCoord), texture(Sampler0, texCoord2), transition);
    float alpha = textureLod(Sampler0, mTexCoord, 0.0).a * 255.;

    // Switch used parts of the texture depending on where the model is displayed
    if (isGUI == 0 && check_alpha(alpha, 253.0)) discard;
    if (isGUI == 1) {
             if (zpos  > 100.0 && check_alpha(alpha, 254.0)) discard;
        else if (zpos <= 100.0 && check_alpha(alpha, 253.0)) discard; // inventory doll: Treat as if outside GUI
    }
    
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);

    //custom lighting
    #define ENTITY
    #moj_import <objmc_light.glsl>
    
    if (color.a < 0.01) {discard;}

    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
	color.a = remap_alpha(alpha) / 255.0;
    color.a *= vertexColor.a;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}