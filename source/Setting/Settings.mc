using Toybox.Graphics as Gfx;
using Toybox.Application as App;

// set of permanently stored values
//
class Settings
{
	enum 
	{
		Cruise,
		Route
	}
	enum {
		TenSeconds,
		Continuous,
		Recorded
	}
	static var ForegroundColor = Gfx.COLOR_BLACK;
	static var BackgroundColor = Gfx.COLOR_WHITE;
	static var DimColor = Gfx.COLOR_LT_GRAY;
	static var TimerValue = 300;
	static var IsTimerValueUpdated = false;
	static var IsAutoRecording = false;
	static var IsWhiteBackground = true; 

	static var ShiftAlerts = true;
	static var ShiftAlertsAvg = TenSeconds;
	static var PortHeadingAverage = 0;
	static var StarboardHeadingAverage = 0;
	static var AverageWindDirection = 0;
	static var ShiftAlertsThreshold = 7;
	
	static var RouteApiUrl = "";
	static var UserId = "";
	static var CurrentRoute = null;
	static var WpEpsilon = 100;
	static var LoadRoutesLimit = 10;

	static var TimerSuccessor = Cruise;

	static function LoadSettings()
	{
		SetAutoRecording(App.getApp().getProperty("IsAutoRecording"));
		SetTimerValue(App.getApp().getProperty("timerValue"));
		SetBackground(App.getApp().getProperty("isWhiteBackground"));
		UserId = App.getApp().getProperty("userId");
		WpEpsilon = App.getApp().getProperty("wpEpsilon");
		CurrentRoute = App.getApp().getProperty("CurrentRoute2");
		RouteApiUrl = Toybox.WatchUi.loadResource(Rez.Strings.apiUrl);
		LoadRoutesLimit = App.getApp().getProperty("loadLimit");

		SetShiftAlerts(App.getApp().getProperty("shiftAlerts"));
		SetShiftAlertsAvg(App.getApp().getProperty("shiftAlertsAvg"));
		SetAlertsThreshold(App.getApp().getProperty("shiftAlertsThreshold"));

		SetPortHeadingAvg(App.getApp().getProperty("portHeadingAvg"));
		SetStarboardHeadingAvg(App.getApp().getProperty("starboardHeadingAvg"));
		SetAverageWindDirection(App.getApp().getProperty("averageWindDirection"));
	}

	static function SaveSettings()
	{
		App.getApp().setProperty("isWhiteBackground", IsWhiteBackground);
		App.getApp().setProperty("timerValue", TimerValue);
		App.getApp().setProperty("IsAutoRecording", IsAutoRecording);
		App.getApp().setProperty("CurrentRoute", CurrentRoute);

		App.getApp().setProperty("shiftAlerts", ShiftAlerts);
		App.getApp().setProperty("shiftAlertsAvg", ShiftAlertsAvg);
		App.getApp().setProperty("shiftAlertsThreshold", ShiftAlertsThreshold);

		App.getApp().setProperty("portHeadingAvg", PortHeadingAverage);
		App.getApp().setProperty("starboardHeadingAvg", StarboardHeadingAverage);
		App.getApp().setProperty("averageWindDirection", AverageWindDirection);
	}

	static function SetBackground(isWhiteBackground)
	{
		IsWhiteBackground = (isWhiteBackground == null) ? true : isWhiteBackground;
        ForegroundColor = isWhiteBackground ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
        BackgroundColor = isWhiteBackground ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;
        DimColor = isWhiteBackground ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;
	}
	
	static function SetTimerValue(value)
	{
		TimerValue = (value == null) ? 300 : value;
		IsTimerValueUpdated = true;
	}
	
	static function GetTimerValue()
	{
		IsTimerValueUpdated = false; 
		return TimerValue;
	}

	static function SetAutoRecording(isAutoRecording)
	{
		IsAutoRecording = (isAutoRecording == null) ? true : isAutoRecording;
	}

	static function SetShiftAlerts(value)
	{
		ShiftAlerts = (value == null) ? true : value;
	}

	static function SetShiftAlertsAvg(value)
	{
		ShiftAlertsAvg = (value == null) ? TenSeconds : value;
	}

	static function SetPortHeadingAvg(value)
	{
		PortHeadingAverage = (value == null ? 0 : value);
	}

	static function SetStarboardHeadingAvg(value)
	{
		StarboardHeadingAverage = (value == null ? 0 : value);
	}

	static function SetAlertsThreshold(value)
	{
		ShiftAlertsThreshold = (value == null ? 7 : value);
	}

	static function SetAverageWindDirection(value)
	{
		AverageWindDirection = (value == null ? 0 : value);
	}
	
}