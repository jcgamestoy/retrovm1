attribute vec4 pos;
attribute vec2 tc;

uniform mat4 pm;

varying vec2 tex0;

void main()
{
  gl_Position=pos*pm;
  tex0=tc;
}
