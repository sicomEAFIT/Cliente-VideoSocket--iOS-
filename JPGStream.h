//
//  JPGStream.h
//  UDP - Socket
//
//  Created by Mateo Olaya Bernal on 24/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//
#define MAX_QUEUE_FRAMES 10000
#import <Foundation/Foundation.h>
typedef enum JPGFpsTypes
{
	JPGFps1 = 1,
	JPGFps2 = 2,
	JPGFps3 = 3,
	JPGFps4 = 4,
	JPGFps5 = 5,
	JPGFps10 = 10,
	JPGFps15 = 15,
	JPGFps20 = 20,
	JPGFps24 = 24
} JPGFps; // Segundos por Frame

@class JPGStream;
@protocol JPGStreamDelegate <NSObject>
@optional
- (void)JPGStream:(JPGStream *)stream didShowFrame:(UIImage *)frame;
- (void)JPGStream:(JPGStream *)stream didEndOfBuffer:(BOOL)isWaiting;
- (void)JPGStream:(JPGStream *)stream didErrorWhenExecute:(NSError *)error;
- (void)JPGStream:(JPGStream *)stream didStopStreamDataFlow:(UIImage *)lastFrame;
- (void)JPGStream:(JPGStream *)stream didAppedData:(UIImage *)image;

@end

@interface JPGStream : NSObject
{
	long	bytes,
			framesIndex;
	NSTimer *caller;
}
@property (nonatomic, assign) id<JPGStreamDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *frames;
@property (nonatomic) JPGFps fps;
@property (nonatomic) NSUInteger waitForBuffer; // En segundos

- (id)init;
- (id)initWhitDelegate:(id)delegate spf:(JPGFps)fps;

- (void)playStream;
- (void)stopStream;
- (void)appendFrame:(UIImage *)frame;

@end
