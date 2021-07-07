//
//  rvmMatrix.m
//  rvmSpectrum
//
//  Created by Juan Carlos González Amestoy on 06/12/13.
//  Copyright (c) 2013 Juan Carlos González Amestoy. All rights reserved.
//

#import "rvmMatrix.h"

@implementation rvmMatrix


+(rvmMatrix*)orthoLeft:(float)left right:(float)right top:(float)top bottom:(float)bottom near:(float)near far:(float)far
{
  rvmMatrix *o=[[rvmMatrix alloc] init];
  
  o.ptr[0]=2.0/(right-left);
  o.ptr[3]=(-(right+left)/(right-left));
  o.ptr[5]=2.0/(top-bottom);
  o.ptr[7]=(-(top+bottom)/(top-bottom));
  o.ptr[10]=2.0/(far-near);
  o.ptr[11]=(-(far+near)/(far-near));
  
  return o;
}


+(rvmMatrix*)orthoFromRect:(CGRect)rect
{
  return [rvmMatrix orthoLeft:0 right:rect.size.width top:rect.size.height bottom:0 near:-1000 far:1000];
}

-(id)init
{
  self=[super init];
  if(self)
  {
    _data[0]=1; _data[1]=0; _data[2]=0; _data[3]=0;
    _data[4]=0; _data[5]=1; _data[6]=0; _data[7]=0;
    _data[8]=0; _data[9]=0; _data[10]=1; _data[11]=0;
    _data[12]=0; _data[13]=0; _data[14]=0; _data[15]=1;
  }
  
  return self;
}

-(float *)ptr
{
  return _data;
}
@end
