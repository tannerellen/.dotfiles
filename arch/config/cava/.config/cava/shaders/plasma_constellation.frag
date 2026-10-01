#version 330

// ============================================================
//  PLASMA CONSTELLATION v2
//  Everything from v1 (orbs linked by electric arcs, morphing 3D
//  formations) plus:
//    - orbs are shaded spheres with swirling plasma interiors,
//      rim light and a specular glint
//    - tilted orbital rings with a bead racing around each orb
//    - anamorphic lens-flare streaks when an orb hits hard
//    - a volumetric nebula that is actually lit by the orbs
//    - flickering arcs, a bass shock ring, and dither for smooth gradients
//  Each new layer has an amount constant below (set to 0.0 to disable).
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
const float GLOW_R      = 0.12;   // arc glow reaches exactly zero at this distance

const float NEBULA_AMT  = 1.0;    // lit nebula clouds
const float RING_AMT    = 0.0;    // orbital rings + beads
const float FLARE_AMT   = 1.0;    // lens flare streaks on loud hits
const float SHOCK_AMT   = 1.0;    // bass shock ring
const float FLICKER_AMT = 1.0;    // electric arc flicker
// --------------------------------------------

const int N = 10;                 // number of orbs

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

float fbm(vec2 x) {
    float a = 0.5;
    float s = 0.0;
    for (int i = 0; i < 4; i++) {
        s += a * vnoise(x);
        x = x * 2.03 + vec2(17.3, 9.1);
        a *= 0.5;
    }
    return s;
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

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
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

// arc brightness vs. distance: tight core + soft tail that fades smoothly to 0 at GLOW_R
float arcGlow(float d, float coreK, float tail) {
    float fall = 1.0 - smoothstep(0.0, GLOW_R, d);
    fall *= fall;
    return exp(-d * coreK) + tail / (d + 0.006) * fall;
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
    // cheap reject (glow is exactly zero beyond GLOW_R, so no visible box edge)
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

    // ---------------- orb layout ----------------
    vec2  sp[N];   // screen position
    float sr[N];   // screen radius
    float sv[N];   // audio level
    vec3  p3[N];   // 3D position (for link distances)
    float sf[N];   // perspective factor
    vec3  sc[N];   // orb color

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
        sc[i] = pal(fi / float(N) * 0.7 + hue + v * 0.1);
    }

    // ---------------- background ----------------
    vec3 col = vec3(0.008, 0.010, 0.022);
    col += pal(hue + 0.5) * exp(-r * 1.6) * (0.03 + 0.10 * energy);
    col += pal(hue + 0.1) * exp(-r * 6.0) * bass * 0.18;

    // nebula clouds, lit by the orbs themselves
    if (NEBULA_AMT > 0.0) {
        vec2 w = p * 1.5 + vec2(T * 0.03, -T * 0.02);
        float n = fbm(w + 1.6 * vec2(fbm(w + T * 0.05), fbm(w + 7.3 - T * 0.04)));
        float cloud = smoothstep(0.35, 0.80, n);
        cloud = pow(cloud, 1.4);

        vec3 lightAcc = vec3(0.0);
        for (int i = 0; i < N; i++) {
            vec2 dv = p - sp[i];
            lightAcc += sc[i] * (0.20 + sv[i] * 1.6) * sf[i] / (1.0 + 10.0 * dot(dv, dv));
        }
        col += cloud * (lightAcc * 0.35 + pal(hue + 0.55) * 0.035) * NEBULA_AMT;
    }

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

    // bass shock ring rolling outward from the center
    if (SHOCK_AMT > 0.0) {
        float ph = fract(T * 0.35);
        float sring = exp(-abs(r - ph * 2.3) * 16.0) * (1.0 - ph) * bass * bass;
        col += pal(hue + 0.3) * sring * 0.35 * SHOCK_AMT;
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

            // electric flicker
            float flick = 1.0 - FLICKER_AMT * 0.30 * noise1(T * 22.0 + seed * 3.0);

            vec3 cI = sc[i];
            vec3 cJ = sc[j];

            float t;
            float d = strand(p, sp[i], sp[j], seed, amp, t);
            if (d < GLOW_R) {
                vec3 lc = mix(cI, cJ, t);
                float line = arcGlow(d, 260.0, 0.0035);
                float inten = strength * depth * (0.30 + pairV * 1.5) * flick;
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
                col += lc2 * arcGlow(d2, 300.0, 0.002) * strength * depth * (0.12 + pairV * 0.8) * flick;
            }
        }
    }

    // ---------------- orbs ----------------
    for (int i = 0; i < N; i++) {
        float fi = float(i);
        float v = sv[i];
        vec2 dv = p - sp[i];
        float dd = length(dv);
        float rad = sr[i];
        vec3 c = sc[i];

        // soft outer glow + hot core + shockwave ring (as before)
        float glow = exp(-dd / (rad * 2.6)) * (0.45 + v * 1.2);
        float core = exp(-dd / (rad * 0.5));
        float ringR = rad * (1.4 + v * 1.6);
        float shock = exp(-abs(dd - ringR) * (70.0 / sf[i])) * v * v;
        col += c * glow * 0.50;
        col += vec3(1.0) * core * (0.20 + v * 0.7);
        col += c * shock * 1.4;

        vec2 lp = dv / rad;   // orb-local coordinates (radius = 1)
        float l2 = dot(lp, lp);

        // shaded sphere with swirling plasma interior
        if (l2 < 1.2) {
            float edge = 1.0 - smoothstep(0.90, 1.0, sqrt(l2));
            float z = sqrt(max(1.0 - l2, 0.0));
            vec3 nrm = vec3(lp, z);
            float diff = clamp(dot(nrm, normalize(vec3(-0.4, 0.5, 0.75))), 0.0, 1.0);
            float fres = pow(1.0 - z, 2.5);

            vec2 lq = rot(T * 1.2 + fi) * lp;
            float pl = vnoise(lq * 3.5 + vec2(T * 0.6, fi * 3.7)) * 0.6
                     + vnoise(lq * 7.0 - vec2(T * 1.1, fi)) * 0.4;

            vec3 surf = mix(c * 0.55, mix(c, vec3(1.0), 0.75), clamp(pl * pl * 1.8, 0.0, 1.0));
            surf *= 0.45 + 0.85 * diff;
            surf += c * fres * 1.3;                          // rim light
            surf += vec3(1.0) * pow(diff, 24.0) * 0.6;       // specular glint
            col += surf * edge * (0.75 + v);
        }

        // tilted orbital ring with a bead
        if (RING_AMT > 0.0 && dd < rad * 5.0) {
            float ang = T * (0.45 + 0.1 * fi) + fi * 1.9;
            float tilt = 0.30 + 0.28 * sin(T * 0.4 + fi * 1.3);
            vec2 lr = rot(ang) * lp;
            float e = length(vec2(lr.x, lr.y / tilt));
            float R = 2.4 + v * 0.8;
            float ringI = exp(-abs(e - R) * 9.0) * (0.12 + v * 0.9);

            float th = T * (1.6 + 0.2 * fi) + fi;
            vec2 bead = vec2(cos(th), tilt * sin(th)) * R;
            float bd = length(lr - bead);
            float beadI = exp(-bd * 5.0) * (0.3 + v * 1.5);

            col += (c * ringI + mix(c, vec3(1.0), 0.7) * beadI) * RING_AMT * 0.55;
        }

        // anamorphic lens flare streak on loud hits
        if (FLARE_AMT > 0.0) {
            float hit = smoothstep(0.50, 0.95, v);
            if (hit > 0.0) {
                float sh = exp(-abs(dv.y) / (rad * 0.22)) * exp(-abs(dv.x) / (rad * 11.0));
                float sv2 = exp(-abs(dv.x) / (rad * 0.18)) * exp(-abs(dv.y) / (rad * 4.0));
                col += mix(c, vec3(1.0), 0.5) * (sh + sv2 * 0.5) * hit * 0.55 * FLARE_AMT;
            }
        }
    }

    // ---------------- finish ----------------
    col *= 0.92 + energy * 0.45;
    col *= 1.0 - 0.45 * smoothstep(0.8, 2.0, r);
    col = 1.0 - exp(-col * 1.3);
    col = pow(col, vec3(0.92));

    // dither to avoid banding in the dark gradients
    col += (hash21(fragCoord * res + fract(T)) - 0.5) / 160.0;

    fragColor = vec4(col, 1.0);
}
