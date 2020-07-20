use Tk ':eventtypes';
use Tk::Button;
use Tk::Entry;
use Tk::Frame;
use Tk::Label;
use Tk::MainWindow;
use Tk::Photo;
use Tk::PNG;
use Tk::Scrollbar;
use Tk::Spinbox;
use Tk::Text;

use Time::HiRes qw|usleep|;
use Win32::Clipboard;

my $keepRunning = 1;

my $clockPanel;
my $labClock1;
my $labClock2;
my $labClock3;
my $labClock4;
my $totalsPanel;
my $breaksPanel;
my $leftBreaksPanel;
my $restPanel;
my $butStartRest;
my $lunchPanel;
my $butStartLunch;
my $rightBreaksPanel;
my $butEndBreak;
my $logOutputPanel;
my $txtLogBody;
my $logControlPanel;
my $butClearLog;
my $butPayPalDon;
my $butCopyLog;
my $localTimePanel;

my $strMinsRemain = '00';
my $strSecsRemain = '00';
my $spinRestLength = 10;
my $spinLunchLength = 60;

my $strTotalRest = '00:00';
my $intTotalRest = 0;
my $strTotalLunch = '00:00';
my $intTotalLunch = 0;
my $strStatus = 'Active';
my $intStatus = 0;
my $termPop = 0;
my $strLocalTime = &ReturnDateTime;
my $currentSWVersion = '0.0.1';
my $objWinClip = Win32::Clipboard();

my $mainWindow = MainWindow->new();
$mainWindow->withdraw();
$mainWindow->title('BreakTrack - Brandon Bourret');
$mainWindow->resizable(0, 0);
$mainWindow->protocol('WM_DELETE_WINDOW' => \&TerminatePop);
$mainWindow->iconbitmap(PerlApp::extract_bound_file('stopwatch.ico'));
my $imgPayPalDon = $mainWindow->Photo( 	-format => 'png',
										-data =>										'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');

	$clockPanel = $mainWindow->Frame(	-relief => 'groove',
										-borderwidth => 2)->pack(	-side => 'top',
																	-fill => 'x');
		$labClock1 = $clockPanel->Label(	-textvariable => \$strMinsRemain,
											-font => '{Lucida Console} 64',
											-foreground => 'black',
											-background => 'white')->pack(	-side => 'left');
		$labClock2 = $clockPanel->Label(	-text => 'm',
											-font => '{Lucida Console} 64',
											-foreground => 'black',
											-background => 'white')->pack(	-side => 'left');
		$labClock3 = $clockPanel->Label(	-textvariable => \$strSecsRemain,
											-font => '{Lucida Console} 64',
											-foreground => 'black',
											-background => 'white')->pack(	-side => 'left');
		$labClock4 = $clockPanel->Label(	-text => 's',
											-font => '{Lucida Console} 64',
											-foreground => 'black',
											-background => 'white')->pack(	-side => 'left');
	$localTimePanel = $mainWindow->Frame(	-relief => 'groove',
											-borderwidth => 2)->pack(	-side => 'top',
																		-fill => 'x');
		$localTimePanel->Label(	-text => 'Status:',
								-font => 'Arial 8 bold',
								-foreground => 'black')->pack(	-side => 'left');
		$localTimePanel->Label(	-textvariable => \$strStatus,
								-font => 'Arial 8 bold',
								-foreground => 'black')->pack(	-side => 'left');
		$localTimePanel->Label(	-textvariable => \$strLocalTime,
								-font => 'Arial 8 bold',
								-foreground => 'black')->pack(	-side => 'right');
	$totalsPanel = $mainWindow->Frame(	-relief => 'groove',
										-borderwidth => 2)->pack(	-side => 'top',
																	-fill => 'x');
		$totalsPanel->Label(-text => 'Total Shift Rest:',
							-font => 'Arial 8 bold',
							-foreground => 'black')->pack(	-side => 'left');
		$totalsPanel->Label(-textvariable => \$strTotalRest,
							-font => 'Arial 8 bold',
							-foreground => 'black')->pack(	-side => 'left');
		$totalsPanel->Label(-textvariable => \$strTotalLunch,
							-font => 'Arial 8 bold',
							-foreground => 'black')->pack(	-side => 'right');
		$totalsPanel->Label(-text => 'Total Shift Lunch:',
							-font => 'Arial 8 bold',
							-foreground => 'black')->pack(	-side => 'right');
	$breaksPanel = $mainWindow->Frame(	-relief => 'groove',
										-borderwidth => 2)->pack(	-side => 'top',
																	-fill => 'x');
		$leftBreaksPanel = $breaksPanel->Frame()->pack(	-side => 'left',
														-fill => 'x');
			$restPanel = $leftBreaksPanel->Frame()->pack(	-side => 'top',
															-fill => 'x',
															-anchor => 'w');
				$butStartRest = $restPanel->Button(	-text => 'Start Rest',
													-font => 'Arial 10',
													-width => 10,
													-command => \&StartRest)->pack(	-side => 'left',
																					-padx => 10,
																					-pady => 2);
				$restPanel->Spinbox	(	-width => 3,
										-font => 'Arial 10',
										-textvariable => \$spinRestLength,
										-from => 1,
										-to => 20,
										-increment => 1,
										-foreground => 'black',
										-background => 'SystemButtonFace',
										-selectforeground => 'black',
										-selectbackground => 'SystemButtonFace',
										-repeatdelay => 250,
										-relief => 'flat',
										-state => 'readonly')->pack(	-side => 'left');
				$restPanel->Label(	-text => 'Minutes',
									-font => 'Arial 10',
									-foreground => 'black')->pack(	-side => 'left',
																	-padx => 5);
			$lunchPanel = $leftBreaksPanel->Frame()->pack(	-side => 'top',
															-fill => 'x',
															-anchor => 'w');
				$butStartLunch = $lunchPanel->Button(	-text => 'Start Lunch',
														-font => 'Arial 10',
														-width => 10,
														-command => \&StartLunch)->pack(	-side => 'left',
																							-padx => 10,
																							-pady => 2);
				$lunchPanel->Spinbox	(	-width => 3,
											-font => 'Arial 10',
											-textvariable => \$spinLunchLength,
											-from => 30,
											-to => 90,
											-increment => 5,
											-foreground => 'black',
											-background => 'SystemButtonFace',
											-selectforeground => 'black',
											-selectbackground => 'SystemButtonFace',
											-repeatdelay => 250,
											-relief => 'flat',
											-state => 'readonly')->pack(	-side => 'left');
				$lunchPanel->Label(	-text => 'Minutes',
									-font => 'Arial 10',
									-foreground => 'black')->pack(	-side => 'left',
																	-padx => 5);
		$rightBreaksPanel = $breaksPanel->Frame()->pack(	-side => 'right',
															-fill => 'x');
				$butEndBreak = $rightBreaksPanel->Button(	-text => "End\nBreak",
																-font => 'Arial 14',
																-width => 8,
																-command => \&EndBreak)->pack(	-side => 'left',
																								-padx => 10,
																								-pady => 2);
	$logOutputPanel = $mainWindow->Frame(	-relief => 'groove',
											-borderwidth => 2)->pack(	-side => 'top',
																		-fill => 'both');
		$txtLogBody = $logOutputPanel->Scrolled(	'Text',
													-scrollbars => 'e',
													-wrap => 'word',
													-font => '{Lucida Console} 8',
													-foreground => 'black',
													-background => 'white',
													-width => 44,
													-height => 8,
													-relief => 'flat',
													-state => 'disabled')->pack(	-side => 'top');
			$txtLogBody->menu(undef);
	$logControlPanel = $mainWindow->Frame(	-relief => 'groove',
											-borderwidth => 2)->pack(	-side => 'top',
																		-fill => 'x');
		$butClearLog = $logControlPanel->Button(	-text => 'Clear Log',
													-font => 'Arial 10 bold',
													-width => 9,
													-command => \&ClearLog)->pack(	-side => 'left',
																					-padx => 5,
																					-pady => 5);
		$butPayPalDon = $logControlPanel->Button(   -image => $imgPayPalDon,
													-relief => 'flat',
													-command => sub {
																		system "start \"\" \"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LBYCSFWJCXRVE&source=url\"";
																	})->pack(   -side => 'left',
																				-padx => 15,
																				-pady => 5);
		$butCopyLog = $logControlPanel->Button(	-text => 'Copy Log',
													-font => 'Arial 10 bold',
													-width => 9,
													-command => \&CopyLog)->pack(	-side => 'left',
																				-padx => 5,
																				-pady => 5);
		
$mainWindow->Popup;
$mainWindow->update;

while($keepRunning)
{
	$strLocalTime = &ReturnDateTime;
	my $i = 0;
	while(($i < 10) && ($keepRunning == 1))
	{
		$mainWindow->update;
		usleep(10000);
		$i ++;
	}
}
$mainWindow->destroy();
exit;

sub StartRest
{
	$butStartRest->configure(	-state => 'disabled');
	$butStartLunch->configure(	-state => 'disabled');
	$butClearLog->configure(	-state => 'disabled');
	$butCopyLog->configure(	-state => 'disabled');
	$intStatus = 1;
	$strStatus = 'Rest Period';
	my $timeCall = time();
	my $startTimeStamp = localtime($timeCall);
	$startTimeStamp =~ s/\s[0-9]{4}$//;
	$txtLogBody->configure(	-state => 'normal');
	$txtLogBody->SetCursor('end');
	$txtLogBody->Insert($startTimeStamp . '  Start Rest Period' . "\n");
	$txtLogBody->configure(	-state => 'disabled');
	my $startTimeEpoch = $timeCall;
	my $targetBreakEnd = $startTimeEpoch + ($spinRestLength * 60);
	my $intTimerCount = $targetBreakEnd - $timeCall;
	my $intThisRest = $timeCall - $startTimeEpoch;
	my $intLastTotalRest = $intTotalRest;
	my $boolExpiredColor = 0;
	my $boolDidPop = 0;
	while(($intStatus == 1) && ($keepRunning == 1))
	{
		$timeCall = time();
		$intThisRest = $timeCall - $startTimeEpoch;
		$intTotalRest = $intLastTotalRest + $intThisRest;
		my $strTempTotalRestMins =  int($intTotalRest / 60);
		if(length($strTempTotalRestMins) < 2)
		{
			$strTempTotalRestMins = '0' . $strTempTotalRestMins;
		}		
		my $strTempTotalRestSecs =  $intTotalRest % 60;
		if(length($strTempTotalRestSecs) < 2)
		{
			$strTempTotalRestSecs = '0' . $strTempTotalRestSecs;
		}
		$strTotalRest = $strTempTotalRestMins . ':' . $strTempTotalRestSecs;
		$intTimerCount = $targetBreakEnd - $timeCall;
		if($intTimerCount <= 0)
		{
			$intTimerCount = 0;
		}
		$strMinsRemain = int($intTimerCount / 60);
		if(length($strMinsRemain) < 2)
		{
			$strMinsRemain = '0' . $strMinsRemain;
		}		
		$strSecsRemain = $intTimerCount % 60;
		if(length($strSecsRemain) < 2)
		{
			$strSecsRemain = '0' . $strSecsRemain;
		}
		$strLocalTime = &ReturnDateTime;
		if(($intTimerCount <= 15) && (! $boolDidPop))
		{
			$boolDidPop = 1;
			$mainWindow->deiconify;
			$mainWindow->attributes(-topmost => 1);
		}
		my $i = 0;
		while(($i < 10) && ($intStatus == 1) && ($keepRunning == 1))
		{
			if(($intTimerCount == 0) && ((($i + 1) % 10) == 0))
			{
				if($boolExpiredColor)
				{
					$labClock1->configure(	-foreground => 'white',
											-background => 'red');
					$labClock2->configure(	-foreground => 'white',
											-background => 'red');
					$labClock3->configure(	-foreground => 'white',
											-background => 'red');
					$labClock4->configure(	-foreground => 'white',
											-background => 'red');
					$boolExpiredColor = 0;
				}
				else
				{
					$labClock1->configure(	-foreground => 'red',
											-background => 'white');
					$labClock2->configure(	-foreground => 'red',
											-background => 'white');
					$labClock3->configure(	-foreground => 'red',
											-background => 'white');
					$labClock4->configure(	-foreground => 'red',
											-background => 'white');
					$boolExpiredColor = 1;
				}
			}
			$mainWindow->update;
			usleep(10000);
			$i ++;
		}
	}
	my $endTimeEpoch = $startTimeEpoch + $intThisRest;
	my $endTimeStamp = localtime($endTimeEpoch);
	$endTimeStamp =~ s/\s[0-9]{4}$//;
	my $strTempThisRestMins =  int($intThisRest / 60);
	if(length($strTempThisRestMins) < 2)
	{
		$strTempThisRestMins = '0' . $strTempThisRestMins;
	}		
	my $strTempThisRestSecs =  $intThisRest % 60;
	if(length($strTempThisRestSecs) < 2)
	{
		$strTempThisRestSecs = '0' . $strTempThisRestSecs;
	}
	$txtLogBody->configure(	-state => 'normal');
	$txtLogBody->SetCursor('end');
	$txtLogBody->Insert($endTimeStamp . '  End Rest Period' . "\n");
	$txtLogBody->Insert('-------------------> Rest Duration  ' . $strTempThisRestMins . ':' . $strTempThisRestSecs . "\n\n");
	$txtLogBody->configure(	-state => 'disabled');
	$strMinsRemain = '00';
	$strSecsRemain = '00';
	$labClock1->configure(	-foreground => 'black',
							-background => 'white');
	$labClock2->configure(	-foreground => 'black',
							-background => 'white');
	$labClock3->configure(	-foreground => 'black',
							-background => 'white');
	$labClock4->configure(	-foreground => 'black',
							-background => 'white');
	$butStartRest->configure(	-state => 'normal');
	$butStartLunch->configure(	-state => 'normal');
	$butClearLog->configure(	-state => 'normal');
	$butCopyLog->configure(	-state => 'normal');
	$mainWindow->attributes(-topmost => 0);
	$mainWindow->deiconify;
	return;
}

sub StartLunch
{
	$butStartRest->configure(	-state => 'disabled');
	$butStartLunch->configure(	-state => 'disabled');
	$butClearLog->configure(	-state => 'disabled');
	$butCopyLog->configure(	-state => 'disabled');
	$intStatus = 2;
	$strStatus = 'Lunch Period';
	my $timeCall = time();
	my $startTimeStamp = localtime($timeCall);
	$startTimeStamp =~ s/\s[0-9]{4}$//;
	$txtLogBody->configure(	-state => 'normal');
	$txtLogBody->SetCursor('end');
	$txtLogBody->Insert($startTimeStamp . '  Start Lunch Period' . "\n");
	$txtLogBody->configure(	-state => 'disabled');
	my $startTimeEpoch = $timeCall;
	my $targetBreakEnd = $startTimeEpoch + ($spinLunchLength * 60);
	my $intTimerCount = $targetBreakEnd - $timeCall;
	my $intThisLunch = $timeCall - $startTimeEpoch;
	my $intLastTotalLunch = $intTotalLunch;
	my $boolExpiredColor = 0;
	my $boolDidPop = 0;
	while(($intStatus == 2) && ($keepRunning == 1))
	{
		$timeCall = time();
		$intThisLunch = $timeCall - $startTimeEpoch;
		$intTotalLunch = $intLastTotalLunch + $intThisLunch;
		my $strTempTotalLunchMins =  int($intTotalLunch / 60);
		if(length($strTempTotalLunchMins) < 2)
		{
			$strTempTotalLunchMins = '0' . $strTempTotalLunchMins;
		}		
		my $strTempTotalLunchSecs =  $intTotalLunch % 60;
		if(length($strTempTotalLunchSecs) < 2)
		{
			$strTempTotalLunchSecs = '0' . $strTempTotalLunchSecs;
		}
		$strTotalLunch = $strTempTotalLunchMins . ':' . $strTempTotalLunchSecs;
		$intTimerCount = $targetBreakEnd - $timeCall;
		if($intTimerCount <= 0)
		{
			$intTimerCount = 0;
		}
		$strMinsRemain = int($intTimerCount / 60);
		if(length($strMinsRemain) < 2)
		{
			$strMinsRemain = '0' . $strMinsRemain;
		}		
		$strSecsRemain = $intTimerCount % 60;
		if(length($strSecsRemain) < 2)
		{
			$strSecsRemain = '0' . $strSecsRemain;
		}
		$strLocalTime = &ReturnDateTime;
		if(($intTimerCount <= 15) && (! $boolDidPop))
		{
			$boolDidPop = 1;
			$mainWindow->deiconify;
			$mainWindow->attributes(-topmost => 1);
			Win32::Sound::Play('SystemHand', SND_ASYNC);
		}
		my $i = 0;
		while(($i < 10) && ($intStatus == 2) && ($keepRunning == 1))
		{
			if(($intTimerCount == 0) && ((($i + 1) % 10) == 0))
			{
				if($boolExpiredColor)
				{
					$labClock1->configure(	-foreground => 'white',
											-background => 'red');
					$labClock2->configure(	-foreground => 'white',
											-background => 'red');
					$labClock3->configure(	-foreground => 'white',
											-background => 'red');
					$labClock4->configure(	-foreground => 'white',
											-background => 'red');
					$boolExpiredColor = 0;
				}
				else
				{
					$labClock1->configure(	-foreground => 'red',
											-background => 'white');
					$labClock2->configure(	-foreground => 'red',
											-background => 'white');
					$labClock3->configure(	-foreground => 'red',
											-background => 'white');
					$labClock4->configure(	-foreground => 'red',
											-background => 'white');
					$boolExpiredColor = 1;
				}
			}
			$mainWindow->update;
			usleep(10000);
			$i ++;
		}
	}
	my $endTimeEpoch = $startTimeEpoch + $intThisLunch;
	my $endTimeStamp = localtime($endTimeEpoch);
	$endTimeStamp =~ s/\s[0-9]{4}$//;
	my $strTempThisLunchMins =  int($intThisLunch / 60);
	if(length($strTempThisLunchMins) < 2)
	{
		$strTempThisLunchMins = '0' . $strTempThisLunchMins;
	}		
	my $strTempThisLunchSecs =  $intThisLunch % 60;
	if(length($strTempThisLunchSecs) < 2)
	{
		$strTempThisLunchSecs = '0' . $strTempThisLunchSecs;
	}
	$txtLogBody->configure(	-state => 'normal');
	$txtLogBody->SetCursor('end');
	$txtLogBody->Insert($endTimeStamp . '  End Lunch Period' . "\n");
	$txtLogBody->Insert('-------------------> Lunch Duration  ' . $strTempThisLunchMins . ':' . $strTempThisLunchSecs . "\n\n");
	$txtLogBody->configure(	-state => 'disabled');
	$strMinsRemain = '00';
	$strSecsRemain = '00';
	$labClock1->configure(	-foreground => 'black',
							-background => 'white');
	$labClock2->configure(	-foreground => 'black',
							-background => 'white');
	$labClock3->configure(	-foreground => 'black',
							-background => 'white');
	$labClock4->configure(	-foreground => 'black',
							-background => 'white');
	$butStartRest->configure(	-state => 'normal');
	$butStartLunch->configure(	-state => 'normal');
	$butClearLog->configure(	-state => 'normal');
	$butCopyLog->configure(	-state => 'normal');
	$mainWindow->attributes(-topmost => 0);
	$mainWindow->deiconify;
	return;
}

sub EndBreak
{
	$intStatus = 0;
	$strStatus = 'Active';
	return;
}

sub ClearLog
{
	$txtLogBody->configure(-state => 'normal');
	$txtLogBody->selectAll;
	$txtLogBody->deleteSelected;
	$txtLogBody->unselectAll;
	$txtLogBody->configure(-state => 'disabled');
	$intTotalRest = 0;
	$strTotalRest = '00:00';
	$intTotalLunch = 0;
	$strTotalLunch = '00:00';
	return;
}

sub CopyLog
{
	$txtLogBody->configure(-state => 'normal');
	$txtLogBody->selectAll;
	my $strMsgBodyTemp = $txtLogBody->getSelected;
	$txtLogBody->unselectAll;
	$txtLogBody->configure(-state => 'disabled');
	$objWinClip->Set($strMsgBodyTemp);
	return;
}

sub ReturnDateTime
{
	my $strDateTime = localtime();
	if($strDateTime =~ m/^([a-z]{1,})\s{1,}([a-z]{1,})\s{1,}([0-9]{1,})\s{1,}([0-9\:]{1,})\s{1,}[0-9]{4}$/i)
	{
		$strDateTime = $1 . ' ' . $3 . ' ' . $2 . ', ' . $4;
	}
	return($strDateTime);
}

sub TerminatePop
{
	$mainWindow->protocol('WM_DELETE_WINDOW' => sub
												{
													$mainWindow->update;
												});
	$termPop = 1;
	my $topLevelRun = 1;
	my $topDialogFrame;
	my $topButtomFrame;
	my $topMessageBox = MainWindow->new();
	$topMessageBox->withdraw();
	$topMessageBox->resizable(0,0);
	$topMessageBox->attributes(	-topmost => 1);
	$topMessageBox->iconbitmap(PerlApp::extract_bound_file('stopwatch.ico'));
	$topMessageBox->title('BreakTrack - Brandon Bourret');
	$topMessageBox->bind('<Unmap>', sub
									{
										$topMessageBox->update;
									});
	$topMessageBox->protocol('WM_DELETE_WINDOW', sub
									{
										$topMessageBox->update;
									});
	$topDialogFrame = $topMessageBox->Frame()->pack(	-side => 'top',
														-anchor => 'w',
														-fill => 'both');
		$topDialogFrame->Label(	-text => 'Are you sure you want to quit? The timer will be stopped, and all logged data will be lost.',
								-font => 'Arial 8',
								-foreground => 'black')->pack(	-side => 'top',
																-padx => 10,
																-pady => 30);
	$topButtomFrame = $topMessageBox->Frame()->pack(	-side => 'top');
		$topButtomFrame->Button(	-text => 'Yes',
									-font => 'Arial 10',
									-width => 10,
									-command => sub
												{
													$keepRunning = 0;
													$topLevelRun = 0;
												})->pack(	-side => 'left',
															-padx => 50,
															-pady => 10);
		$topButtomFrame->Button(	-text => 'No',
									-font => 'Arial 10',
									-width => 10,
									-command => sub
												{
													$topLevelRun = 0;
												})->pack(	-side => 'right',
															-padx => 50,
															-pady => 10);
	$topMessageBox->Popup;
	$topMessageBox->update;
	while($topLevelRun == 1)
	{
		my $i = 0;
		while(($i < 10) && ($topLevelRun == 1))
		{
			$topMessageBox->update;
			usleep(10000);
			$i ++;
		}
	}
	$topMessageBox->destroy();
	$mainWindow->protocol('WM_DELETE_WINDOW' => \&TerminatePop);
	return;
}