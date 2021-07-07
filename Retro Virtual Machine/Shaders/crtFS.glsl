
varying vec2 tex0;

//uniform float w,h;

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
uniform float curvature;
uniform float vigAmp;
uniform float vigRnd;
uniform float beamI;
uniform float beamSpeed;

uniform float seed;
//uniform float x;
//uniform float y;

uniform vec2 screen;
uniform vec2 size;

uniform sampler2D sam;
uniform sampler2D previous;
uniform sampler2D scanMask;

//float rand(vec2 co){
//  co.x=co.x+seed;
//  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
//}

float rand(vec2 p)
{
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4337);
}

vec3 rand32(vec2 p)
{
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy +  vec2(21.5351, 14.3137));
  return fract(vec3(p.x * p.y * 95.4337, p.x * p.y * 97.597, p.x * p.y * 93.8365));
}

vec2 screenDistort(vec2 uv)
{
  uv -= vec2(.5,.5);
  uv = uv*1.2*(1./1.2+curvature*uv.x*uv.x*uv.y*uv.y);
  uv += vec2(.5,.5);
  return uv;
}

void main()
{
  vec2 pos=gl_FragCoord.xy/screen.xy;
  
  const vec3 lc=vec3(0.2125, 0.7154, 0.0721);
  const vec3 al=vec3(0.5,0.5,0.5);
  
  vec2 uv=screenDistort(tex0);
  
  float o=(0.5-rand(vec2(0,uv.y+time)))*offset;
  vec2 t=vec2(uv.x+o,uv.y);
  
  vec3 c1=vec3(texture2D(sam,t));
  vec3 c2=vec3(texture2D(sam,vec2(t.x+blur,t.y)));
  vec3 c3=vec3(texture2D(sam,vec2(t.x-blur,t.y)));
  c1=(c1+c2+c3)/3.0;
  vec3 p1=vec3(texture2D(previous,t));
  vec3 g=vec3(texture2D(sam,t+ghostOffset));
  
  vec3 c=mix(p1,c1,interlaced);
  c=mix(c,g,ghostIntensity);
  
  vec3 n=(vec3(-0.5,-0.5,-0.5)+rand32(floor(pos*size*2.0)+time))*noise;
  c=clamp(c+n,0.0,1.0);
  vec3 i=vec3(dot(c,lc));
  
  
  vec3 sc=mix(i,c,saturation);
  vec3 cc=mix(al,sc,contrast)+vec3(brightness);
  
  vec2 v1=vec2(0.5,(pos.y*size.y));
  vec4 wl=clamp(texture2D(scanMask,v1)-scanlines,0.0,1.0);
  
  float va=vigAmp+rand(vec2(time,0))*vigRnd;
  float vignette = (1.-va*(uv.y-.5)*(uv.y-.5))*(1.-va*(uv.x-.5)*(uv.x-.5));
  cc*=vignette;
  
  float be=fract(time*beamSpeed);
  //be=0.5;
  be=clamp(uv.y-be,0.0,1.0);
  if(be>0.0)
  {
    be=0.5-be;
    cc+=beamI*be*be;
  }
  
  //float  nr=(0.5-rand(floor(vec2(x,y)*tex0)+time))*noise;
  //vec3 n=vec3(nr,nr,nr);
  //vec3 n=vec3(rand(floor(vec2(x+seed,y+seed)*tex0))-0.5,rand(floor(vec2(x,y)*tex0))-0.5,rand(floor(vec2(x,y+seed)*tex0))-0.5)*noise;
  
  gl_FragColor=vec4((cc*wl.x),1);
}
