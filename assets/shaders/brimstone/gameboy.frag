#pragma header

/*
 *
 * Sources!
 * https://www.shadertoy.com/view/ttlfzj
 *
 */

uniform float interpolation = 0.5;

float threshold = 0.125;
vec4 dither_2 = vec4(0.,1.,1.,0.);

struct dither_tile {
    float height;
};

vec3 tex2D(sampler2D _tex,vec2 _p)
{
    vec3 col=texture2D(_tex,_p).xyz;
    if(.5<abs(_p.x-.5)){
        col=vec3(.1);
    }
    return col;
}

void gb_colors(out vec3 gb_colors[4]) {
    gb_colors[0] = vec3(8., 24., 32.) / 255.;
    gb_colors[1] = vec3(52., 104., 86.) / 255.;
    gb_colors[2] = vec3(136., 192., 112.) / 255.;
    gb_colors[3] = vec3(224., 248., 208.) / 255.;
}

void rgb_colors_distance(vec3 color, out float distances[4]) {
    vec3 colors[4];
    gb_colors(colors);
    
    distances[0] = distance(color, colors[0]);
    distances[1] = distance(color, colors[1]);
    distances[2] = distance(color, colors[2]);
    distances[3] = distance(color, colors[3]);
}

vec3 closest_gb(vec3 color) {
    int best_i = 0;
    float best_d = 2.;

    vec3 colors[4];
    gb_colors(colors);

    for (int i = 0; i < 4; i++) {
        float dis = distance(colors[i], color);;
        if (dis < best_d) {
            best_d = dis;
            best_i = i;
        }
    }
    return colors[best_i];
}

vec2 get_tile_sample(vec2 coords, vec2 res) {
    return floor(coords * res / 2.) * 2. / res;
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
    gb_colors(colors);
    
    if (first_i < second_i) {
        result[0] = colors[first_i];
        result[1] = colors[second_i];
    } else {
     	result[0] = colors[second_i];
      result[1] = colors[first_i];
    }
}

bool needs_dither(vec3 color) {
    float distances[4];
    gb_colors_distance(color, distances);

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

vec3 return_gbColor(vec3 sampleColor) {
    vec3 endColor;
    if (needs_dither(sampleColor)) {
        int cux = int(openfl_TextureCoordv.x);
        int cuy = int(openfl_TextureCoordv.y);
        endColor = vec3(closest_color[int(dither_2[cux * 2 + cuy])]);
    } else
        endColor = vec3(closest_gb(tex2D(bitmap, openfl_TextureCoordv).xyz));
    return endColor;
}

vec3 buried_eye_color = vec3(255.0, 0.0, 0.0) / 255.0;
vec3 buried_grave_color = vec3(121.0, 133.0, 142.0) / 255.0;

void main() {

    vec4 color = texture2D(bitmap, openfl_TextureCoordv);
    if(interpolation==0.0){
      gl_FragColor = color;
      return;
    }

    vec3 sampleColor = color.xyz;
    // gb colors
    vec3 colors[4];
    gb_colors(colors);
    if (color.a != 0.0) {
        vec3 colorA = sampleColor;
        vec3 colorB = return_gbColor(sampleColor);

        vec3 newColor;
        // if colorA is just buried alive's fucking eye
        if (colorA == buried_eye_color)
            colorB = colors[2];
        if (colorA == buried_grave_color)
            colorB = colors[2];
        newColor = mix(colorA, colorB, interpolation);
        gl_FragColor = vec4(newColor, 1.0) * color.a;
    } else
        gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
}

/*
 *
 */
