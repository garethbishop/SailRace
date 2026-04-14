using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class RecordView extends Ui.View 
{
    hidden var _gpsWrapper;
	hidden var _timer;
	hidden var _isAvgSpeedDisplay = true;
	hidden var _displayMode = 0;
	hidden var _recordViewDc;

    hidden var _currentTack = "port";
    hidden var _portTackComplete = false;
    hidden var _starboardTackComplete = false;
    hidden var _tacking = false;
    hidden var _recordingStarted = false;
    hidden var _recordingComplete = false;
    hidden var _timerValue = 0;
    hidden var _portTackBearing = 0;
    hidden var _starboardTackBearing = 0;
    hidden var _portSinValues = [];
    hidden var _portCosValues = [];
    hidden var _portTackCount = 0;
    hidden var _totalPortSin = 0;
    hidden var _totalPortCos = 0;
    hidden var _starboardSinValues = [];
    hidden var _starboardCosValues = [];
    hidden var _starboardTackCount = 0;
    hidden var _totalStarboardSin = 0;
    hidden var _totalStarboardCos = 0;
    hidden var _portTackAvg = 0;
    hidden var _starboardTackAvg = 0;
    hidden var _isRecording = false;

    function initialize(gpsWrapper, recordViewDc) 
    {
        View.initialize();
        _gpsWrapper = gpsWrapper;
        _gpsWrapper.IsSessionRecorded = false;
        _recordViewDc = recordViewDc;
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

        // _gpsWrapper.DiscardRecord();
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
    	_recordViewDc.ClearDc(dc);
    
    	// Display current time
    	//
        var clockTime = Sys.getClockTime();
        _recordViewDc.PrintTime(dc, clockTime);
        
        // Display speed and bearing if GPS available
        //
        var gpsInfo = _gpsWrapper.GetGpsInfo();

        _timerValue++;

        var tenSecondBearingDifference = GetHeadingDifference(gpsInfo.CurrentBearingDegree, gpsInfo.TenSecondAvgBearingDegree);

        // if (gpsInfo.Accuracy == 4 && _timerValue >= 5)
        if (gpsInfo.Accuracy > 0 && _timerValue >= 5 && tenSecondBearingDifference > -25 && _isRecording)
        {
            _recordingStarted = true;
        }

        if (_recordingStarted && !_starboardTackComplete)
        {

            // Work out if tacking
            // If port tack completed (tack marks the end of leg)
            if (_currentTack.equals("port") && tenSecondBearingDifference < -25 && !_tacking && _timerValue > 20)
            {
                _tacking = true;
                _portTackComplete = true;
                _totalPortSin = 0;
                _totalPortCos = 0;

                for(var i = 0; i < _portSinValues.size() - 3; i += 1) {
                    _totalPortSin += _portSinValues[i];
                    _totalPortCos += _portCosValues[i];
                }

                _portTackAvg = (Math.toDegrees(Math.atan2(_totalPortSin, _totalPortCos)) + 360).toNumber() % 360;
                
                SignalWrapper.DoubleBeep();
                
            } // If starboard tack completed (tack marks the end of leg)
            else if (_currentTack.equals("starboard") && tenSecondBearingDifference > 25)
            {
                _tacking = true;
                _starboardTackComplete = true;
                _totalStarboardSin = 0;
                _totalStarboardCos = 0;

                for(var i = 0; i < _starboardSinValues.size() - 3; i += 1) {
                    _totalStarboardSin += _starboardSinValues[i];
                    _totalStarboardCos += _starboardCosValues[i];
                }

                _starboardTackAvg = (Math.toDegrees(Math.atan2(_totalStarboardSin, _totalStarboardCos)) + 360).toNumber() % 360;

                SignalWrapper.DoubleBeep();
            }

            // Tacking from port to starboard complete
            if (_tacking && tenSecondBearingDifference > -5)
            {
                _tacking = false;
                _currentTack = "starboard";
                _totalStarboardSin = gpsInfo.SinCurrentBearingSum;
                _totalStarboardCos = gpsInfo.CosCurrentBearingSum;
                _starboardSinValues.add(gpsInfo.SinCurrentBearingSum);
                _starboardCosValues.add(gpsInfo.CosCurrentBearingSum);
            }

            if (!_tacking)
            {

                // Use gpsInfo.Heading to get heading...

                if (_currentTack.equals("port") && !_portTackComplete) {

                    var sinBearing = Math.sin(gpsInfo.Heading);
                    _portSinValues.add(sinBearing);
                    _totalPortSin += sinBearing;

                    var cosBearing = Math.cos(gpsInfo.Heading);
                    _portCosValues.add(cosBearing);
                    _totalPortCos += cosBearing;

                    _portTackAvg = (Math.toDegrees(Math.atan2(_totalPortSin, _totalPortCos)) + 360).toNumber() % 360;

                    _recordViewDc.PrintCurrentBearing(dc, _portTackAvg);

                } else if (_currentTack.equals("starboard") && !_starboardTackComplete) {

                    var sinBearing = Math.sin(gpsInfo.Heading);
                    _starboardSinValues.add(sinBearing);
                    _totalStarboardSin += sinBearing;

                    var cosBearing = Math.cos(gpsInfo.Heading);
                    _starboardCosValues.add(cosBearing);
                    _totalStarboardCos += cosBearing;

                    _starboardTackAvg = (Math.toDegrees(Math.atan2(_totalStarboardSin, _totalStarboardCos)) + 360).toNumber() % 360;

                    _recordViewDc.PrintCurrentBearing(dc, _starboardTackAvg);
                }

            }

            if (_tacking) {
                _recordViewDc.PrintCurrentTack(dc, "tacking");
            } else {
                _recordViewDc.PrintCurrentTack(dc, _currentTack);
            }

            if (_portTackComplete && _starboardTackComplete) {

                completeRecording();
                resetValues();
            }

        }

        if (_starboardTackComplete)
        {
            _recordViewDc.ClearDc(dc);
            _recordViewDc.PrintCurrentTack(dc, "complete");
            // completeRecording();
            
        }



        
        _recordViewDc.DisplayState(dc, gpsInfo.Accuracy, _isRecording);
        
    }

    public function pressSelect() {
        if (!_isRecording) {
            _isRecording = true;
            _portTackComplete = false;
            _starboardTackComplete = false;
            _timerValue = 0;  //Restart timer whe select is pressed
            // resetValues();
            // _timer = new Toybox.Timer.Timer();
    	    // _timer.start(method(:onTimerUpdate), 1000, true);
            return true;
        } else {
            // completeRecording();
            resetValues();
            return true;
        }
    }

    public function completeRecording() as Void {

        // Save settings/properties
        Settings.PortHeadingAverage = _portTackAvg;
        Settings.StarboardHeadingAverage = _starboardTackAvg;

        var avgWindDirection = 0;

        if (_starboardTackAvg > _portTackAvg)
        {
            avgWindDirection = ((_portTackAvg - (360 - _starboardTackAvg)) / 2) + _portTackAvg;
            if (avgWindDirection > 359)
            {
                avgWindDirection -= 360;
            }
        }
        else
        {
            avgWindDirection = ((_portTackAvg - _starboardTackAvg) / 2) + _starboardTackAvg;
        }
        
        Settings.AverageWindDirection = avgWindDirection;
        
        _isRecording = false;

        

        // _timer.stop();

        // resetValues();
    }

    function resetValues() {
        _currentTack = "port";
        // _portTackComplete = false;
        // _starboardTackComplete = false;
        _tacking = false;
        _recordingStarted = false;
        _recordingComplete = false;
        _timerValue = 0;
        _portTackBearing = 0;
        _starboardTackBearing = 0;
        _portSinValues = [];
        _portCosValues = [];
        _portTackCount = 0;
        _totalPortSin = 0;
        _totalPortCos = 0;
        _starboardSinValues = [];
        _starboardCosValues = [];
        _starboardTackCount = 0;
        _totalStarboardSin = 0;
        _totalStarboardCos = 0;
        _portTackAvg = 0;
        _starboardTackAvg = 0;
        _isRecording = false;

    }
function GetHeadingDifference(current, previous)
        {
            var diff = current - previous;
         
            if (diff > 180) {
                diff -= 360;
            }

            return diff;
        }

    
}