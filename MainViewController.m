//
//  MainViewController.m
//  UDP - Socket
//
//  Created by Mateo Olaya Bernal on 23/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	// Crear recurso socket TCP
	socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	
	stream = [[JPGStream alloc] initWhitDelegate:self spf:JPGFps24];
	
	tmp = [[NSMutableData alloc] initWithCapacity:2^64];
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	[tmp appendData:data];

	const char * bytes = (const char *)[data bytes];
	for (int seek = 0; seek < [data length]; ++seek) {
		if (bytes[seek] == (char)0xFF && bytes[seek + 1] == (char)0xD9) {
			// Encontro un EOI
			UIImage *image = [UIImage imageWithData:tmp];
			[stream appendFrame:image];
			
			[self showLengthOnLabel:bytesPerFrame withLength:[tmp length] withDescription:@"por Frame"];
			
			[tmp resetBytesInRange:NSMakeRange(0, [tmp length])];
			[tmp setLength:0];
			break;
		}
	}
	
	[sock readDataWithTimeout:-1 tag:0];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [socket readDataWithTimeout:-1 tag:0];
}

- (IBAction)run:(id)sender
{
	[puerto resignFirstResponder];
	[ip resignFirstResponder];
	
	if (![socket isConnected]) {
		[socket connectToHost:[ip text] onPort:[[puerto text] integerValue] error:nil];
		
		[ip setHidden:YES];
		[puerto setHidden:YES];
		
		const char byte = 0xF;
		[socket writeData:[NSData dataWithBytes:&byte length:sizeof(byte)] withTimeout:-1 tag:0];
		
		[stream playStream];
	} else {
		[ip setHidden:NO];
		[puerto setHidden:NO];
		
		[socket disconnect];
		[stream stopStream];
	}
}

- (IBAction)changeFPS:(UIStepper *)sender {
	switch ((int) sender.value) {
		case 2:
			[stream setFps:JPGFps2];
			break;
		case 3:
			[stream setFps:JPGFps3];
			break;
		case 4:
			[stream setFps:JPGFps4];
			break;
		case 5:
			[stream setFps:JPGFps5];
			break;
		case 6:
			[stream setFps:JPGFps10];
			break;
		case 7:
			[stream setFps:JPGFps15];
			break;
		case 8:
			[stream setFps:JPGFps20];
			break;
		case 9:
			[stream setFps:JPGFps24];
			break;
		default:
		case 1:
			[stream setFps:JPGFps1];
			break;
	}
	[stream playStream];
	[fpsLabel setText:[NSString stringWithFormat:@"%d FPS", (int)[stream fps]]];
}

- (void)JPGStream:(JPGStream *)stream didShowFrame:(UIImage *)frame
{
	//NSLog(@"Show Frame");
	[viewer setImage:frame];
	[waitingBuffer setHidden:YES];
	// 0xF le dice al servidor que entrege un frame
	const char byte = 0xF;
	[socket writeData:[NSData dataWithBytes:&byte length:sizeof(byte)] withTimeout:-1 tag:0];
}

- (void)JPGStream:(JPGStream *)stream didEndOfBuffer:(BOOL)isWaiting
{
	//NSLog(@"NO BUFFER");
	if ([socket isConnected]) {
		[waitingBuffer setHidden:NO];
	}
}

- (void)JPGStream:(JPGStream *)stream didStopStreamDataFlow:(UIImage *)lastFrame
{
	[viewer setImage:lastFrame];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flujo de datos terminado"
													message:@"Se corto la comunicacion con el servidor y se asumio el final del flujo de datos, se borrara el Buffer."
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil, nil];
	[alert show];
	
}

- (void)JPGStream:(JPGStream *)stream didErrorWhenExecute:(NSError *)error
{
	NSLog(@"%@", error.localizedDescription);
}

- (void)JPGStream:(JPGStream *)stream_ didAppedData:(UIImage *)image
{
	[bufferLabel setText:[NSString stringWithFormat:@"%d Frames en el Buffer", [[stream_ frames] count]]];
}

- (void)viewDidUnload {
	viewer = nil;
	fpsLabel = nil;
	bytesPerFrame = nil;
	bufferLabel = nil;
	waitingBuffer = nil;
	puerto = nil;
	ip = nil;
	[super viewDidUnload];
}

- (void)showLengthOnLabel:(UILabel *)textfield withLength:(long)bytes withDescription:(NSString *)desc
{
	if (bytes < 1024) {
		[textfield setText:[NSString stringWithFormat:@"%ld Bytes %@", bytes, desc]];
	} else if (bytes < 1048576) {
		[textfield setText:[NSString stringWithFormat:@"%ld Kb %@", bytes / 1024, desc]];
	} else if (bytes < 1073741824) {
		[textfield setText:[NSString stringWithFormat:@"%.1f Mb %@", (float) (bytes / 1024) / 1024, desc]];
	} else {
		[textfield setText:[NSString stringWithFormat:@"%.2f Gb %@", (float) ((bytes / 1024) / 1024) / 1024, desc]];
	}
}
@end
