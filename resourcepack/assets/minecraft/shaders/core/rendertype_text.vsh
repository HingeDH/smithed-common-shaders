#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

float offsets[9] = float[9](
    -2.0,
    -1.5,
    -1.0,
    -0.5,
     0.0,
     0.5,
     1.0,
     1.5,
     2.0
);

void main() {
    bool markerShadow = ivec2(Color.gb * 255. + 0.5) == ivec2(1, 62);

    if (markerShadow) {
        gl_Position = vec4(3.0, 3.0, 3.0, 1.0);
        return;
    }

    int p = int(Color.r * 255. + 0.5);
    ivec2 ioffset = ivec2(
        (p >> 4) & 0xf,
        p & 0xf
    );
    bool marker = ivec2(Color.gb * 255. + 0.5) == ivec2(4, 249)
        && ioffset.x < offsets.length()
        && ioffset.y < offsets.length();
    if (marker) {
        gl_Position = ProjMat * ModelViewMat * vec4(Position.xy, Position.z - 2.0, 1.0);

        vec2 offset = vec2(
            offsets[ioffset.x],
            offsets[ioffset.y]
        );

        gl_Position.xy += gl_Position.w * offset;
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    }

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = texelFetch(Sampler2, UV2 / 16, 0);
    if (marker)
        vertexColor.a *= Color.a;
    else
        vertexColor *= Color;
    texCoord0 = UV0;

    // NoShadow behavior (https://github.com/PuckiSilver/NoShadow)
    ivec3 iColor = ivec3(Color.xyz * 255 + vec3(0.5));
    if (iColor == ivec3(78, 92, 36) && (
        Position.z == 2200.03 || // Actionbar
        Position.z == 2400.06 || // Subtitle
        Position.z == 2400.12 || // Title
        Position.z == 50.03 ||   // Opened Chat
        Position.z == 2650.03 || // Closed Chat
        Position.z == 200.03 ||  // Advancement Screen
        Position.z == 400.03 ||  // Items
        Position.z == 1000.03 || // Bossbar
        Position.z == 2800.03 || // Scoreboard List
        Position.z == 2000       // Scoreboard Sidebar (Has no shadow, remove tint for consistency)
        )) { // Regular text
        vertexColor.rgb = texelFetch(Sampler2, UV2 / 16, 0).rgb; // Remove color from no shadow marker
    } else if (iColor == ivec3(19, 23, 9) && (
        Position.z == 2200 || // Actionbar
        Position.z == 2400 || // Subtitle | Title
        Position.z == 50 ||   // Opened Chat
        Position.z == 2650 || // Closed Chat
        Position.z == 200 ||  // Advancement Screen
        Position.z == 400 ||  // Items
        Position.z == 1000 || // Bossbar
        Position.z == 2800    // Scoreboard List
        )) { // Shadow
        gl_Position = vec4(2,2,2,1); // Move shadow off screen
    }
}
