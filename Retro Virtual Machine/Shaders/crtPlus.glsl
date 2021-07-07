//
// (C)2015 Juan Carlos González Amestoy.
//
// Thanks to Timothy Lottes -> https://www.shadertoy.com/view/XsjSzR
//

#define real 0

#if real==1 //Real shader
  uniform float lineOffset;
  uniform float lineNoise;
  uniform vec2 res; //Resolution
  uniform float scanlines;
  uniform float sharpness;
  uniform float curvature;
  uniform sampler2D t0;
  uniform sampler2D t1; //previous frame
  varying vec2 tex0;
#else //Emulated
  #define lineOffset 0.003
  #define lineNoise 0.40
  #define scanlines -8.0
  #define sharpness -3.0
  #define curvature 0.03

  #define t0 iChannel0

  #if 1
    // Fix resolution to set amount.
    vec2 res=vec2(320.0/1.0,160.0/1.0);
  #else
    // Optimize for resize.
    vec2 res=iResolution.xy/18.0;
  #endif

  vec2 tex0=gl_FragCoord.xy/iResolution.xy;
#endif

vec2 wa=vec2(4.0,3.0);
vec2 warp=wa * curvature;//vec2(1.0/32.0,1.0/24.0);

//------------------------------------------------------------------------

float hash12(vec2 p)
{
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
  return fract(p.x * p.y * 95.4337);
}

vec3 hash32(vec2 p)
{
  p  = fract(p * vec2(5.3983, 5.4427));
  p += dot(p.yx, p.xy +  vec2(21.5351, 14.3137));
  return fract(vec3(p.x * p.y * 95.4337, p.x * p.y * 97.597, p.x * p.y * 93.8365));
}

vec3 Fetch(vec2 pos,vec2 off)
{
  pos=floor(pos*res+off)/res;
  if(max(abs(pos.x-0.5),abs(pos.y-0.5))>0.5)return vec3(0.0,0.0,0.0);
  float n=(0.5-hash12(vec2(0,pos.y+iGlobalTime)))*lineOffset;
  pos.x+=n;
  vec3 noise=(0.5-hash32(pos+iGlobalTime))*lineNoise;
  return texture2D(iChannel0,pos.xy,-16.0).rgb+noise;
}

// Distance in emulated pixels to nearest texel.
vec2 Dist(vec2 pos){pos=pos*res;return -((pos-floor(pos))-vec2(0.5));}

// 1D Gaussian.
float Gaus(float pos,float scale){return exp2(scale*pos*pos);}

// 3-tap Gaussian filter along horz line.
vec3 Horz3(vec2 pos,float off){
  vec3 b=Fetch(pos,vec2(-1.0,off));
  vec3 c=Fetch(pos,vec2( 0.0,off));
  vec3 d=Fetch(pos,vec2( 1.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=sharpness;
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  // Return filtered sample.
  return (b*wb+c*wc+d*wd)/(wb+wc+wd);}

// 5-tap Gaussian filter along horz line.
vec3 Horz5(vec2 pos,float off){
  vec3 a=Fetch(pos,vec2(-2.0,off));
  vec3 b=Fetch(pos,vec2(-1.0,off));
  vec3 c=Fetch(pos,vec2( 0.0,off));
  vec3 d=Fetch(pos,vec2( 1.0,off));
  vec3 e=Fetch(pos,vec2( 2.0,off));
  float dst=Dist(pos).x;
  // Convert distance to weight.
  float scale=sharpness;
  float wa=Gaus(dst-2.0,scale);
  float wb=Gaus(dst-1.0,scale);
  float wc=Gaus(dst+0.0,scale);
  float wd=Gaus(dst+1.0,scale);
  float we=Gaus(dst+2.0,scale);
  // Return filtered sample.
  return (a*wa+b*wb+c*wc+d*wd+e*we)/(wa+wb+wc+wd+we);}

// Return scanline weight.
float Scan(vec2 pos,float off){
  float dst=Dist(pos).y;
  return Gaus(dst+off,scanlines);}

// Allow nearest three lines to effect pixel.
vec3 Tri(vec2 pos){
  vec3 a=Horz3(pos,-1.0);
  vec3 b=Horz5(pos, 0.0);
  vec3 c=Horz3(pos, 1.0);
  float wa=Scan(pos,-1.0);
  float wb=Scan(pos, 0.0);
  float wc=Scan(pos, 1.0);
  return a*wa+b*wb+c*wc;}

// Distortion of scanlines, and end of screen alpha.
vec2 Warp(vec2 pos){
  pos=pos*2.0-1.0;
  pos*=vec2(1.0+(pos.y*pos.y)*warp.x,1.0+(pos.x*pos.x)*warp.y);
  return pos*0.5+0.5;}

// Draw dividing bars.
float Bar(float pos,float bar){pos-=bar;return pos*pos<4.0?0.0:1.0;}

// Entry.
void main(void)
{
  vec2 pos=Warp(tex0);
  gl_FragColor.rgb=Tri(pos);
  gl_FragColor.a=1.0;
}




