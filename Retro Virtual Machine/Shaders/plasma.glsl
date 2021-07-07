#define PI 3.14159265358979323846

#if 0
#define size iResolution.xy
float time=float(iGlobalTime)*1.0;
#else
uniform float time;
uniform vec2 size;
#endif


void main()
{
  vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / size.xy;
  
  float x = p.x;
  float y = p.y;
  float mov0 = x+y+cos(sin(time)*2.0)*100.+sin(x/100.)*1000.;
  float mov1 = y / 0.9 +  time;
  float mov2 = x / 0.2;
  float c1 = abs(sin(mov1+time)/2.+mov2/2.-mov1-mov2+time);
  float c2 = abs(sin(c1+sin(mov0/1000.+time)+sin(y/40.+time)+sin((x+y)/100.)*3.));
  float c3 = abs(sin(c2+cos(mov1+mov2+c2)+cos(mov2)+sin(x/1000.)));
  //const vec3 lc=vec3(0.2125, 0.7154, 0.0721);
  const vec3 lc=vec3(.1, .1, .1 );
  vec3 c=vec3(c1,c2,c3*1.2);
  vec3 i=vec3(dot(c,lc));
  
  vec3 sc=mix(i,c,0.3);
  //gl_FragColor = vec4(c1,c2,c3*1.2,1);
  gl_FragColor=vec4(sc,1);
  //gl_FragColor=vec4(1.0,1.0,0.0,1.0);
}