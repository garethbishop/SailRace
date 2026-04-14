// class to pass actual gps data
//
class GpsInfo
{
	// GPS signal accuracy
	//
	var Accuracy = 0;

	// actual speed in Knots
	//
	var SpeedKnot = 0.0;

	// max speed in knots
	//
	var MaxSpeedKnot = 0.0;

	// avg speed in knots for 10 sec.
	//
	var AvgSpeedKnot = 0.0;

	// Bearing in degree 0-360
	//
	var BearingDegree = 0;

	// Heading in radians
	//
	var Heading = 0;

	// total number of laps
	//
	var LapCount = 0;

	// is activity recorded
	//
	var IsRecording = false;

	// sliding avg bearing for e.g. 5 sec.
	//
	var CurrentBearingDegree = 0;

	var SinCurrentBearingSum = 0;
	var CosCurrentBearingSum = 0;

	// sliding avg bearing for 30 sec.
	//
	// var AvgBearingDegree = 0;

	var TenSecondAvgBearingDegree = 0;

	var ContinuousAvgBearingDegree = 0;
	
	// Total distance covered
	//
	var TotalDistance = 0.0;
	
	// Actual location
	//
	var GpsLocation = null;

}