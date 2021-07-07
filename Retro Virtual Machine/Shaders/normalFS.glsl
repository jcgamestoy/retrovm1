
varying vec2 tex0;

uniform float saturation;
uniform float contrast;
uniform float brightness;

uniform sampler2D sam;

void main()
{
  const vec3 lc=vec3(0.2125, 0.7154, 0.0721);
  const vec3 al=vec3(0.5,0.5,0.5);
  
  vec3 c=vec3(texture2D(sam,tex0));

  vec3 i=vec3(dot(c,lc));
  
  vec3 sc=mix(i,c,saturation);
  vec3 cc=mix(al,sc,contrast)+vec3(brightness);

  gl_FragColor=vec4(cc,1);
}
