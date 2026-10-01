#version 330

// ============================================================
//  PLASMA CONSTELLATION - pulsing orbs linked by electric arcs
//  Each orb listens to its own slice of the spectrum. The orbs
//  float in 3D, rotate, and morph between formations (sphere,
//  trefoil knot, armillary rings, lissajous cloud). Arcs crackle
//  between nearby orbs, with sparks racing along them. Louder
//  music = bigger orbs, wilder arcs, and more connections.
// ============================================================

in vec2 fragCoord;
out vec4 fragColor;

uniform float bars[512];
uniform int bars_count;
uniform vec3 u_resolution;
uniform float shader_time;

#define PI  3.14159265359
#define TAU 6.28318530718

// ---------------- tweakables ----------------
const float MORPH_TIME  = 7.0;    // seconds per formation
const float SPIN_SPEED  = 0.25;   // rotation speed
const float HUE_SPEED   = 0.02;   // color drift speed
const float ARC_WILD    = 1.0;    // arc jitter multiplier
const float LINK_RANGE  = 1.25;   // how close orbs must be to link (before bass boost)
// --------------------------------------------

const int N = 10;                 // number of orbs
const float GLOW_R = 0.12;        // arc glow reaches exactly zero at this distance

// arc brightness vs. distance: tight core + soft tail that fades smoothly to 0 at GLOW_R
float arcGlow(float d, float coreK, float tail) {
    float fall = 1.0 - smoothstep(0.0, GLOW_R, d);
    fall *= fall;
    return exp(-d * coreK) + tail / (d + 0.006) * fall;
}

float hash11(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise1(float x) {
    float i = floor(x);
    float f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(hash11(i), hash11(i + 1.0), f);
}

vec3 pal(float t) {
    return 0.55 + 0.45 * cos(TAU * (t + vec3(0.00, 0.15, 0.35)));
}

float getBar(float t) {
    float n = float(max(bars_count, 2));
    float x = clamp(t, 0.0, 1.0) * (n - 1.0);
    int i = int(floor(x));
    int j = min(i + 1, bars_count - 1);
    float f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(bars[i], bars[j], f);
}

float band(float a, float b) {
    float s = 0.0;
    for (int k = 0; k < 4; k++) s += getBar(mix(a, b, (float(k) + 0.5) / 4.0));
    return s * 0.25;
}

// ---------------- formations ----------------
vec3 shapePos(int s, int i) {
    float fi = float(i);
    float u = fi / float(N);
    if (s == 0) {
        // fibonacci sphere
        float y = 1.0 - 2.0 * (fi + 0.5) / float(N);
        float rad = sqrt(max(1.0 - y * y, 0.0));
        float phi = fi * 2.39996323;
        return vec3(cos(phi) * rad, y, sin(phi) * rad);
    } else if (s == 1) {
        // trefoil knot
        float a = u * TAU;
        return vec3(sin(a) + 2.0 * sin(2.0 * a),
                    cos(a) - 2.0 * cos(2.0 * a),
                    -sin(3.0 * a)) / 2.6;
    } else if (s == 2) {
        // armillary: two crossed rings
        float a = float(i / 2) * TAU / 5.0;
        if ((i & 1) == 0) return vec3(cos(a), sin(a), 0.0);
        return vec3(0.0, cos(a + 0.3), sin(a + 0.3));
    }
    // lissajous cloud
    return vec3(sin(fi * 1.7 + 1.0), cos(fi * 2.3), sin(fi * 3.1 + 2.0)) * 0.95;
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

// jagged electric strand between a and b. returns distance, t = position along strand
float strand(vec2 p, vec2 a, vec2 b, float seed, float amp, out float tOut) {
    vec2 ba = b - a;
    float len = max(length(ba), 1e-4);
    vec2 dir = ba / len;
    vec2 nrm = vec2(-dir.y, dir.x);
    vec2 pa = p - a;
    float s = dot(pa, dir);
    float perp = dot(pa, nrm);
    float dx = max(abs(s - len * 0.5) - len * 0.5, 0.0);
    float t = clamp(s / len, 0.0, 1.0);
    tOut = t;
    // cheap reject, avoids noise for most pixels
    if (abs(perp) > amp * 1.6 + GLOW_R || dx > GLOW_R) return 1e3;
    float env = sin(t * PI);
    float T = shader_time;
    float j = (noise1(t * len * 14.0 + seed + T * 7.0) - 0.5) * 2.0
            + (noise1(t * len * 36.0 + seed * 2.0 + T * 13.0) - 0.5) * 0.8;
    float off = j * amp * env;
    return length(vec2(perp - off, dx));
}

void main() {
    vec2 res = u_resolution.xy;
    vec2 p = (fragCoord * res - 0.5 * res) / res.y * 2.0;
    float T = shader_time;

    float bass   = band(0.00, 0.10);
    float mids   = band(0.10, 0.45);
    float highs  = band(0.45, 1.00);
    float energy = (bass * 1.4 + mids + highs) / 3.4;
    float hue = T * HUE_SPEED;
    float r = length(p);

    // ---------------- orb layout (computed per pixel, cheap) ----------------
    vec2  sp[N];   // screen position
    float sr[N];   // screen radius
    float sv[N];   // audio level
    vec3  p3[N];   // 3D position (for link distances)
    float sf[N];   // perspective factor

    float cyc = T / MORPH_TIME;
    int   sIdx = int(floor(cyc));
    float m = smoothstep(0.65, 1.0, fract(cyc));
    int   sA = sIdx % 4;
    int   sB = (sIdx + 1) % 4;

    float breathe = 1.0 + bass * 0.30;
    float yaw = T * SPIN_SPEED;
    float pitch = 0.45 + 0.25 * sin(T * 0.17);
    mat2 ry = rot(yaw);
    mat2 rx = rot(pitch);

    for (int i = 0; i < N; i++) {
        float fi = float(i);
        float v = getBar((fi + 0.5) / float(N));
        v = pow(v, 0.8);

        vec3 q = mix(shapePos(sA, i), shapePos(sB, i), m);
        // lively wobble + audio push
        q += 0.07 * vec3(sin(T * 0.9 + fi * 1.3), cos(T * 0.7 + fi * 2.1), sin(T * 1.1 + fi * 0.7));
        q *= breathe * (1.0 + v * 0.18);

        q.xz = ry * q.xz;
        q.yz = rx * q.yz;

        float zc = q.z + 3.2;
        float f = 1.0 / zc;
        sp[i] = q.xy * f * 3.7;
        sf[i] = f * 3.2;
        sr[i] = (0.030 + v * 0.055) * sf[i];
        sv[i] = v;
        p3[i] = q;
    }

    // ---------------- background ----------------
    vec3 col = vec3(0.008, 0.010, 0.022);
    col += pal(hue + 0.5) * exp(-r * 1.6) * (0.03 + 0.10 * energy);
    col += pal(hue + 0.1) * exp(-r * 6.0) * bass * 0.18;

    // parallax dust
    for (int L = 0; L < 2; L++) {
        float scale = (L == 0) ? 16.0 : 30.0;
        vec2 g = (p + vec2(T * 0.01 * float(L + 1), 0.0)) * scale + float(L) * 11.0;
        vec2 gi = floor(g);
        vec2 gf = fract(g) - 0.5;
        float rnd = hash21(gi);
        if (rnd > 0.92) {
            vec2 off = (vec2(hash21(gi + 3.1), hash21(gi + 7.7)) - 0.5) * 0.6;
            float tw = 0.5 + 0.5 * sin(T * (1.0 + rnd * 3.0) + rnd * 50.0);
            col += pal(rnd + hue) * smoothstep(0.08, 0.0, length(gf - off)) * tw * (0.15 + highs) * 0.6;
        }
    }

    // ---------------- electric links ----------------
    float range = LINK_RANGE + bass * 0.45;
    for (int i = 0; i < N; i++) {
        for (int j = i + 1; j < N; j++) {
            float d3 = distance(p3[i], p3[j]);
            float strength = 1.0 - smoothstep(range - 0.30, range, d3);
            if (strength < 0.01) continue;

            float seed = float(i * N + j) * 1.37;
            float pairV = 0.5 * (sv[i] + sv[j]);
            float amp = (0.025 + 0.11 * pairV) * ARC_WILD;
            float depth = 0.5 * (sf[i] + sf[j]);

            vec3 cI = pal(float(i) / float(N) * 0.7 + hue);
            vec3 cJ = pal(float(j) / float(N) * 0.7 + hue);

            float t;
            float d = strand(p, sp[i], sp[j], seed, amp, t);
            if (d < GLOW_R) {
                vec3 lc = mix(cI, cJ, t);
                float line = arcGlow(d, 260.0, 0.0035);
                float inten = strength * depth * (0.30 + pairV * 1.5);
                col += lc * line * inten;
                col += vec3(1.0) * exp(-d * 420.0) * inten * 0.35;   // hot white core

                // spark racing along the arc
                float ph = fract(T * (0.35 + 0.5 * hash11(seed)) + hash11(seed + 9.0));
                float spark = exp(-pow((t - ph) * 9.0, 2.0));
                col += mix(lc, vec3(1.0), 0.6) * spark * exp(-d * 140.0) * strength * (0.6 + pairV * 2.0);
            }

            // thinner secondary strand for a crackly feel
            float t2;
            float d2 = strand(p, sp[i], sp[j], seed + 50.0, amp * 0.7, t2);
            if (d2 < GLOW_R) {
                vec3 lc2 = mix(cI, cJ, t2);
                col += lc2 * arcGlow(d2, 300.0, 0.002) * strength * depth * (0.12 + pairV * 0.8);
            }
        }
    }

    // ---------------- orbs ----------------
    for (int i = 0; i < N; i++) {
        float v = sv[i];
        float dd = length(p - sp[i]);
        float rad = sr[i];
        vec3 c = pal(float(i) / float(N) * 0.7 + hue + v * 0.1);

        float glow = exp(-dd / (rad * 2.6)) * (0.45 + v * 1.2);
        float body = 1.0 - smoothstep(rad * 0.75, rad, dd);
        float core = exp(-dd / (rad * 0.5));
        // expanding shockwave ring that appears on loud hits
        float ringR = rad * (1.4 + v * 1.6);
        float shock = exp(-abs(dd - ringR) * (70.0 / sf[i])) * v * v;

        col += c * glow * 0.55;
        col += mix(c, vec3(1.0), 0.55) * body * (0.7 + v);
        col += vec3(1.0) * core * (0.25 + v * 0.8);
        col += c * shock * 1.4;
    }

    // ---------------- finish ----------------
    col *= 0.92 + energy * 0.45;
    col *= 1.0 - 0.45 * smoothstep(0.8, 2.0, r);
    col = 1.0 - exp(-col * 1.3);
    col = pow(col, vec3(0.92));

    fragColor = vec4(col, 1.0);
}
