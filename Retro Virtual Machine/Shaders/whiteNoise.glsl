
varying vec2 tex0;

uniform float seed;
//uniform float x;
//uniform float y;
uniform vec2 screen;
uniform vec2 size;
uniform float time;
//uniform sampler2D sam;

float rand(vec2 p)
{
  p+=time;
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4337);
}

void main()
{
  //vec2 s=vec2(x,y);
  vec2 pos=gl_FragCoord.xy/screen;
  vec2 f=floor(size*pos);
  //float c=rand(vec2(floor(f.x),floor(f.y)));
  float tl=rand(f);
  float tr=rand(f+vec2(1,0));
  float bl=rand(f+vec2(0,1));
  float br=rand(f+vec2(1,1));
  vec2 fr=fract(size*pos);
  float tA=mix(tl,tr,fr.x);
  float tB=mix(bl,br,fr.x);
  float c=mix(tA,tB,fr.y);
  
  gl_FragColor=vec4(c,c,c,1);
}