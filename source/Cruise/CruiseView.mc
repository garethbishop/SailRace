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
    // hidden var _startedTack = 0;
    hidden var _tacking = false;

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
        _gpsWrapper.IsSessionRecorded = true;
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

            if (Settings.ShiftAlertsAvg == Settings.Recorded)
            {
                analyseRecordedData(dc, gpsInfo);
            }
            else
            {

                var tenSecondBearingDifference = gpsInfo.CurrentBearingDegree - gpsInfo.TenSecondAvgBearingDegree;
                var continuousBearingDifference = gpsInfo.CurrentBearingDegree - gpsInfo.ContinuousAvgBearingDegree;
                // }

                var bearingDifference =  0;
                // var tack = "port";

                if (Settings.ShiftAlertsAvg == Settings.TenSeconds) {
                    bearingDifference = tenSecondBearingDifference;
                } else if (Settings.ShiftAlertsAvg == Settings.Continuous) {
                    bearingDifference = continuousBearingDifference;
                }

                if (bearingDifference > 180) {
                    bearingDifference -= 360;
                } else if (bearingDifference < -180) {
                    bearingDifference += 360;
                }

                // Print numbers on screen
                _cruiseViewDc.PrintCurrentBearing(dc, gpsInfo.CurrentBearingDegree);

                if (Settings.ShiftAlertsAvg == Settings.TenSeconds) {
                    _cruiseViewDc.PrintAverageBearing(dc, gpsInfo.TenSecondAvgBearingDegree);
                } else if (Settings.ShiftAlertsAvg == Settings.Continuous) {
                    _cruiseViewDc.PrintAverageBearing(dc, gpsInfo.ContinuousAvgBearingDegree);
                } 
                
                _cruiseViewDc.PrintBearingDifference(dc, bearingDifference);

                _cruiseViewDc.DrawGrid(dc);

                if ((tenSecondBearingDifference > 35 || tenSecondBearingDifference < -35) && !_tacking) {
                    // If tacking, wait 20 seconds until next alert
                    _shiftAlertCountdown = 20;
                    _tacking = true;
                } else if (_shiftAlertCountdown == 0 && !_tacking) {
                    if (bearingDifference >= Settings.ShiftAlertsThreshold && tenSecondBearingDifference < 35) {
                        if (Settings.ShiftAlerts) {
                            // SignalWrapper.SingleBeep();
                            SignalWrapper.CanaryTone();
                        }
                        _shiftAlertCountdown = 10;
                    } else if (bearingDifference <= (0-Settings.ShiftAlertsThreshold) && tenSecondBearingDifference > -35) {
                        if (Settings.ShiftAlerts) {
                            // SignalWrapper.DoubleBeep();
                            SignalWrapper.DoubleCanaryTone();
                        }
                        _shiftAlertCountdown = 10;
                    } 
                } else {
                    _shiftAlertCountdown--;
                }

                if (_tacking && tenSecondBearingDifference < 5) {
                    // After tack completed, reset continuous sin/cos totals
                    _tacking = false;
                    _gpsWrapper.resetAverageSinCosTotals();
                }

            }

        }
        
        _cruiseViewDc.DisplayState(dc, gpsInfo.Accuracy, gpsInfo.IsRecording, gpsInfo.LapCount);
        
    }
    
    function analyseRecordedData(dc, gpsInfo)
    {
        var tack = "port";
        var bearingDifference = 0;

        var currentBearingDegree = gpsInfo.CurrentBearingDegree;
        var starboardHeadingAverage = Settings.StarboardHeadingAverage;
        var portHeadingAverage = Settings.PortHeadingAverage;
        var starboardBearingDifference = gpsInfo.CurrentBearingDegree - Settings.StarboardHeadingAverage;
        var portBearingDifference = gpsInfo.CurrentBearingDegree - Settings.PortHeadingAverage;

        if (portBearingDifference > 180) {
            portBearingDifference -= 360;
        } else if (portBearingDifference < -180) {
            portBearingDifference += 360;
        }

        if (starboardBearingDifference > 180) {
            starboardBearingDifference -= 360;
        } else if (starboardBearingDifference < -180) {
            starboardBearingDifference += 360;
        }

        if (portBearingDifference.abs() < starboardBearingDifference.abs()) {
            bearingDifference = portBearingDifference;
            tack = "port";
        } else {
            bearingDifference = starboardBearingDifference;
            tack = "starboard";
        }

        if (bearingDifference > 180) {
            bearingDifference -= 360;
        } else if (bearingDifference < -180) {
            bearingDifference += 360;
        }

        _cruiseViewDc.PrintRecordedData(dc, gpsInfo.CurrentBearingDegree, bearingDifference, tack);

    }

    // function SwitchNextMode()
    // {
    // 	_displayMode += 1;
    // 	_displayMode = _displayMode % 2;
    // }
}