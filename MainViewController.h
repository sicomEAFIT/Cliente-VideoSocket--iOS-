//
//  MainViewController.h
//  UDP - Socket
//
//  Created by Mateo Olaya Bernal on 23/03/13.
//  Copyright (c) 2013 Mateo Olaya Bernal. All rights reserved.
//

#define DEBUG_HOST_LOCAL @"127.0.0.1"
#define DEBUG_HOST_REMOTE @"192.168.0.13"

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "JPGStream.h"

@interface MainViewController : UIViewController <GCDAsyncSocketDelegate, JPGStreamDelegate>
{
	__weak IBOutlet UILabel *bytesPerFrame;
	__weak IBOutlet UILabel *fpsLabel;
	__weak IBOutlet UILabel *bufferLabel;
	__weak IBOutlet UIActivityIndicatorView *waitingBuffer;
	GCDAsyncSocket *socket;
	__weak IBOutlet UIImageView *viewer;
	NSMutableData *tmp;
	JPGStream *stream;
	IBOutlet UITextField *puerto;
	IBOutlet UITextField *ip;
}
- (IBAction)run:(id)sender;
- (IBAction)changeFPS:(UIStepper *)sender;

@end
