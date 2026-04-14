using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Fit;

/// Helper class to work with GPS features
///
class GpsWrapper
{
    hidden var _lastTimeCall = 0l;
    hidden var _activeSession;
    hidden var _isAutoRecordStart = false;

    // hidden var _isSessionRecorded = true;
    var IsSessionRecorded = true;

    // avg for 10 sec. values (speed)
    //
	hidden var _avgSpeedIterator = 0;
	hidden var _avgSpeedSum = 0;
	hidden var _avgSpeedValues = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
	
	// max for3 sec. values (speed)
    //
	hidden var _maxSpeedIterator = 0;
	hidden var _maxSpeedSum = 0;
	hidden var _maxSpeedValues = [0, 0, 0];


    // avg for e.g. 5 sec. values (bearing)
    //
    // hidden var _currentSinValues = [0, 0, 0, 0, 0];
    // hidden var _currentCosValues = [0, 0, 0, 0, 0];

    hidden var _currentSinValues = [];
    hidden var _currentCosValues = [];

    hidden var _alpha;

    hidden var _currentSmoothedSinValues = [];
    hidden var _currentSmoothedCosValues = [];

    hidden var _sinCurrentBearingSum = 0;
    hidden var _cosCurrentBearingSum = 0;
    hidden var _currentBearingDegree = 0;
    hidden var _currentBearingIterator = 0;

    // avg for e.g. 30 sec. values (bearing)
    //
    // hidden var _averageSinValues = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    // hidden var _averageCosValues = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    hidden var _averageSinValues = [];
    hidden var _averageCosValues = [];

    hidden var _continuousSinTotal = 0;
    hidden var _continuousCosTotal = 0;

    hidden var _sinAverageBearingSum = 0;
    hidden var _cosAverageBearingSum = 0;
    hidden var _tenSecondAverageBearingDegree = 0;
    hidden var _continuousAverageBearingDegree = 0;
    hidden var _averageBearingIterator = 0;

    // actual gps values
    //
	hidden var _speedKnot = 0.0;
    hidden var _accuracy = 0;
    hidden var _bearingDegree = 0;
    hidden var _heading = 0;
    hidden var _location = null;

    // global values
    //
    hidden var _startTime;
    hidden var _distance = 0;
    hidden var _duration = 0;
    hidden var _maxSpeedKnot = 0;

    // lap values
    //
	hidden var _currentLap = new LapInfo();
	hidden var _lapArray = new [0];
	hidden var _lapCount = 0;

    const LAP_ARRAY_MAX = 20;
    const MAX_SPEED_INTERVAL = 3;
    const AVG_SPEED_INTERVAL = 10;

    const CURRENT_BEARING_INTERVAL = 10;
    const AVG_BEARING_INTERVAL = 10;

    const METERS_PER_NAUTICAL_MILE = 1852;
    const MS_TO_KNOT = 1.9438444924574;

    function initialize()
    {
        var deviceSettings = Sys.getDeviceSettings();

        if(deviceSettings.monkeyVersion[0] >= 3) {
            _activeSession = Fit.createSession({:name => "Sailing", :sport => Fit.SPORT_SAILING});    
        } else {
            _activeSession = Fit.createSession({:name => "Sailing", :sport => Fit.SPORT_GENERIC});
        }

        for(var i = 0; i < CURRENT_BEARING_INTERVAL; i += 1) {
            _currentSinValues.add(0);
            _currentCosValues.add(0);
        }

        for(var i = 0; i < AVG_BEARING_INTERVAL; i += 1) {
            _averageSinValues.add(0);
            _averageCosValues.add(0);
        }
        
    }

	function SetPositionInfo(positionInfo)
	{
        _accuracy = (positionInfo != null) ? positionInfo.accuracy : 0;
        if (_accuracy < 1 )
        {
            return;
        }

        _heading = (positionInfo.heading != null) ? positionInfo.heading : 0;

        // autostart recording 
        //
        if (IsSessionRecorded)
        {
            if (!_isAutoRecordStart && Settings.IsAutoRecording)
            {
                _isAutoRecordStart = StartStopRecording();
            }
        }

        // difference between two method's calls 
        //
        var timeCall = Sys.getTimer();
        var timelaps = (_lastTimeCall > 0) ? timeCall - _lastTimeCall : 0;
        _lastTimeCall = timeCall;

        _speedKnot = positionInfo.speed.toDouble() * MS_TO_KNOT;
        _bearingDegree = (Math.toDegrees(positionInfo.heading) + 360).toNumber() % 360;

		// moving max speed : in order to avoid fluctuation, max speed take as avg from 3 values
		//
		_maxSpeedSum = _maxSpeedSum - _maxSpeedValues[_maxSpeedIterator] + _speedKnot;
        _maxSpeedValues[_maxSpeedIterator] = _speedKnot;
        _maxSpeedIterator = (_maxSpeedIterator + 1) % MAX_SPEED_INTERVAL;
        var maxSpeed = _maxSpeedSum / MAX_SPEED_INTERVAL;
        _maxSpeedKnot = (_maxSpeedKnot < maxSpeed) ? maxSpeed : _maxSpeedKnot;
		_currentLap.MaxSpeedKnot = (_currentLap.MaxSpeedKnot < maxSpeed) ? maxSpeed : _currentLap.MaxSpeedKnot;
        
        // moving avg speed 
        //
        _avgSpeedSum = _avgSpeedSum - _avgSpeedValues[_avgSpeedIterator] + _speedKnot;
        _avgSpeedValues[_avgSpeedIterator] = _speedKnot;
        _avgSpeedIterator = (_avgSpeedIterator + 1) % AVG_SPEED_INTERVAL;

        // moving avg bearing for current bearing
        //
        var sinBearing = Math.sin(positionInfo.heading);
        var cosBearing = Math.cos(positionInfo.heading);

        // Record oldest current bearing sin/cos values before getting overwritten
        var  sinOldestCurrentBearing = _currentSinValues[_currentBearingIterator];
        var cosOldestCurrentBearing = _currentCosValues[_currentBearingIterator];


        // Sum up sin/cos values for last 10 seconds with new values replacing oldest
        _sinCurrentBearingSum = _sinCurrentBearingSum - sinOldestCurrentBearing + sinBearing;
        _currentSinValues[_currentBearingIterator] = sinBearing;
        _cosCurrentBearingSum = _cosCurrentBearingSum - cosOldestCurrentBearing + cosBearing;
        _currentCosValues[_currentBearingIterator] = cosBearing;
        // Use inverse tan to get angle from sin/cos sums
        _currentBearingDegree = (Math.toDegrees(Math.atan2(_sinCurrentBearingSum, _cosCurrentBearingSum)) + 360).toNumber() % 360;
        _currentBearingIterator = (_currentBearingIterator + 1) % CURRENT_BEARING_INTERVAL;

        // Sum up sin/cos values for previous 10 seconds with oldest 'current' value replacing oldest 'average' value 
        _sinAverageBearingSum = _sinAverageBearingSum - _averageSinValues[_averageBearingIterator] + sinOldestCurrentBearing;
        _averageSinValues[_averageBearingIterator] = sinOldestCurrentBearing;
        _cosAverageBearingSum = _cosAverageBearingSum - _averageCosValues[_averageBearingIterator] + cosOldestCurrentBearing;
        _averageCosValues[_averageBearingIterator] = cosOldestCurrentBearing;
        // Use inverse tan to get angles from sin/cos sums
        _tenSecondAverageBearingDegree = (Math.toDegrees(Math.atan2(_sinAverageBearingSum, _cosAverageBearingSum)) + 360).toNumber() % 360;
        _averageBearingIterator = (_averageBearingIterator + 1) % AVG_BEARING_INTERVAL;

        _continuousSinTotal += sinOldestCurrentBearing;
        _continuousCosTotal += cosOldestCurrentBearing;

        _continuousAverageBearingDegree = (Math.toDegrees(Math.atan2(_continuousSinTotal, _continuousCosTotal)) + 360).toNumber() % 360;


        var timelapsSecond = timelaps.toDouble() / 1000;
        _distance += positionInfo.speed * timelapsSecond;
        _duration += timelapsSecond;
        
        _location = positionInfo.position;
	}

	// return all calculated data from GPS 
	//
    function GetGpsInfo()
    {
        var gpsInfo = new GpsInfo();
        gpsInfo.Accuracy = _accuracy;
        gpsInfo.Heading = _heading;
        gpsInfo.SpeedKnot = _speedKnot;
        gpsInfo.BearingDegree = _bearingDegree;
        gpsInfo.AvgSpeedKnot = _avgSpeedSum / AVG_SPEED_INTERVAL;
        gpsInfo.MaxSpeedKnot = _maxSpeedKnot;
        gpsInfo.IsRecording = _activeSession.isRecording();
        gpsInfo.LapCount = _lapCount;
        gpsInfo.CurrentBearingDegree = _currentBearingDegree;
        gpsInfo.SinCurrentBearingSum = _sinCurrentBearingSum;
        gpsInfo.CosCurrentBearingSum = _cosCurrentBearingSum;
        gpsInfo.TenSecondAvgBearingDegree = _tenSecondAverageBearingDegree;
        gpsInfo.ContinuousAvgBearingDegree = _continuousAverageBearingDegree;
        gpsInfo.TotalDistance = _distance / METERS_PER_NAUTICAL_MILE;
        gpsInfo.GpsLocation = _location; 

        return gpsInfo;
    }

    // Add new lap statistic
    //
    function AddLap()
    {
        // count lap only when recording
        //
        if (!_activeSession.isRecording())
        {
            return false;
        }

        _activeSession.addLap();

        saveLap();

        //LogWrapper.WriteLapStatistic(_currentLap);

        _currentLap = newLap();
       
        return true;       
    }

    // Start & Pause activity recording
    //
    function StartStopRecording()
    {
        if (_accuracy < 2 && !_activeSession.isRecording())
        {
            return false;
        }
        
        if (_activeSession.isRecording())
        {
            _activeSession.stop();
            saveLap();
        }
        else
        {
            _activeSession.start();
            _startTime = (_startTime == null) ? Time.now() : _startTime;
            _currentLap = newLap();
        }
        return true;
    }

    function SaveRecord()
    {
        if (_activeSession != null)
        {
            _activeSession.save();
        }
    }
    
    function DiscardRecord()
    {
        if (_activeSession != null)
        {
            _activeSession.discard();
        }
    }    

	// returns lap data
	//
    function GetLapArray()
    {
    	return _lapArray;
    }
    
    // initialize lap data from external source
    //
    function SetLapArray(lapArray)
    {
    	_lapArray = lapArray;
    	_lapCount = (lapArray.size() > 0)
    		? lapArray[lapArray.size() - 1].LapNumber + 1
    		: 0;
    	_currentLap.LapNumber = _lapCount;
    }

	// return data collected while application was run
	//
    function GetAppStatistic()
    {
        var overall = new LapInfo();
        overall.StartTime = _startTime;
        overall.MaxSpeedKnot = _maxSpeedKnot;
        overall.Distance = _distance / METERS_PER_NAUTICAL_MILE;
        overall.Duration = _duration;
        overall.AvgSpeedKnot =  (_duration > 0) ? overall.Distance / (_duration / Time.Gregorian.SECONDS_PER_HOUR) : 0;
        return overall;
    }

    // save lap statistic to local array
    //
    hidden function saveLap()
    {
        // calculate lap statistics
        //
        _currentLap.Distance = (_distance - _currentLap.Distance) / METERS_PER_NAUTICAL_MILE;
        _currentLap.Duration = (_duration - _currentLap.Duration);
        _currentLap.AvgSpeedKnot = (_currentLap.Duration > 0)
            ? _currentLap.Distance/(_currentLap.Duration.toDouble() / Time.Gregorian.SECONDS_PER_HOUR)
            : 0;

        _lapArray.add(_currentLap);
        
        // no more than 999 laps 
        //
        _lapCount = (_lapCount + 1) % 999;

        // if array oversized - remove oldest element
        //
        if (_lapArray.size() > LAP_ARRAY_MAX)
        {
            _lapArray = _lapArray.slice(1, null);
        }
    }

    // initialize new lap 
    //
    hidden function newLap()
    {
        // Store some current global values to calculate difference later
        //
        var lapInfo = new LapInfo();
        lapInfo.StartTime = Time.now();
        lapInfo.Distance = _distance;        
        lapInfo.Duration = _duration;
        lapInfo.LapNumber = _lapCount;   
        return lapInfo;     
    }

    public function resetAverageSinCosTotals() as Void {
        _continuousSinTotal = _sinCurrentBearingSum;
        _continuousCosTotal = _cosCurrentBearingSum;
	}
}