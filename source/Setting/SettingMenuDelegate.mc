using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

// setting menu handler
//
class SettingMenuDelegate extends Ui.MenuInputDelegate 
{
    hidden var _raceTimerView;
    
    function initialize(raceTimerView) 
    {
        MenuInputDelegate.initialize();
        _raceTimerView = raceTimerView;
    }

    function onMenuItem(item) 
    {
        if (item == :setTimer)
        {
            Ui.pushView(new Rez.Menus.SetTimerMenu(), new SetTimerMenuDelegate(_raceTimerView), Ui.SLIDE_LEFT);
        } 
        else if (item == :backgroundColor)
        {
        	var backgroundMenu = new Ui.Menu(); 
        	backgroundMenu.setTitle("Background Color");
            backgroundMenu.addItem((Settings.IsWhiteBackground ? "*" : "") + " White", :white);
            backgroundMenu.addItem((Settings.IsWhiteBackground ? "" : "*") + " Black", :black);
        	Ui.pushView(backgroundMenu, new BackgroundColorMenuDelegate(), Ui.SLIDE_LEFT);
        }  
        else if (item == :isAutoStartRecording)
        {
            var autoRecordingMenu = new Ui.Menu();
            autoRecordingMenu.setTitle("Auto Recording");
            autoRecordingMenu.addItem((Settings.IsAutoRecording ? "*" : "") + " On", :isAutoOn);
            autoRecordingMenu.addItem((Settings.IsAutoRecording ? "" : "*") + " Off", :isAutoOff);
            Ui.pushView(autoRecordingMenu, new AutoRecordingMenuDelegate(), Ui.SLIDE_LEFT);
        }
        // else if (item == :afterTimer)
        // {
        //     var afterTimerMenu = new Ui.Menu();
        //     afterTimerMenu.setTitle("After countdown");
        //     afterTimerMenu.addItem((Settings.TimerSuccessor == Settings.Cruise ? "*" : "") + " Run Cruise", :setCruise);
        //     afterTimerMenu.addItem((Settings.TimerSuccessor == Settings.Route ? "*" : "") + " Run Route", :setRoute);
        //     Ui.pushView(afterTimerMenu, new AfterTimerMenuDelegate(), Ui.SLIDE_LEFT);
        // }

        else if (item == :shiftAlerts)
        {
            var shiftAlertsMenu = new Ui.Menu();
            shiftAlertsMenu.setTitle("Shift Alerts");
            shiftAlertsMenu.addItem((Settings.ShiftAlerts ? "*" : "") + " On", :shiftAlertsOn);
            shiftAlertsMenu.addItem((Settings.ShiftAlerts ? "" : "*") + " Off", :shiftAlertsOff);
            Ui.pushView(shiftAlertsMenu, new ShiftAlertsMenuDelegate(), Ui.SLIDE_LEFT);
        }

        else if (item == :shiftAlertsAvg)
        {
            var shiftAlertsAvgMenu = new Ui.Menu();
            shiftAlertsAvgMenu.setTitle("Shift Alerts Average");
            shiftAlertsAvgMenu.addItem((Settings.ShiftAlertsAvg == Settings.TenSeconds ? "*" : "") + " 10 Seconds", :setTenSeconds);
            shiftAlertsAvgMenu.addItem((Settings.ShiftAlertsAvg == Settings.Continuous ? "*" : "") + " Continuous", :setContinuous);
            shiftAlertsAvgMenu.addItem((Settings.ShiftAlertsAvg == Settings.Recorded ? "*" : "") + " Recorded", :setRecorded);
            Ui.pushView(shiftAlertsAvgMenu, new ShiftAlertsAvgMenuDelegate(), Ui.SLIDE_LEFT);
        }
        
        if (item == :shiftAlertsThreshold)
        {
            var shiftAlertsThresholdMenu = new Ui.Menu();
            shiftAlertsThresholdMenu.setTitle("Shift Alerts Threshold");
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 1 ? "*" : "") + " 1°", :set1Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 2 ? "*" : "") + " 2°", :set2Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 3 ? "*" : "") + " 3°", :set3Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 4 ? "*" : "") + " 4°", :set4Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 5 ? "*" : "") + " 5°", :set5Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 6 ? "*" : "") + " 6°", :set6Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 7 ? "*" : "") + " 7°", :set7Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 8 ? "*" : "") + " 8°", :set8Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 9 ? "*" : "") + " 9°", :set9Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 10 ? "*" : "") + " 10°", :set10Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 11 ? "*" : "") + " 11°", :set11Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 12 ? "*" : "") + " 12°", :set12Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 13 ? "*" : "") + " 13°", :set13Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 14 ? "*" : "") + " 14°", :set14Deg);
            shiftAlertsThresholdMenu.addItem((Settings.ShiftAlertsThreshold == 15 ? "*" : "") + " 15°", :set15Deg);
            Ui.pushView(shiftAlertsThresholdMenu, new ShiftAlertsThresholdMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if (item == :recordedHeadings)
        {
            var recordedHeadingsMenu = new Ui.Menu2({:title=>"Recorded Headings"});
            var portHeadingItem = new Ui.MenuItem(
                "Port Heading",
                Settings.PortHeadingAverage == null ? "N/A" : Settings.PortHeadingAverage.toString() + "°",
                "ph_id",
                {}
            );
            var starboardHeadingItem = new Ui.MenuItem(
                "Starboard Heading",
                Settings.StarboardHeadingAverage == null ? "N/A" : Settings.StarboardHeadingAverage.toString() + "°",
                "ph_id",
                {}
            );
            var avgWindDirectionItem = new Ui.MenuItem(
                "Average Wind Direction",
                Settings.AverageWindDirection == null ? "N/A" : Settings.AverageWindDirection.toString() + "°",
                "ph_id",
                {}
            );
            recordedHeadingsMenu.addItem(portHeadingItem);
            recordedHeadingsMenu.addItem(starboardHeadingItem);
            recordedHeadingsMenu.addItem(avgWindDirectionItem);
            Ui.pushView(recordedHeadingsMenu, new DummyMenuDelegate(), Ui.SLIDE_LEFT);

            // autoRecordingMenu.setTitle("Recorded Headings");
            // autoRecordingMenu.addItem((Settings.IsAutoRecording ? "*" : "") + " On", :isAutoOn);
            // autoRecordingMenu.addItem((Settings.IsAutoRecording ? "" : "*") + " Off", :isAutoOff);
            // Ui.pushView(autoRecordingMenu, new AutoRecordingMenuDelegate(), Ui.SLIDE_LEFT);
        }
    }
}

class BackgroundColorMenuDelegate extends Ui.MenuInputDelegate 
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) 
    {
        if (item == :white)
        {
            Settings.SetBackground(true);
        } 
        else if (item == :black)
        {
            Settings.SetBackground(false);
        }  
    }
}

class AutoRecordingMenuDelegate extends Ui.MenuInputDelegate 
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }
    
    function onMenuItem(item) 
    {
        if (item == :isAutoOn)
        {
            Settings.SetAutoRecording(true);
        }
        else if (item == :isAutoOff)
        {
            Settings.SetAutoRecording(false);
        }
    }
}

class AfterTimerMenuDelegate extends Ui.MenuInputDelegate
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }
    
    function onMenuItem(item) 
    {
        if (item == :setCruise)
        {
            Settings.TimerSuccessor = Settings.Cruise;
        }
        else if (item == :setRoute)
        {
            Settings.TimerSuccessor = Settings.Route;
        }
    }
}

class ShiftAlertsMenuDelegate extends Ui.MenuInputDelegate 
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }
    
    function onMenuItem(item) 
    {
        if (item == :shiftAlertsOn)
        {
            Settings.SetShiftAlerts(true);
        }
        else if (item == :shiftAlertsOff)
        {
            Settings.SetShiftAlerts(false);
        }
    }
}

class ShiftAlertsAvgMenuDelegate extends Ui.MenuInputDelegate
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }
    
    function onMenuItem(item) 
    {
        if (item == :setTenSeconds)
        {
            Settings.ShiftAlertsAvg = Settings.TenSeconds;
        }
        else if (item == :setContinuous)
        {
            Settings.ShiftAlertsAvg = Settings.Continuous;
        }
        else if (item == :setRecorded)
        {
            Settings.ShiftAlertsAvg = Settings.Recorded;
        }
    }
}

class ShiftAlertsThresholdMenuDelegate extends Ui.MenuInputDelegate
{
    function initialize() 
    {
        MenuInputDelegate.initialize();
    }
    
    function onMenuItem(item) 
    {
        if (item == :set1Deg)
        {
            Settings.ShiftAlertsThreshold = 1;
        }
        else if (item == :set2Deg)
        {
            Settings.ShiftAlertsThreshold = 2;
        }
        else if (item == :set3Deg)
        {
            Settings.ShiftAlertsThreshold = 3;
        }
        else if (item == :set4Deg)
        {
            Settings.ShiftAlertsThreshold = 4;
        }
        else if (item == :set5Deg)
        {
            Settings.ShiftAlertsThreshold = 5;
        }
        else if (item == :set6Deg)
        {
            Settings.ShiftAlertsThreshold = 6;
        }
        else if (item == :set7Deg)
        {
            Settings.ShiftAlertsThreshold = 7;
        }
        else if (item == :set8Deg)
        {
            Settings.ShiftAlertsThreshold = 8;
        }
        else if (item == :set9Deg)
        {
            Settings.ShiftAlertsThreshold = 9;
        }
        else if (item == :set10Deg)
        {
            Settings.ShiftAlertsThreshold = 10;
        }
        else if (item == :set11Deg)
        {
            Settings.ShiftAlertsThreshold = 11;
        }
        else if (item == :set12Deg)
        {
            Settings.ShiftAlertsThreshold = 12;
        }
        else if (item == :set13Deg)
        {
            Settings.ShiftAlertsThreshold = 13;
        }
        else if (item == :set14Deg)
        {
            Settings.ShiftAlertsThreshold = 14;
        }
        else if (item == :set15Deg)
        {
            Settings.ShiftAlertsThreshold = 15;
        }
    }
}



class DummyMenuDelegate extends Ui.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }
    function onSelect(item) {
        // Do nothing when an item is clicked
    }
}