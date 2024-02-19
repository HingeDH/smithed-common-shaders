ivec2 dim = textureSize(Sampler0, 0);
if (ProjMat[2][3] == 0.0 || dim.x != 64 || dim.y != 64) { // short circuit if cannot be player
    part = 0.0;
    texCoord0 = UV0;
    texCoord1 = vec2(0.0);

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightColor = minecraft_sample_lightmap(Sampler2, UV2);
    maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal_spd = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
else {
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, normalize(Normal), Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    normal_spd = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    vec3 wpos = Position;
    vec2 UVout = UV0;
    vec2 UVout2 = vec2(0.0);
    int partId = -int((wpos.y - MAXRANGE) / SPACING);

    part = float(partId);

    if (partId == 0) { // higher precision position if no translation is needed
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

        vertexDistance = fog_distance(wpos, FogShape);
        vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
        lightColor = minecraft_sample_lightmap(Sampler2, UV2);
        maxLightColor = minecraft_sample_lightmap(Sampler2, ivec2(240.0, 240.0));
        overlayColor = texelFetch(Sampler1, UV1, 0);
        texCoord0 = UV0;
        normal_spd = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    }
    else {
        vec4 samp1 = texture(Sampler0, vec2(54.0 / 64.0, 20.0 / 64.0));
        vec4 samp2 = texture(Sampler0, vec2(55.0 / 64.0, 20.0 / 64.0));
        bool slim = samp1.a == 0.0 || (((samp1.r + samp1.g + samp1.b) == 0.0) && ((samp2.r + samp2.g + samp2.b) == 0.0) && samp1.a == 1.0 && samp2.a == 1.0);
        int outerLayer = (gl_VertexID / 24) % 2; 
        int faceId = (gl_VertexID % 24) / 4;
        int vertexId = gl_VertexID % 4;
        int subuvIndex = faceId;

        wpos.y += SPACING * partId;
        gl_Position = ProjMat * ModelViewMat * vec4(wpos, 1.0);
        
        UVout = origins[2 * (partId - 1) + outerLayer];
        UVout2 = origins[2 * (partId - 1)];

        if (slim && (partId == 1 || partId == 2)) {
            subuvIndex += 6;
        }
        else if (partId == 3) {
            subuvIndex += 12;
        }

        vec4 subuv = subuvs[subuvIndex];

        vec2 offset = vec2(0.0);
        if (faceId == 1) {
            if (vertexId == 0) {
                offset += subuv.zw;
            }
            else if (vertexId == 1) {
                offset += subuv.xw;
            }
            else if (vertexId == 2) {
                offset += subuv.xy;
            }
            else {
                offset += subuv.zy;
            }
        }
        else {
            if (vertexId == 0) {
                offset += subuv.zy;
            }
            else if (vertexId == 1) {
                offset += subuv.xy;
            }
            else if (vertexId == 2) {
                offset += subuv.xw;
            }
            else {
                offset += subuv.zw;
            }
        }

        UVout += offset;
        UVout2 += offset;
        UVout /= 64.0;
        UVout2 /= 64.0;

        vertexDistance = fog_distance(wpos, FogShape);
    }

    texCoord0 = UVout;
    texCoord1 = UVout2;
}