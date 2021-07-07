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
  p+=time;
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4337);
}

float onOff(float a, float b, float c)
{
  return step(c, sin(time + a*cos(time*b)));
}

float noise(vec2 pos)
{
  vec2 f=floor(size*pos);
  //float c=rand(vec2(floor(f.x),floor(f.y)));
  float tl=rand(f);
  float tr=rand(f+vec2(1,0));
  float bl=rand(f+vec2(0,1));
  float br=rand(f+vec2(1,1));
  vec2 fr=fract(size*pos);
  float tA=mix(tl,tr,fr.x);
  float tB=mix(bl,br,fr.x);
  return mix(tA,tB,fr.y);
}

float ramp(float y, float start, float end)
{
  float inside = step(start,y) - step(end,y);
  float fact = (y-start)/(end-start)*inside;
  return (1.-fact) * inside;
}

float stripes(vec2 uv)
{
  float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
  return ramp(mod(uv.y*4. + time/2.+sin(time + sin(time*0.63)),1.),0.5,0.6)*noi;
}

vec3 getVideo(vec2 uv)
{
  vec2 look = uv;
  float window = 1./(1.+20.*(look.y-mod(time/4.,1.))*(look.y-mod(time/4.,1.)));
  look.x = look.x + sin(look.y*10. + time)/50.*onOff(4.,4.,.3)*(1.+cos(time*80.))*window;
  float vShift = 0.4*onOff(2.,3.,.9)*(sin(time)*sin(time*20.) +
                                      (0.5 + 0.1*sin(time*200.)*cos(time)));
  look.y = mod(look.y + vShift, 1.);
  vec3 video;
  
  if(look.x<0.0 || look.y<0.0 || look.x>1.0 || look.y>1.0)
    video=vec3(0.0,0.0,0.0);
  else
    video = vec3(texture2D(sam,look));
  return video;
}

vec2 screenDistort(vec2 uv)
{
  uv -= vec2(.5,.5);
  uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
  uv += vec2(.5,.5);
  return uv;
}

void main()
{
  vec2 pos=gl_FragCoord.xy/screen.xy;
  float ti=time*4.0;
  
  vec2 uv=tex0;
  uv=screenDistort(uv);
  float vigAmt = 3.+.3*sin(time + 5.*cos(time*5.));
  float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
  
  
  float noise=n*rand(floor(uv*screen)+ti);
  //vec4 t = texture2D(sam,uv);
  vec3 t=getVideo(uv);
  t+=stripes(pos);//floor(pos*size*2.0));
  t+=noise(pos)/10.;
  t*=vignette;
  t*=(12.+mod(uv.y*30.+time,1.))/13.;
  //vec4 sepia=vec4(t.r*.393+t.g*.769+t.b*.189,t.r*.349+t.g*.686+t.b*.189,t.r*.272+t.g*.534+t.b*.131,1.0);
  gl_FragColor = vec4(t*0.8,1.0);
}