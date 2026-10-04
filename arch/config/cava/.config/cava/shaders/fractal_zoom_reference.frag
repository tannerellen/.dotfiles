#version 330

// ---------------------------------------------------------------------------
//  fractal_zoom_v8.frag  -  endless-zoom Kali fractal that reacts to music
//
//  Put in ~/.config/cava/shaders/ and use this cava config (mono works best):
//
//    [general]
//    bars = 64            ; 48-128 is a good range
//    framerate = 60
//
//    [output]
//    method = sdl_glsl
//    channels = mono
//    fragment_shader = fractal_zoom_v8.frag
//
//  What reacts to what:
//    bass   -> beat "kick": view punches inward, rotation jolts, center flash
//    low    -> bends the fractal parameter (shape morph) + sine bending + rotation
//    mid    -> bends the other fractal parameter + shifts the hue
//    treble -> brightens the sharp line traps ("sparkle")
//  Extra sound cues in this version:
//    bass   -> kick: view punches inward, center flares, whole picture swells
//    mids   -> a gentle swirl twists the center of the picture
//    treble -> twinkling glints scatter across the picture
//    colors -> bass, mids and treble each tint a different color channel, and
//              overall loudness pushes the hue around
//  On its own, the fold exponent, bending and twist wander slowly, so the
//  pattern keeps flowing into new shapes even in silence.
// ---------------------------------------------------------------------------

in vec2 fragCoord;
out vec4 fragColor;

uniform float bars[512];
uniform int bars_count;
uniform vec3 u_resolution;
uniform float shader_time;   // seconds since start (cava's uniform name)
#define time shader_time     // so the rest of the code can just say `time`

// ---- tweakables -----------------------------------------------------------
#define ITER          16      // fractal iterations (lower = faster)
#define ZOOM_PERIOD   22.0    // seconds for one zoom cycle (lower = faster zoom)
#define ZOOM_OCTAVES  3.0     // how deep each cycle zooms before cross-fading
#define PATTERN_SCALE 0.45    // lower = bigger pattern on screen
#define FLOW          1.0     // how fast the pattern mutates (0.5 calm, 2 wild)
#define SOUND_FX      1.0     // strength of the treble glints (0 = off)
#define SWIRL         1.0     // strength of the mid-driven twist (0 = off)
#define BEAT_LO       0.45    // bass level where the kick starts to register
#define BEAT_HI       0.95    // bass level where the kick is full strength
// ---------------------------------------------------------------------------

#define PI 3.14159265

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c, -s, s, c);
}

// channel phases are animated in main(): they slide slowly on their own and are
// pushed by bass / mids / treble, so the color balance itself reacts to sound
vec3 g_phase = vec3(0.0, 0.33, 0.67);

vec3 pal(float t) {
    return 0.5 + 0.5 * cos(6.28318 * (t + g_phase));
}

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// smooth lookup into the spectrum, f in 0..1 (low -> high frequency)
float bar_at(float f) {
    float x = clamp(f, 0.0, 1.0) * float(bars_count - 1);
    int i0 = int(floor(x));
    int i1 = min(i0 + 1, bars_count - 1);
    return mix(bars[i0], bars[i1], fract(x));
}

// average of the spectrum between two fractions
float band(float a, float b) {
    float s = 0.0;
    for (int i = 0; i < 6; i++) {
        s += bar_at(mix(a, b, (float(i) + 0.5) / 6.0));
    }
    return clamp(s / 6.0, 0.0, 1.0);
}

// mutation state, animated in main()
float g_k = 1.0;                                  // fold exponent (reshapes the whole set)
float g_morph = 0.0;                              // strength of the organic sine bending
mat2  g_spin = mat2(1.0, 0.0, 0.0, 1.0);          // twist applied every iteration

// one fractal layer: Kali-style fold with orbit traps for coloring
vec3 fractal(vec2 p, vec2 c, float hue, float treb) {
    float tr1 = 1e9;   // distance-to-origin trap  (soft glow)
    float tr2 = 1e9;   // diagonal line trap       (sharp filaments)
    float body = 0.0;

    for (int i = 0; i < ITER; i++) {
        p = abs(p) / pow(max(dot(p, p), 1e-4), g_k) - c;
        p += g_morph * 0.12 * sin(p.yx * 2.5 + time * 0.8 * FLOW);   // flowing bend
        p = g_spin * p;                                              // constant twist
        float l = length(p);
        tr1 = min(tr1, l);
        tr2 = min(tr2, abs(dot(p, vec2(0.70711, -0.70711))));
        body += 1.0 / (1.0 + l * l);
    }
    body /= float(ITER);

    float glowA = exp(-3.0 * tr1);
    float glowB = exp(-10.0 * tr2);

    vec3 col = pal(hue + 0.40 * tr1 + 0.60 * body) * (0.35 * body + 1.2 * glowA);
    col += pal(hue + 0.50 + 0.30 * tr2) * glowB * (0.6 + 2.2 * treb);
    return col;
}

void main() {
    vec2 uv = fragCoord * 2.0 - 1.0;
    uv.x *= u_resolution.x / u_resolution.y;

    // ---- audio analysis ----------------------------------------------------
    float bass = band(0.00, 0.07);
    float low  = band(0.07, 0.22);
    float mid  = band(0.22, 0.50);
    float treb = band(0.50, 1.00);

    float kick = smoothstep(BEAT_LO, BEAT_HI, bass);
    kick *= kick;                       // sharpen so only real hits pop

    // ---- endless zoom: two layers half a cycle apart, cross-faded ----------
    float ph0 = fract(time / ZOOM_PERIOD);
    float ph1 = fract(time / ZOOM_PERIOD + 0.5);
    float z0 = exp2(-ph0 * ZOOM_OCTAVES);
    float z1 = exp2(-ph1 * ZOOM_OCTAVES);
    float w0 = sin(PI * ph0);
    float w1 = sin(PI * ph1);

    float punch = 1.0 - 0.18 * kick;    // view lunges inward on the beat

    // ---- camera / fractal parameters --------------------------------------
    float ang = time * 0.06 + kick * 0.30 + (low - 0.3) * 0.25;
    vec2 off = vec2(0.35, 0.20) + 0.30 * vec2(sin(time * 0.11 * FLOW), cos(time * 0.14 * FLOW))
                                + 0.12 * vec2(sin(time * 0.33 * FLOW), cos(time * 0.27 * FLOW));
    vec2 c = vec2(0.85 + 0.20 * sin(time * 0.12 * FLOW) + 0.10 * sin(time * 0.37 * FLOW) + 0.18 * low,
                  0.62 + 0.20 * cos(time * 0.10 * FLOW) + 0.10 * cos(time * 0.31 * FLOW) + 0.18 * mid);

    // slow mutations: the fold exponent, the sine bending and the twist each
    // wander on their own clocks, so the set keeps turning into new patterns
    g_k = 1.0 + 0.22 * sin(time * 0.13 * FLOW) + 0.08 * sin(time * 0.31 * FLOW + 1.0);
    g_morph = clamp(0.5 + 0.5 * sin(time * 0.09 * FLOW + 2.0) + 0.4 * low, 0.0, 1.2);
    g_spin = rot(0.06 * sin(time * 0.17 * FLOW) + 0.03 * sin(time * 0.43 * FLOW));
    float hue = time * 0.04 + 0.15 * sin(time * 0.07) + mid * 0.30;

    float r = length(uv);
    float vol = (bass + low + mid + treb) * 0.25;

    // colors react: slow slide + each band tints its own channel + loudness shifts hue
    g_phase = vec3(0.0, 0.33, 0.67)
            + 0.15 * sin(time * 0.17 + vec3(0.0, 2.1, 4.2))
            + 0.30 * (vec3(bass, mid, treb) - 0.25);
    hue += vol * 0.35 + kick * 0.12;

    // mids twist the middle of the picture
    float sw = (mid - 0.25) * 0.6 * exp(-r) * SWIRL;
    vec2 uvd = rot(sw) * uv;

    vec2 q = rot(ang) * uvd * punch * (1.0 - 0.06 * bass);   // whole picture swells slightly with the bass

    vec3 a = fractal(off + q * z0 * PATTERN_SCALE, c, hue, treb);
    vec3 b = fractal(off + q * z1 * PATTERN_SCALE, c, hue, treb);
    vec3 col = (a * w0 + b * w1) / (w0 + w1);

    // beat flash from the center, plus overall loudness lifting the brightness
    col *= (0.75 + 0.55 * kick) * (0.85 + 0.45 * vol);

    col += pal(hue + 0.10) * kick * 0.30 * exp(-r * 1.6);

    // treble glints: a drifting field of stars that only twinkle with high frequencies
    vec2 gp = uv * 11.0 + time * vec2(0.10, 0.22);
    vec2 gi = floor(gp);
    vec2 gf = fract(gp) - 0.5;
    float gh = hash21(gi);
    vec2 go = (vec2(hash21(gi + 3.1), hash21(gi + 7.7)) - 0.5) * 0.6;
    float glint = smoothstep(0.14, 0.0, length(gf - go)) * step(0.80, gh)
                * (0.5 + 0.5 * sin(time * (4.0 + gh * 6.0) + gh * 50.0));
    col += mix(pal(hue + 0.5), vec3(1.0), 0.6) * glint * treb * 2.2 * SOUND_FX;

    // soft tone map so loud passages never clip harshly (no vignette)
    col = 1.0 - exp(-col * 1.4);

    fragColor = vec4(col, 1.0);
}
