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

use Clipboard;
use Time::HiRes qw|usleep|;

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

my $mainWindow = MainWindow->new();
$mainWindow->withdraw();
$mainWindow->title('BreakTrack - Brandon Bourret');
$mainWindow->resizable(0, 0);
my $imgClockIcon = $mainWindow->Photo( -format => 'png',
                                        -data =>										'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');
my $imgPayPalDon = $mainWindow->Photo( 	-format => 'png',
										-data =>										'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');
$mainWindow->protocol('WM_DELETE_WINDOW' => \&TerminatePop);
$mainWindow->iconimage($imgClockIcon);

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
										-background => 'white',
										-selectforeground => 'black',
										-selectbackground => 'white',
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
											-background => 'white',
											-selectforeground => 'black',
											-selectbackground => 'white',
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
													-font => '{DejaVu Sans Mono} 8',
													-foreground => 'black',
													-background => 'white',
													-width => 55,
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
																		system('xdg-open "https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=LBYCSFWJCXRVE&source=url" &');
																	})->pack(   -side => 'left',
																				-padx => 20,
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

sub XclipFound
{
	my $open_retval = open(CHECK, '-|', 'xclip -o');
	close(CHECK);
    #my $open_retval = open my $just_checking, 'xclip -o |';
    return $open_retval;
}

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
	if(&XclipFound)
	{
		$txtLogBody->configure(-state => 'normal');
		$txtLogBody->selectAll;
		my $strMsgBodyTemp = $txtLogBody->getSelected;
		$txtLogBody->unselectAll;
		$txtLogBody->configure(-state => 'disabled');
		Clipboard->copy_to_all_selections($strMsgBodyTemp);
	}
	else
	{
		&MessageBox('ok',
					'Copy to Clipboard',
					"\nCopy to Clipboard\n\n" .
					"Could not find \"xclip\" installed on your system. Please be\n" .
					"sure to install \"xclip\" through your Linux distribution's\n" .
					"software package manager to use the copy text function.\n\n" .
					"Press 'OK' to continue.\n");
	}
	return;
}

sub MessageBox($$$)
{
	my $strMainGeometry = $mainWindow->geometry;
    $strMainGeometry =~ s/^\d{1,}x\d{1,}//ig;
    my $boxButtonOpts = shift(@_);
    my $boxMainTitle = shift(@_);
    my @messageLines = split(/\n/, shift(@_));
    my $strReturnDecision = 'n';
    my $subRunLoop = 1;
    my $subWindow = MainWindow->new();
    $subWindow->state('withdrawn');
    $subWindow->resizable(0,0);
    $subWindow->attributes(-topmost => 1);
    $subWindow->title($boxMainTitle);
    $subWindow->bind('<Unmap>' => sub{$subWindow->deiconify;});
    $subWindow->protocol('WM_DELETE_WINDOW' => sub{$subWindow->update;});
    my $subFrame = $subWindow->Frame()->pack(   -side => 'top',
                                                -anchor => 'w');
    my @contentLinesFrames;
    my $contentLinesCount = 0;
    while(@messageLines)
    {
          $contentLinesFrames[$contentLinesCount] = $subFrame->Label(   -text => shift(@messageLines),
                                                                        -font => 'arial 8')->pack(  -side => 'top',
                                                                                                    -anchor => 'w',
                                                                                                    -padx => 20);
          $contentLinesCount += 1;
    }
    if($boxButtonOpts =~ m/yn/i)
    {
        my $subYesNo = $subFrame->Frame()->pack(   -side => 'top',
                                                   -fill => 'both');
        $subYesNo->Button(  -text => 'Yes',
                            -font => 'arial 8 bold',
                            -width => 6,
                            -command => sub{$strReturnDecision = 'y';
                                            $subRunLoop = 0;})->pack(   -side => 'left',
                                                                        -padx => 35,
                                                                        -pady => 15);
        $subYesNo->Button(  -text => 'No',
                            -font => 'arial 8 bold',
                            -width => 6,
                            -command => sub{$strReturnDecision = 'n';
                                            $subRunLoop = 0;})->pack(   -side => 'right',
                                                                        -padx => 35,
                                                                        -pady => 15);
    }
    else
    {
        $subFrame->Button(  -text => 'OK',
                            -font => 'arial 8 bold',
                            -width => 6,
                            -command => sub{$subRunLoop = 0;})->pack(   -side => 'top',
                                                                        -pady => 15);
    }

    $subWindow->geometry($strMainGeometry);
	$subWindow->Popup();
    $subWindow->update;
    while($subRunLoop)
    {
        $subWindow->update;
    }
    $subWindow->destroy();
    $mainWindow->update;
    return($strReturnDecision);
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