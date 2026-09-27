#!/bin/bash
SHADER="$1"   # e.g. ./run_cava_shader.sh northern_lights

cat > /tmp/cava_shader_config <<EOF
[input]
method = pulse
source = auto

[output]
method = sdl_glsl
vertex_shader = pass_through.vert
fragment_shader = ${SHADER}

[color]
background = '#0d1117'
foreground = '#58a6ff'

gradient = 1
gradient_count = 8
gradient_color_1 = '#39ff14'
gradient_color_2 = '#00f5d4'
gradient_color_3 = '#00bbf9'
gradient_color_4 = '#9b5de5'
gradient_color_5 = '#f15bb5'
gradient_color_6 = '#fee440'
gradient_color_7 = '#ff9e00'
gradient_color_8 = '#ff0054'

EOF

cava -p /tmp/cava_shader_config
