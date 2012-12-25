
#import <UIKit/UIKit.h>

@interface ThreadingViewController : UIViewController {
	
	
	
	bool button1On;// keeps track if the Start Counting.. buttons are clicked 
	bool button2On;
	bool button3On;
	bool button4On;
	
	int total;  // keeps track of the total count
	int countThread1; //keeps track of the count for each thread
	int countThread2;
	int countThread3;
	int countThread4;
	
	NSLock *myLock; //mutex used to create our Critical Section
	
	IBOutlet UILabel *thread1Label; //Thread value labels
	IBOutlet UILabel *thread2Label;
	IBOutlet UILabel *thread3Label;
	IBOutlet UILabel *thread4Label;
	
	IBOutlet UILabel *totalCount; //Total thread count label
	IBOutlet UILabel *updatedByThread; //Updated by thread label
	
	IBOutlet UIButton *button1Title; // buttons titles that will be updated when
									 //clicked
	IBOutlet UIButton *button2Title;
	IBOutlet UIButton *button3Title;
	IBOutlet UIButton *button4Title;
}

@property (retain,nonatomic)  UIButton *button1Title; //getter and setters
@property (retain,nonatomic)  UIButton *button2Title;
@property (retain,nonatomic)  UIButton *button3Title;
@property (retain,nonatomic)  UIButton *button4Title;

@property (retain,nonatomic) UILabel *totalCount; //getter and setters
@property (retain,nonatomic) UILabel *thread1Label;
@property (retain,nonatomic) UILabel *thread2Label;
@property (retain,nonatomic) UILabel *thread3Label;
@property (retain,nonatomic) UILabel *thread4Label;
@property (retain,nonatomic) UILabel *updatedByThread;

-(IBAction)launchThread1:(id)sender; //methods each button will trigger when 
									//clicked
-(IBAction)launchThread2:(id)sender;
-(IBAction)launchThread3:(id)sender;
-(IBAction)launchThread4:(id)sender;
-(IBAction)KillAllThreads:(id)sender;




-(void)thread1;
-(void)thread2;
-(void)thread3;
-(void)thread4;

-(void)displayThread1Counts:(NSNumber*)threadNumber;
-(void)displayThread2Counts:(NSNumber*)threadNumber;
-(void)displayThread3Counts:(NSNumber*)threadNumber;
-(void)displayThread4Counts:(NSNumber*)threadNumber;

-(void)countThreadLoops:(NSNumber*)threadNumber;


@end