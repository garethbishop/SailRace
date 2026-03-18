using Toybox.Attention as Attention;
using Toybox.System as Sys;
using Toybox.System;

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

	hidden static var _singleBeep = [
		new Attention.ToneProfile(3000, 250)	
	];

	hidden static var _doubleBeep = [
		new Attention.ToneProfile(3000, 230), // Lower pitch for a "heavier" sound
		new Attention.ToneProfile(0, 100),    // Gap
		new Attention.ToneProfile(3000, 250) 
	];

	hidden static var _tripleBeep = [
    new Attention.ToneProfile(3000, 190), // Lower pitch for a "heavier" sound
    new Attention.ToneProfile(0, 90),    // Gap
    new Attention.ToneProfile(3000, 190) , // Second beep
	new Attention.ToneProfile(0, 90),    // Gap
    new Attention.ToneProfile(3000, 190)  // Second beep
	];

	hidden static var _longBeep = [
		new Attention.ToneProfile(3000, 1500)	
	];

	hidden static var _canaryTone = [
    new Attention.ToneProfile(3000, 20), // Short high pitch
    new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	];

	hidden static var _doubleCanaryTone = [
    new Attention.ToneProfile(3000, 20), // Short high pitch
    new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(0, 100),    // Gap
	new Attention.ToneProfile(3000, 20), // Short high pitch
    new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	new Attention.ToneProfile(4000, 30),    // Higher pitch
    new Attention.ToneProfile(3000, 20), // Return to first pitch
	];

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
    	// _play(0);
		Attention.playTone({:toneProfile=>_singleBeep});
	}
	
	static function HalfMinute()
	{
		Attention.vibrate(_vibeBeep);
    	// _play(0);
		Attention.playTone({:toneProfile=>_singleBeep});
	}

	static function SingleBeep()
	{
		Attention.vibrate(_vibeBeep);
    	// _play(0);
		Attention.playTone({:toneProfile=>_singleBeep});
	}

	static function BeepOnly()
	{
    	// _play(0);
		Attention.playTone({:toneProfile=>_singleBeep});
	}

	static function DoubleBeep()
	{
		Attention.vibrate(_vibeBeep);
    	Attention.playTone({:toneProfile=>_doubleBeep});
	}

	static function TripleBeep()
	{
		Attention.vibrate(_vibeBeep);
    	Attention.playTone({:toneProfile=>_tripleBeep});
	}

	static function LongBeep()
	{
		Attention.vibrate(_vibeBeep);
    	Attention.playTone({:toneProfile=>_longBeep});
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

	static function CanaryTone()
	{
		Attention.vibrate(_vibeBeep);
		Attention.playTone({:toneProfile=>_canaryTone});
	}

	static function DoubleCanaryTone()
	{
		Attention.vibrate(_vibeBeep);
		Attention.playTone({:toneProfile=>_doubleCanaryTone});
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

}
