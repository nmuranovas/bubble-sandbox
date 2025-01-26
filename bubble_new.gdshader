shader_type spatial;

uniform float distortion_speed : hint_range(0.1, 2.0, 0.1) = 0.5;
uniform float distortion_power : hint_range(0.0, 1.0, 0.01) = 0.1;

uniform float bubble_speed = 1.5;
uniform float bubble_size = 0.05;

uniform vec4 outline_color : source_color = vec4( 0.45, 0.70, 1.0, 1.0 );
uniform float outline_ratio = 1.0;
uniform float noise_speed = 0.2;
uniform float noise_scale = 0.5;

float random(vec2 pos) { 
	return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
vec4 permute(vec4 x) { return mod(((x * 34.0) + 1.0) * x, 289.0); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(vec3 v) {
	vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
	vec4  D = vec4(0.0, 0.5, 1.0, 2.0);
	vec3 Cxxx = vec3(C.x);

	// First corner
	vec3 i  = floor(v + dot(v, vec3(C.y)) );
	vec3 x0 =   v - i + dot(i, vec3(C.x)) ;

	// Other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );

	//  x0 = x0 - 0. + 0.0 * C 
	vec3 x1 = x0 - i1 + 1.0 * Cxxx;
	vec3 x2 = x0 - i2 + 2.0 * Cxxx;
	vec3 x3 = x0 - 1. + 3.0 * Cxxx;

	// Permutations
	i = mod(i, 289.0 ); 
	vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients
	// ( N*N points uniformly over a square, mapped onto an octahedron.)
	float n_ = 1.0/7.0; // N=7
	vec3  ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)
	
	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
	
	vec4 x = x_ *ns.x + vec4(ns.y);
	vec4 y = y_ *ns.x + vec4(ns.y);
	vec4 h = 1.0 - abs(x) - abs(y);

	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );
	
	vec4 s0 = floor(b0)*2.0 + 1.0;
	vec4 s1 = floor(b1)*2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));
	
	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

	vec3 p0 = vec3(a0.xy,h.x);
	vec3 p1 = vec3(a0.zw,h.y);
	vec3 p2 = vec3(a1.xy,h.z);
	vec3 p3 = vec3(a1.zw,h.w);

	// Normalize gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

// Mix final noise value
	vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
								  dot(p2,x2), dot(p3,x3) ) );
}

vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void vertex() {
	//vec3 v = clamp( cos( VERTEX * 10.0 + vec3( TIME * bubble_speed ) ) + vec3( 1.0 ), 0.0, 1.0 );
	//VERTEX *= 1.0 + dot( v, v ) * bubble_size * 0.5;
	VERTEX *= pow(1.0 + snoise(vec3(VERTEX.xy, VERTEX.z + TIME * distortion_speed) * 0.5), distortion_power);
	COLOR = vec4(hsv2rgb(vec3((length(VERTEX) - 1.0) * 5.0, 1.0, 1.0)), 0.5);
}

void fragment( ) {
	float outline_alpha = clamp( ( 1.0 - pow(dot( NORMAL, VIEW ), 0.5)) * outline_ratio, 0.0, 1.0 );
	vec3 color = hsv2rgb( vec3(outline_alpha - 1.5 + noise_speed * TIME, 1.0, 1.0 )) * noise_scale;
//
	ALPHA = outline_alpha;
	float noise = snoise(vec3(VERTEX.xy, VERTEX.z + TIME * distortion_speed) * 0.2);
	ALBEDO = hsv2rgb(vec3((length(noise) - 1.0) + 0.2, 1.0, 1.0));
	ALBEDO = mix( color, outline_color.rgb, max( outline_alpha - 0.3, 0.0 ) );
}
