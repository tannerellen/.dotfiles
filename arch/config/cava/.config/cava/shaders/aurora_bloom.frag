#version 330

// ============================================================
//  AURORA BLOOM - a radial, mirrored, glowing cava visualizer
//  Bass pulses the ring and nebula, mids/highs fire the spikes,
//  stars twinkle with the treble. Colors drift slowly over time.
// ============================================================

in vec2 fragCoord;
out vec4 fragColor;

// bar values (0..1), only the first bars_count entries are valid
uniform float bars[512];
uniform int bars_count;

// window resolution
uniform vec3 u_resolution;

// time in seconds
uniform float shader_time;

#define PI  3.14159265359
#define TAU 6.28318530718

// ---------------- tweakables ----------------
const float SPIKES      = 44.0;   // number of angular bands (per half, mirrored)
const float RING_RADIUS = 0.36;   // base ring radius
const float SPIKE_LEN   = 0.50;   // max outward spike length
const float ROTATION    = 0.10;   // rotation speed
const float HUE_SPEED   = 0.025;  // how fast colors drift
// --------------------------------------------

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// smooth cosine palette
vec3 pal(float t) {
    return 0.55 + 0.45 * cos(TAU * (t + vec3(0.00, 0.12, 0.28)));
}

// smoothly interpolated bar lookup, t in 0..1
float getBar(float t) {
    float n = float(max(bars_count, 2));
    float x = clamp(t, 0.0, 1.0) * (n - 1.0);
    int i = int(floor(x));
    int j = min(i + 1, bars_count - 1);
    float f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    return mix(bars[i], bars[j], f);
}

// average a band of the spectrum with a few samples
float band(float a, float b) {
    float s = 0.0;
    for (int k = 0; k < 4; k++) {
        s += getBar(mix(a, b, (float(k) + 0.5) / 4.0));
    }
    return s * 0.25;
}

void main() {
    vec2 res = u_resolution.xy;
    vec2 p = (fragCoord * res - 0.5 * res) / res.y * 2.0; // y in -1..1
    float T = shader_time;

    // ---- audio summary ----
    float bass   = band(0.00, 0.10);
    float mids   = band(0.10, 0.45);
    float highs  = band(0.45, 1.00);
    float energy = (bass * 1.4 + mids + highs) / 3.4;

    float hue = T * HUE_SPEED;
    float r = length(p);

    // ---------------- background nebula ----------------
    vec2 q = p;
    for (int i = 0; i < 4; i++) {
        float fi = float(i);
        q += 0.35 * vec2(sin(q.y * 2.1 + T * 0.30 + fi * 1.7),
                         cos(q.x * 2.3 + T * 0.25 + fi * 2.3));
    }
    float neb = 0.5 + 0.5 * sin(length(q) * 3.2 - T * 0.4 + bass * 3.0);
    neb = pow(neb, 3.0);
    vec3 col = pal(neb * 0.35 + hue + 0.55) * neb * (0.06 + 0.30 * energy);

    // bass ripples rolling outward
    float ripple = 0.5 + 0.5 * sin(r * 26.0 - T * 3.0 - bass * 6.0);
    col += pal(hue + r * 0.4 + 0.2) * pow(ripple, 6.0) * exp(-r * 2.2) * bass * 0.22;

    // ---------------- radial spikes ----------------
    float ring_r = RING_RADIUS + bass * 0.10;

    float ang = atan(p.x, p.y) + T * ROTATION;
    float t = abs(fract(ang / TAU) * 2.0 - 1.0);   // mirrored 0..1 around the circle
    float cell = t * SPIKES;
    float id = floor(cell);
    float f = fract(cell);
    float v = getBar((id + 0.5) / SPIKES);
    v = pow(v, 0.85);

    // soft gap between spikes
    float w = smoothstep(0.0, 0.14, f) * (1.0 - smoothstep(0.86, 1.0, f));

    // outward spikes
    float d = r - ring_r;
    float h = v * SPIKE_LEN;
    float outMask = step(0.0, d) * (1.0 - smoothstep(h - 0.004, h + 0.004, d));
    vec3 spikeCol = pal(t * 0.7 + d * 1.1 + hue);
    float fade = 0.35 + 0.65 * clamp(d / max(h, 0.001), 0.0, 1.0);
    col += spikeCol * outMask * w * fade * 1.5;

    // glowing tips + halo above each spike
    float tip = exp(-abs(d - h) * 55.0) * v * step(0.0, d);
    col += pal(t * 0.7 + hue + 0.15) * tip * (0.4 + 0.6 * w) * 1.3;
    float halo = exp(-max(d - h, 0.0) * 12.0) * step(0.0, d) * v * smoothstep(0.0, 0.5, w);
    col += spikeCol * halo * 0.30;

    // inward spikes (shorter, mirrored feel)
    float di = (ring_r - 0.025) - r;
    float hi = v * 0.22;
    float inMask = step(0.0, di) * (1.0 - smoothstep(hi - 0.004, hi + 0.004, di));
    col += pal(t * 0.7 + hue + 0.45) * inMask * w * 0.9;
    col += pal(t * 0.7 + hue + 0.45) * exp(-abs(di - hi) * 50.0) * v * step(0.0, di) * 0.6;

    // ---------------- glowing ring ----------------
    float ringDist = abs(r - ring_r);
    float ring = exp(-ringDist * 160.0) * 1.2 + exp(-ringDist * 28.0) * (0.15 + bass * 0.9);
    col += pal(hue + 0.05 + bass * 0.2) * ring;

    // inner core pulse
    float core = exp(-r * 5.5) * (0.10 + bass * 0.9);
    col += pal(hue + 0.6) * core;
    col += vec3(1.0) * exp(-r * 18.0) * bass * 0.5;

    // ---------------- twinkling stars ----------------
    for (int L = 0; L < 2; L++) {
        float scale = (L == 0) ? 14.0 : 27.0;
        vec2 g = p * scale + float(L) * 17.0;
        vec2 gi = floor(g);
        vec2 gf = fract(g) - 0.5;
        float rnd = hash21(gi);
        if (rnd > 0.90) {
            vec2 off = (vec2(hash21(gi + 3.1), hash21(gi + 7.7)) - 0.5) * 0.6;
            float dist = length(gf - off);
            float tw = 0.5 + 0.5 * sin(T * (1.5 + rnd * 4.0) + rnd * 40.0);
            float s = smoothstep(0.09, 0.0, dist) * tw * (0.25 + highs * 2.0);
            col += pal(rnd + hue) * s * 0.8;
        }
    }

    // ---------------- finish ----------------
    // gentle brightness lift when the music hits hard
    col *= 0.9 + energy * 0.5;

    // vignette
    col *= 1.0 - 0.45 * smoothstep(0.7, 1.9, r);

    // filmic-ish tone map + gamma
    col = 1.0 - exp(-col * 1.35);
    col = pow(col, vec3(0.92));

    fragColor = vec4(col, 1.0);
}
