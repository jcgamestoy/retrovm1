#define n 0.3

varying vec2 tex0;

uniform float saturation;
uniform float contrast;
uniform float brightness;
uniform float scanlines;
uniform float noise;
uniform float offset;
uniform float interlaced;
uniform vec2 ghostOffset;
uniform float ghostIntensity;
uniform float blur;
uniform float time;

uniform float seed;
uniform vec2 screen;
uniform vec2 size;

uniform sampler2D sam;
uniform sampler2D previous;
uniform sampler2D scanMask;

float rand(vec2 p)
{
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4337);
}

void main()
{
	float ti=time*4.0;

	vec2 uv=tex0;

	
	uv.x+=(sin(uv.y*10.0+ti*0.5)/size.x)*10.0+3.0*sin(rand(vec2(0,uv.y+time)))/size.x;
	uv.y+=(sin(uv.x*10.0+ti*0.5)/size.x)*10.0;

	float noise=n*rand(floor(uv*screen)+ti);
	vec4 t = texture2D(sam,uv);
    vec4 sepia=vec4(t.r*.393+t.g*.769+t.b*.189,t.r*.349+t.g*.686+t.b*.189,t.r*.272+t.g*.534+t.b*.131,1.0);
	gl_FragColor = mix(sepia+noise,t,0.1)*0.7;
}