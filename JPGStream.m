//
//  JPGStream.m
//  UDP - Socket
//
//  Created by Mateo Olaya Bernal on 24/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import "JPGStream.h"

@implementation JPGStream
@synthesize delegate = _delegate,
			frames = _frames,
			fps = _fps,
			waitForBuffer;

#pragma mark - Constructor 

- (void)__construct
{
	// Construir objetos
	_frames = [NSMutableArray array];
	
	// Construir tipos estandar
	waitForBuffer = 10;
	framesIndex = 0;
}

- (id)init
{
	self = [super init];
	if (self) {
		_fps = JPGFps1;
		[self __construct];
	}
	return self;
}
- (id)initWhitDelegate:(id)delegate spf:(JPGFps)fps
{
	self = [super init];
	if (self) {
		_delegate = delegate;
		_fps = fps;
		
		[self __construct];
	}
	return self;
}

#pragma mark - 

- (void)appendFrame:(UIImage *)frame
{
	if ([_frames count] > MAX_QUEUE_FRAMES) {
		[_frames removeAllObjects];
		[self notifyError:@"Warning: Se a superado el tamaño maximo de la cola de Frames."
					 code:1];
	}
	[_frames addObject:frame];
	[_delegate JPGStream:self didAppedData:frame];
}

- (void)showFrame:(NSTimer *)timer;
{
	if ([_frames count] > 0) {
		UIImage *frame = [_frames objectAtIndex:[_frames count] - 1];
		[_frames removeObjectAtIndex:0];
		[_delegate JPGStream:self didShowFrame:frame];
	} else {
		[_delegate JPGStream:self didEndOfBuffer:YES];
	}
	
}

- (void)notifyError:(NSString *)desc code:(NSUInteger)code
{
	NSMutableDictionary *options = [NSMutableDictionary dictionary];
	[options setValue:desc forKey:NSLocalizedDescriptionKey];
	[_delegate JPGStream:self didErrorWhenExecute:[NSError errorWithDomain:@"Stream Warning" code:code userInfo:options]];
}

- (void)playStream
{
	if (caller) {
		[caller invalidate];
	}
	caller = [NSTimer scheduledTimerWithTimeInterval:(1.f / (float)_fps)
									 target:self
								   selector:@selector(showFrame:)
								   userInfo:nil
									repeats:YES];
}

- (void)stopStream
{
	[caller invalidate];
	[_delegate JPGStream:self didStopStreamDataFlow:[_frames objectAtIndex:0]];
	[_frames removeAllObjects];
}
@end
