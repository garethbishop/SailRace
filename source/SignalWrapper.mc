using Toybox.Attention as Attention;
using Toybox.System as Sys;
using Toybox.System;

// using Toybox.Timer;
// using Toybox.Lang;



// methods for signals
//
class SignalWrapper
{
	hidden static var _isBacklightOn = false;
	hidden static var _vibeBeep = [new Attention.VibeProfile(40, 300)];
	hidden static var _vibeStart = [
        new Attention.VibeProfile(  100, 100 ),
        new Attention.VibeProfile(  30, 200 ),
        new Attention.VibeProfile(  100, 400 ),
        new Attention.VibeProfile(  30, 200 ),
        new Attention.VibeProfile(  100, 400 )];



	hidden static function _play(tone) 
	{
		if (!(Attention has :playTone)) 
		{
			return;
		}

		var tones = 
		[	
			Attention.TONE_LOUD_BEEP,
			Attention.TONE_CANARY,
			Attention.TONE_ALERT_HI,
		];
		Attention.playTone(tones[tone]);
	}
	
	static function PressButton()
	{
    	_play(0);
	}
	
	static function HalfMinute()
	{
		Attention.vibrate(_vibeBeep);
    	_play(0);
	}
	
	static function TenSeconds(secLeft)
	{
		BacklightOn();
		Attention.vibrate(_vibeBeep);
    	_play(0);
    	
	}

	static function CountdownAlert(secLeft)
	{
		BacklightOn();
		Attention.vibrate(_vibeBeep);
    	_play(0);
    	
	}
	
	static function Start()
	{
		Attention.vibrate(_vibeStart);
	    _play(1);
	    // BacklightOff();
	}
	
	// never call
	//
	static function StartEnd()
	{
    	_play(2);
    	Attention.vibrate(_vibeBeep);
	}
	
	static function BacklightOn()
	{
		if (!_isBacklightOn)
		{
			Attention.backlight(true);
			_isBacklightOn = true;
		}
	}
	
	static function BacklightOff()
	{
		if (_isBacklightOn)
		{
			Attention.backlight(false);
			_isBacklightOn = false;
		}
	}



// static function twoBeepsAsync() as Void
// {
// 	_play(0);

//     var t = new Timer.Timer();
//     t.start(Lang.method(SignalWrapper.secondBeep), 150, false);
// }

// static function secondBeep() as Void
// {
// _play(0);
// }


// static function onTimerTimeout() as Void {
//         // System.println("Timer callback executed!");
//         _play(0);

// 		stopTimer();
//     }

//     static function startIntervalTimer() as Void {
// 		_play(0);
//         myTimer = new Timer.Timer();
//         // Start the timer to call the static onTimerTimeout function every 1000ms (1 second), repeatedly
//         myTimer.start(method(:onTimerTimeout), 1000, true);
//     }

// 	    static function stopTimer() as Void {
//         if (myTimer != null) {
//             myTimer.stop();
//             myTimer = null;
//         }
//     }

}
