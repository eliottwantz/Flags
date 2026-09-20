//
//  TrophyGold.metal
//  Flags
//
//  Brushed-gold recolor with a travelling specular sheen for the victory trophy.
//  SPDX-License-Identifier: MIT
//

#include <metal_stdlib>
using namespace metal;

// Recolors the rendered glyph (expected white, coverage in `color.a`)
// as brushed gold. `time` is 0...1 and loops; `width`/`height` describe
// the view bounds so the ramp and sheen stay proportional.
[[ stitchable ]] half4 trophyGold(
    float2 position,
    half4 color,
    float time,
    float width,
    float height
) {
    if (color.a <= 0.001) {
        return color;
    }

    float2 uv = float2(position.x / max(width, 1.0), position.y / max(height, 1.0));

    // Vertical gold ramp: bright crown gold -> rich gold -> deep bronze.
    half3 crown  = half3(1.00, 0.87, 0.55);
    half3 gold   = half3(1.00, 0.71, 0.16);
    half3 bronze = half3(0.45, 0.27, 0.07);
    half3 base = mix(
        mix(crown, gold, smoothstep(0.0, 0.5, uv.y)),
        bronze,
        smoothstep(0.5, 1.0, uv.y)
    );

    // Fine brushed-metal striations.
    float brush = 0.965 + 0.035 * sin(position.y * 1.9 + sin(position.x * 0.11) * 3.0);

    // Diagonal specular band travelling across the cup.
    float sweep = fract((uv.x * 0.7 + uv.y * 0.7) - time);
    float sheen = smoothstep(0.0, 0.06, sweep) * (1.0 - smoothstep(0.06, 0.20, sweep));

    half3 rgb = base * half(brush) + half(sheen * 0.85) * half3(1.0, 0.98, 0.92);

    return half4(rgb, color.a);
}
