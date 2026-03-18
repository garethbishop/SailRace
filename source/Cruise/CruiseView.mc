using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class CruiseView extends Ui.View 
{
    hidden var _gpsWrapper;
	hidden var _timer;
	hidden var _isAvgSpeedDisplay = true;
	hidden var _displayMode = 0;
	hidden var _cruiseViewDc;

    hidden var _shiftAlertCountdown = 20;

    function initialize(gpsWrapper, cruiseViewDc) 
    {
        View.initialize();
        _gpsWrapper = gpsWrapper;
        _cruiseViewDc = cruiseViewDc;
    }

	// SetUp timer on show to update every second
    //
    function onShow() 
    {
    	_timer = new Toybox.Timer.Timer();
    	_timer.start(method(:onTimerUpdate), 1000, true);
    }

    // Stop timer then hide
    //
    function onHide() 
    {
        _timer.stop();
    }
    
    // Refresh view every second
    //
    function onTimerUpdate() as Void
    {
        Ui.requestUpdate();
    }    

    // Update the view
    //
    function onUpdate(dc) 
    {   
    	_cruiseViewDc.ClearDc(dc);
    
    	// Display current time
    	//
        var clockTime = Sys.getClockTime();
        _cruiseViewDc.PrintTime(dc, clockTime);
        
        // Display speed and bearing if GPS available
        //
        var gpsInfo = _gpsWrapper.GetGpsInfo();
        if (gpsInfo.Accuracy > 0)
        {
        	// _cruiseViewDc.PrintSpeed(dc, gpsInfo.SpeedKnot);
        	// _cruiseViewDc.PrintBearing(dc, gpsInfo.BearingDegree);

            var bearingDifference = gpsInfo.CurrentBearingDegree - gpsInfo.AvgBearingDegree;
            if (bearingDifference > 200) {
                bearingDifference -= 360;
            } else if (bearingDifference < -200) {
                bearingDifference += 360;
            }

            _cruiseViewDc.PrintCurrentBearing(dc, gpsInfo.CurrentBearingDegree);
            _cruiseViewDc.PrintAverageBearing(dc, gpsInfo.AvgBearingDegree);
            _cruiseViewDc.PrintBearingDifference(dc, bearingDifference);

            Settings.LoadSettings();

            if (Settings.ShiftAlerts) {
                if (bearingDifference > 30 || bearingDifference < -30) {
                    _shiftAlertCountdown = 20 ;
                } else if (_shiftAlertCountdown == 0) {
                    if (bearingDifference >= 10 && bearingDifference < 30) {
                        // SignalWrapper.SingleBeep();
                        SignalWrapper.CanaryTone();
                        _shiftAlertCountdown = 10;
                    } else if (bearingDifference <= -10 && bearingDifference > -30) {
                        // SignalWrapper.DoubleBeep();
                        SignalWrapper.DoubleCanaryTone();
                        _shiftAlertCountdown = 10;
                    } 
                } else {
                    _shiftAlertCountdown--;
                } 
            }

        	// _cruiseViewDc.PrintMaxSpeed(dc, gpsInfo.MaxSpeedKnot);	
        	// _cruiseViewDc.PrintTotalDistance(dc, gpsInfo.TotalDistance);
        	
        	// if (_displayMode == 0)
        	// {
        	// 	_cruiseViewDc.PrintAvgBearing(dc, gpsInfo.AvgBearingDegree);
        	// } 
        	// else if (_displayMode == 1)
        	// {
        	// 	_cruiseViewDc.PrintAvgSpeed(dc, gpsInfo.AvgSpeedKnot);
        	// } 

        	// Display speed gradient. If current speed > avg speed then trend is positive and vice versa.
        	//
        	// _cruiseViewDc.DisplaySpeedTrend(dc, gpsInfo.SpeedKnot - gpsInfo.AvgSpeedKnot, gpsInfo.SpeedKnot); 
        }
        
        _cruiseViewDc.DisplayState(dc, gpsInfo.Accuracy, gpsInfo.IsRecording, gpsInfo.LapCount);
        
        _cruiseViewDc.DrawGrid(dc);
    }
    
    function SwitchNextMode()
    {
    	_displayMode += 1;
    	_displayMode = _displayMode % 2;
    }
}