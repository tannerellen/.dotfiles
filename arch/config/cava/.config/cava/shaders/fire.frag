#version 330

// ---------------------------------------------------------------
//  Roaring Fire - audio reactive fragment shader for cava
//  - Flame height follows each bar
//  - Twist / sway grows with overall loudness and bass
//  - Embers drift upward, more of them when the music is intense
// ---------------------------------------------------------------

in vec2 fragCoord;
out vec4 fragColor;

// bar values 0..1
uniform float bars[512];
uniform int   bars_count;
uniform vec3  u_resolution;
uniform float shader_time;   // cava supplies time under this name
#define time shader_time

// ----- tweakables -----
const float FLAME_MIN      = 0.10;  // idle flame height (fraction of screen)
const float FLAME_MAX      = 0.90;  // height at full bar
const float RISE_SPEED     = 1.5;   // how fast flames scroll upward
const float TWIST_BASE     = 0.25;  // idle sway
const float TWIST_REACTIVE = 1.10;  // extra twist from music
const float EMBER_BASE     = 0.06;  // idle ember density
const float EMBER_REACTIVE = 0.35;  // extra ember density from music

// ----- noise helpers -----
float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash21(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(0.8, -0.6, 0.6, 0.8);
    for (int i = 0; i < 5; i++) {
        v += a * vnoise(p);
        p = rot * p * 2.03 + 11.7;
        a *= 0.5;
    }
    return v;
}

// ----- audio helpers -----
float barAt(int i) {
    i = clamp(i, 0, max(bars_count - 1, 0));
    return clamp(bars[i], 0.0, 1.0);
}

// smooth, interpolated bar value at horizontal position x (0..1)
float sampleBar(float x) {
    float f  = x * float(bars_count) - 0.5;
    int   i0 = int(floor(f));
    float t  = fract(f);
    t = t * t * (3.0 - 2.0 * t);
    return mix(barAt(i0), barAt(i0 + 1), t);
}

// wide blur so neighbouring bars merge into one organic flame body
float flameBar(float x) {
    float d = 1.5 / float(max(bars_count, 1));
    float s = sampleBar(x) * 2.0
            + sampleBar(x - d) + sampleBar(x + d)
            + 0.5 * (sampleBar(x - 2.0 * d) + sampleBar(x + 2.0 * d));
    return s / 5.0;
}

// ----- colour -----
vec3 fireColor(float t) {
    vec3 c = mix(vec3(0.0), vec3(0.45, 0.02, 0.0), smoothstep(0.00, 0.30, t));
    c = mix(c, vec3(1.00, 0.30, 0.02), smoothstep(0.25, 0.60, t));
    c = mix(c, vec3(1.00, 0.75, 0.15), smoothstep(0.55, 0.85, t));
    c = mix(c, vec3(1.00, 0.96, 0.75), smoothstep(0.85, 1.00, t));
    return c;
}

// ----- embers -----
// Each ember is an individual particle with a fixed speed that loops from the
// base of the fire to past the top of the screen. No grid, so no clipping.
vec3 embers(vec2 uv, float aspect, float energy) {
    vec3 acc = vec3(0.0);
    vec2 p = vec2(uv.x * aspect, uv.y);
    float density = (EMBER_BASE + EMBER_REACTIVE * energy) * 2.5;

    for (int l = 0; l < 3; l++) {
        float fl = float(l);
        for (int i = 0; i < 40; i++) {
            float id = float(i) + fl * 100.0;
            float r  = hash11(id * 1.37 + 0.5);

            // how visible this ember is (more of them appear as music gets louder)
            float vis = clamp((density - r) / 0.1, 0.0, 1.0);
            if (vis <= 0.0) continue;

            // constant speed per ember (screen heights per second)
            float speed = (0.20 + fl * 0.07) * (0.7 + 0.8 * hash11(id + 3.0));
            float cyc   = fract(hash11(id + 9.0) + time * speed);   // 0..1 lifetime
            float y     = cyc * 1.2 - 0.05;                         // ends above the top edge

            float baseX = hash11(id + 5.0);
            float x = baseX * aspect
                    + sin(time * (1.0 + 2.0 * r) + id) * 0.03
                    + sin(y * 7.0 + id) * 0.025;

            // favour spots where the flames are tall
            vis *= 0.35 + 0.65 * sampleBar(baseX);

            vec2 d = p - vec2(x, y);
            d.y *= 0.6;                                             // slight vertical streak
            float dist = length(d);

            float size = 0.0035 + 0.004 * hash11(id + 11.0);
            if (dist > size * 6.0) continue;

            float core = smoothstep(size, 0.0, dist);
            float g    = smoothstep(size * 6.0, 0.0, dist);
            float glow = g * g * 0.35;

            float flicker = 0.55 + 0.45 * sin(time * (7.0 + 9.0 * r) + r * 50.0);
            float fade = smoothstep(0.0, 0.08, y + 0.05) * (1.0 - smoothstep(0.80, 1.10, y));
            float depth = 1.0 - fl * 0.2;

            vec3 col = mix(vec3(1.0, 0.30, 0.04), vec3(1.0, 0.80, 0.30), hash11(id + 13.0));
            acc += col * (core + glow) * flicker * fade * vis * depth * 1.8;
        }
    }
    return acc;
}

void main() {
    vec2 uv = fragCoord.xy;                       // 0..1, origin bottom-left
    float aspect = (u_resolution.y > 0.0) ? u_resolution.x / u_resolution.y : 16.0 / 9.0;

    // ----- overall audio energy & bass -----
    float energy = 0.0;
    float bass   = 0.0;
    int   n      = min(bars_count, 512);
    int   bassN  = max(n / 8, 1);
    for (int i = 0; i < n; i++) {
        float b = bars[i];
        energy += b;
        if (i < bassN || i >= n - bassN) bass += b;   // handles mirrored stereo layout
    }
    energy = clamp(energy / float(max(n, 1)) * 1.8, 0.0, 1.0);
    bass   = clamp(bass / float(bassN * 2) * 1.4, 0.0, 1.0);

    // ----- per-column flame height -----
    float h = flameBar(uv.x);
    h = pow(clamp(h, 0.0, 1.0), 0.8);
    float flameH = mix(FLAME_MIN, FLAME_MAX, h);
    flameH *= 0.97 + 0.03 * sin(time * 3.0 + uv.x * 12.0);   // subtle flicker
    float y = uv.y / flameH;                                  // 0 at base, 1 at tip

    // ----- twisting / turbulent coordinates -----
    float twist = TWIST_BASE + TWIST_REACTIVE * (0.6 * energy + 0.4 * bass);
    vec2 p = vec2(uv.x * aspect * 3.0, uv.y * 2.6);
    float speed = RISE_SPEED;   // constant: speed changes would make time*speed jump

    // slow large-scale warp makes the flames lean and curl
    float warp = fbm(vec2(p.x * 0.6 + time * 0.25, p.y * 0.8 - time * 0.5));
    p.x += (warp - 0.5) * 2.0 * twist * (0.3 + uv.y * 2.0);
    p.x += sin(uv.y * 5.0 - time * 1.8 + uv.x * 6.0) * 0.35 * twist * uv.y;

    p.y -= time * speed;

    float n1 = fbm(p);
    float n2 = fbm(p * 2.1 + vec2(0.0, -time * 0.9) + n1 * 0.8);

    // ----- heat field -----
    float tips = 0.35 + 0.9 * y;                              // ragged edges toward the tip
    float heat = (1.0 - y) + (n1 - 0.45) * 0.9 * tips;
    heat *= 0.65 + 0.7 * n2;
    heat += (1.0 - smoothstep(0.0, 0.18, uv.y)) * 0.35;       // hot bed at the bottom
    heat = clamp(heat, 0.0, 1.0);
    heat = smoothstep(0.02, 0.95, heat);
    heat = pow(heat, 1.15);

    // ----- compose -----
    vec3 col = vec3(0.012, 0.004, 0.003);                     // dark room
    col += vec3(0.35, 0.07, 0.01) * exp(-uv.y * 3.5) * (0.25 + 0.75 * energy);  // ambient glow
    col += vec3(0.5, 0.12, 0.02) * exp(-abs(y - 0.6) * 2.0) * 0.05 * h;         // halo

    col += fireColor(heat) * smoothstep(0.0, 0.08, heat);
    col += embers(uv, aspect, energy);

    // gentle tone mapping
    col = col / (1.0 + col * 0.25);
    col = pow(col, vec3(0.95));

    fragColor = vec4(col, 1.0);
}
