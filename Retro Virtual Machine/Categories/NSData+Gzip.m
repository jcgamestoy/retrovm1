//
//  NSData+Gzip.m
//  Retro Virtual Machine
//
//  Created by Juan Carlos González Amestoy on 19/12/14.
//  Copyright (c) 2014 Juan Carlos González Amestoy. All rights reserved.
//

#import "NSData+Gzip.h"
#import <zlib.h>

typedef struct __attribute__ ((__packed__))
{
  uint8 id1,id2,cm,flg;
  uint32 mtime;
  uint8 xfl,os;
}gzipH;

@implementation NSData (GZIP)

-(NSData *)deflate
{
  NSMutableData *d=[NSMutableData dataWithLength:self.length*1.001+12];
  uLongf l=d.length;
  int r=compress2((Bytef*)d.bytes, &l, self.bytes, self.length, 9);
  d.length=l;
  if(r==Z_OK)
    return d;
  else
    return nil;
}

-(NSData *)inflate
{
  if ([self length])
  {
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.avail_in = (uint)[self length];
    stream.next_in = (Bytef *)[self bytes];
    stream.total_out = 0;
    stream.avail_out = 0;
    
    NSMutableData *data = [NSMutableData dataWithLength:(NSUInteger)([self length] * 1.5)];
    if (inflateInit2(&stream, 47) == Z_OK)
    {
      int status = Z_OK;
      while (status == Z_OK)
      {
        if (stream.total_out >= [data length])
        {
          data.length += [self length] * 0.5;
        }
        stream.next_out = (uint8_t *)[data mutableBytes] + stream.total_out;
        stream.avail_out = (uInt)([data length] - stream.total_out);
        status = inflate (&stream, Z_SYNC_FLUSH);
      }
      if (inflateEnd(&stream) == Z_OK)
      {
        if (status == Z_STREAM_END)
        {
          data.length = stream.total_out;
          return data;
        }
      }
    }
  }
  return nil;
}

-(uint32)crc32
{
  uint32 crc=(uint32)crc32(0, NULL, 0);
  return (uint32)crc32(crc, self.bytes, (uint32)self.length);
}

-(NSData *)gunzip
{
  if ([self length] == 0) return self;
  
  unsigned full_length = (uint32)[self length];
  unsigned half_length = (uint32)[self length] / 2;
  
  NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
  BOOL done = NO;
  int status;
  
  z_stream strm;
  strm.next_in = (Bytef *)[self bytes];
  strm.avail_in = (uint32)[self length];
  strm.total_out = 0;
  strm.zalloc = Z_NULL;
  strm.zfree = Z_NULL;
  
  if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
  while (!done)
  {
    if (strm.total_out >= [decompressed length])
      [decompressed increaseLengthBy: half_length];
    strm.next_out = [decompressed mutableBytes] + strm.total_out;
    strm.avail_out = (uint32)([decompressed length] - strm.total_out);
    
    status = inflate (&strm, Z_SYNC_FLUSH);
    if (status == Z_STREAM_END) done = YES;
    else if (status != Z_OK) break;
  }
  if (inflateEnd (&strm) != Z_OK) return nil;
  
  if (done)
  {
    [decompressed setLength: strm.total_out];
    return [NSData dataWithData: decompressed];
  }
  else return nil;
}

- (NSData *)gzip
{
  if ([self length] == 0) return self;
  
  z_stream strm;
  
  strm.zalloc = Z_NULL;
  strm.zfree = Z_NULL;
  strm.opaque = Z_NULL;
  strm.total_out = 0;
  strm.next_in=(Bytef *)[self bytes];
  strm.avail_in = (uint32)[self length];
  
  if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
  
  NSMutableData *compressed = [NSMutableData dataWithLength:16384];
  
  do {
    
    if (strm.total_out >= [compressed length])
      [compressed increaseLengthBy: 16384];
    
    strm.next_out = [compressed mutableBytes] + strm.total_out;
    strm.avail_out = (uint32)([compressed length] - strm.total_out);
    
    deflate(&strm, Z_FINISH);
    
  } while (strm.avail_out == 0);
  
  deflateEnd(&strm);
  
  [compressed setLength: strm.total_out];
  return [NSData dataWithData:compressed];
}
@end
