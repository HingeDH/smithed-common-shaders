vec4 color = texture(Sampler0, texCoord0);
if (color.a < 0.1 || abs(mod(part + 0.5, 1.0) - 0.5) > 0.001) {
    discard;
}
if (color.a < 1.0 && part > 0.5) {
    vec4 color2 = texture(Sampler0, texCoord1);
    if (color.a < 0.75 && int(gl_FragCoord.x + gl_FragCoord.y) % 2 == 0) {
        discard;
    }
    else {
        color.rgb = mix(color2.rgb, color.rgb, min(1.0, color.a * 2));
        color.a = 1.0;
    }
}

color *= vertexColor * ColorModulator;
color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
if (part==0.0) {
    float alpha = textureLod(Sampler0, texCoord0, 0.0).a * 255.0;
    color = make_emissive(color, lightColor, maxLightColor, vertexDistance, alpha);
    color.a = remap_alpha(alpha) / 255.0;
} else
{
    color *= lightMapColor;
}
fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);