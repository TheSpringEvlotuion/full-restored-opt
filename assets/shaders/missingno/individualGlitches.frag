#pragma header

#version 100 es

precision mediump float;

uniform float binaryIntensity;
uniform sampler2D bitmap;

in vec2 openfl_TextureCoordv;
out vec4 fragColor;

void main() {
    vec2 uv = openfl_TextureCoordv.xy;

    float psize = 0.04 * binaryIntensity;
    float psq = 1.0 / psize;

    float px = floor(uv.x * psq + 0.5) * psize;
    float py = floor(uv.y * psq + 0.5) * psize;

    vec4 colSnap = texture2D(bitmap, vec2(px, py));

    float lum = pow(1.0 - (colSnap.r + colSnap.g + colSnap.b) / 3.0, binaryIntensity);

    float qsize = psize * lum;
    float qsq = 1.0 / qsize;

    float qx = floor(uv.x * qsq + 0.5) * qsize;
    float qy = floor(uv.y * qsq + 0.5) * qsize;

    float rx = (px - qx) * lum + uv.x;
    float ry = (py - qy) * lum + uv.y;

    fragColor = texture2D(bitmap, vec2(rx, ry));
}
