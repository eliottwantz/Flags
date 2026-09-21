//
//  MedalShaders.metal
//  Flags
//
//  Brushed-metal recolors for medal scores.
//  Each function recolors the rendered glyph (expected white, coverage in
//  `color.a`). `width`/`height` describe the view bounds so the ramp stays
//  proportional.
//  SPDX-License-Identifier: MIT
//

#include <metal_stdlib>
using namespace metal;

half4 medalShade(
    float2 position,
    half4 color,
    float width,
    float height,
    half3 light,
    half3 mid,
    half3 dark
) {
    if (color.a <= 0.001) {
        return color;
    }

    float2 uv = float2(position.x / max(width, 1.0), position.y / max(height, 1.0));

    // Vertical metal ramp: bright edge -> rich metal -> deep shadow.
    half3 base = mix(
        mix(light, mid, smoothstep(0.0, 0.5, uv.y)),
        dark,
        smoothstep(0.5, 1.0, uv.y)
    );

    // Fine brushed-metal striations.
    float brush = 0.965 + 0.035 * sin(position.y * 1.9 + sin(position.x * 0.11) * 3.0);

    return half4(base * half(brush), color.a);
}

[[ stitchable ]] half4 medalGold(
    float2 position,
    half4 color,
    float width,
    float height
) {
    return medalShade(
        position, color, width, height,
        half3(1.00, 0.87, 0.55),
        half3(1.00, 0.71, 0.16),
        half3(0.45, 0.27, 0.07)
    );
}

[[ stitchable ]] half4 medalSilver(
    float2 position,
    half4 color,
    float width,
    float height
) {
    return medalShade(
        position, color, width, height,
        half3(0.97, 0.98, 1.00),
        half3(0.72, 0.75, 0.81),
        half3(0.32, 0.35, 0.42)
    );
}

[[ stitchable ]] half4 medalBronze(
    float2 position,
    half4 color,
    float width,
    float height
) {
    return medalShade(
        position, color, width, height,
        half3(1.00, 0.82, 0.58),
        half3(0.80, 0.50, 0.20),
        half3(0.38, 0.21, 0.08)
    );
}
