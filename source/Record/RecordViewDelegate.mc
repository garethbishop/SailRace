using Toybox.WatchUi as Ui;

class RecordViewDelegate extends Ui.BehaviorDelegate 
{
    hidden var _recordView;
    hidden var _gpsWrapper;
    
    function initialize(recordView, gpsWrapper) 
    {
        BehaviorDelegate.initialize();
        _recordView = recordView;
        _gpsWrapper = gpsWrapper;
    }    

    function onBack() {
        // Pop the current view off the stack
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true; // Indicates the event is handled
    }
    
    function onSelect()
    {
        // if recording available, make sound
        //
    	if (_recordView.pressSelect())
        {
            SignalWrapper.PressButton();
        }
    	return true;
    }

}
