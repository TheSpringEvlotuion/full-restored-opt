#pragma header

float threshold = 0.125; // Threshold for dithering (0.0045 found to be optimal)
uniform float intensity;
vec4 dither_2 = vec4(0.,1.,1.,0.);

struct dither_tile {
    float height;
};

void rgb_colors(out vec3 rgb_colors[4]) {
    rgb_colors[0] = vec3(8., 24., 32.) / 255.;
    rgb_colors[1] = vec3(52., 104., 86.) / 255.;
    rgb_colors[2] = vec3(136., 192., 112.) / 255.;
    rgb_colors[3] = vec3(224., 248., 208.) / 255.;
}

void rgb_colors_distance(vec3 color, out float distances[4]) {
    vec3 colors[4];
    rgb_colors(colors);
    
    distances[0] = distance(color, colors[0]);
    distances[1] = distance(color, colors[1]);
    distances[2] = distance(color, colors[2]);
    distances[3] = distance(color, colors[3]);
}

vec3 closest_rgb(vec3 color) {
    int best_i = 0;
    float best_d = 2.;

    vec3 colors[4];
    rgb_colors(colors);
    for (int i = 0; i < 4; i++) {
        float dis = distance(colors[i], color);
        if (dis < best_d) {
            best_d = dis;
            best_i = i;
        }
    }
    return colors[best_i];
}

void rgb_2_closest(vec3 color, out vec3 results[2]) {
 	float distances[4];
 	rgb_colors_distance(color, distances);

    int first_i = 0;
    float first_d = 2.;

    int second_i = 0;
    float second_d = 2.;

    for (int i = 0; i < 4; i++) {
        float d = distances[i];
        if (distances[i] <= first_d) {
            second_i = first_i;
            second_d = first_d;
            first_i = i;
            first_d = d;
        } else if (distances[i] <= second_d) {
            second_i = i;
            second_d = d;
        }
    }
    vec3 colors[4];
    rgb_colors(colors);

    if (first_i < second_i) {
        results[0] = colors[first_i];
        results[1] = colors[second_i];
    } else {
     	results[0] = colors[second_i];
      results[1] = colors[first_i];
    }
}

bool needs_dither(vec3 color) {
    float distances[4];
    rgb_colors_distance(color, distances);

    int first_i = 0;
    float first_d = 2.;

    int second_i = 0;
    float second_d = 2.;

    for (int i = 0; i < 4; i++) {
        float d = distances[i];
        if (d <= first_d) {
            second_i = first_i;
            second_d = first_d;
            first_i = i;
            first_d = d;
        } else if (d <= second_d) {
            second_i = i;
            second_d = d;
        }
    }
    return abs(first_d - second_d) <= threshold;
}

vec3 return_rgbColor(vec3 sampleColor) {
    vec3 endColor;
    vec3 closest_color[2];
    rgb_2_closest(sampleColor, closest_color);
    if (needs_dither(sampleColor)) {
        // more organization
        int cux = int(openfl_TextureCoordv.x);
        int cuy = int(openfl_TextureCoordv.y);
        endColor = vec3(closest_color[int(dither_2[cux * 2 + cuy])]);
    } else
        endColor = vec3(closest_rgb(texture2D(bitmap, openfl_TextureCoordv).rgb));
    return endColor;
}

vec3 buried_eye_color = vec3(255.0, 0.0, 0.0) / 255.0;
vec3 buried_grave_color = vec3(121.0, 133.0, 142.0) / 255.0;
vec3 buried_wall_color = vec3(107., 130., 149.) / 255.0;

void main() {
    vec4 sampleColor = texture2D(bitmap, openfl_TextureCoordv);
    /*if(intensity==0.0){
      gl_FragColor = sampleColor;
      return;
    }*/
    vec3 colors[4];
    rgb_colors(colors);
    if (sampleColor.a != 0.0) {
        vec3 colorB = return_rgbColor(sampleColor.rgb);
        vec4 newColor;
        if (sampleColor.rgb == buried_eye_color)
            colorB = colors[2];
        if (sampleColor.rgb == buried_grave_color)
            colorB = colors[2];
        if (sampleColor.rgb == buried_wall_color)
            colorB = colors[2];
        newColor = vec4(mix(sampleColor.rgb, colorB.rgb, intensity), sampleColor.a);
        gl_FragColor = newColor;
    } else
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);

    /*
    vec3 gbColor = vec3(closest_rgb(texture2D(bitmap, openfl_TextureCoordv).rgb));
    // Output to screen
    gl_FragColor = vec4(
        mix(texture2D(bitmap, openfl_TextureCoordv).rgb * texture2D(bitmap, openfl_TextureCoordv).a, gbColor.rgb, intensity),
        texture2D(bitmap, openfl_TextureCoordv).a
    );
    */
}
