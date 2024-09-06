#pragma header

float threshold = 0.125; // Threshold for dithering (0.0045 found to be optimal)
uniform float intensity;
mat2 dither_2 = mat2(0.0, 1.0, 1.0, 0.0);

struct dither_tile {
    float height;
};

vec3 gb_color_0 = vec3(8.0, 24.0, 32.0) / 255.0;
vec3 gb_color_1 = vec3(52.0, 104.0, 86.0) / 255.0;
vec3 gb_color_2 = vec3(136.0, 192.0, 112.0) / 255.0;
vec3 gb_color_3 = vec3(224.0, 248.0, 208.0) / 255.0;

vec3 closest_gb(vec3 color) {
    vec3 colors[4];
    colors[0] = gb_color_0;
    colors[1] = gb_color_1;
    colors[2] = gb_color_2;
    colors[3] = gb_color_3;

    int best_i = 0;
    float best_d = distance(color, gb_color_0);

    for (int i = 1; i < 4; i++) {
        float dis = distance(colors[i], color);
        if (dis < best_d) {
            best_d = dis;
            best_i = i;
        }
    }
    return colors[best_i];
}

bool needs_dither(vec3 color) {
    float d0 = distance(color, gb_color_0);
    float d1 = distance(color, gb_color_1);
    float d2 = distance(color, gb_color_2);
    float d3 = distance(color, gb_color_3);

    float first_d = min(min(d0, d1), min(d2, d3));
    float second_d = max(max(min(d0, d1), min(d2, d3)), min(max(d0, d1), max(d2, d3)));

    return abs(first_d - second_d) <= threshold;
}

vec3 return_gbColor(vec3 sampleColor) {
    vec3 endColor;
    if (needs_dither(sampleColor)) {
        endColor = closest_gb(sampleColor);
    } else {
        endColor = closest_gb(sampleColor);
    }
    return endColor;
}

vec3 buried_eye_color = vec3(255.0, 0.0, 0.0) / 255.0;
vec3 buried_grave_color = vec3(121.0, 133.0, 142.0) / 255.0;
vec3 buried_wall_color = vec3(107.0, 130.0, 149.0) / 255.0;

void main() {
    vec4 sampleColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

    if (sampleColor.a != 0.0) {
        vec3 colorB = return_gbColor(sampleColor.rgb);
        vec4 newColor;
        if (sampleColor.rgb == buried_eye_color)
            colorB = gb_color_2;
        if (sampleColor.rgb == buried_grave_color)
            colorB = gb_color_2;
        if (sampleColor.rgb == buried_wall_color)
            colorB = gb_color_2;
        newColor = vec4(mix(sampleColor.rgb, colorB.rgb, intensity), sampleColor.a);
        gl_FragColor = newColor;
    } else {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}