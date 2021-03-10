package {

import flash.display.MovieClip;
import flash.external.ExternalInterface;
import flash.net.NetConnection;
import flash.events.NetStatusEvent;
import flash.net.NetStream;
import flash.media.Microphone;

public class AudioOnlyRtmpStreamer extends MovieClip {

    internal var nc:NetConnection;
    internal var ns:NetStream;
    internal var mic:Microphone;

    // The encoded speech quality when using the Speex codec. Possible values are from 0 to 10.
    // The default value is 6. Higher numbers represent higher quality but require more bandwidth, as shown in the following table.
    // The bit rate values that are listed represent net bit rates and do not include packetization overhead.
    // ------------------------------------------
	//  Quality value | Required bit rate (kbps)
	// -------------------------------------------
	//       0        |       3.95
	//       1        |       5.75
	//       2        |       7.75
	//       3        |       9.80
	//       4        |       12.8
	//       5        |       16.8
	//       6        |       20.6
	//       7        |       23.8
	//       8        |       27.8
	//       9        |       34.2
	//       10       |       42.2
	// -------------------------------------------
    internal var _micQuality:int = 10;

    // The rate at which the microphone is capturing sound, in kHz. Acceptable values are 5, 8, 11, 22, and 44.
    // The default value is 8 kHz if your sound capture device supports this value. Otherwise, the default value is the next available capture level above 8 kHz that your sound capture device supports, usually 11 kHz.
    // -------------------------------
    // rate value   |   Actual frequency
    // -------------------------------
    //  44          |   44,100 Hz
    //  22          |   22,050 Hz
    //  11	        |   11,025 Hz
    //  8	        |   8,000 Hz
    //  5	        |   5,512 Hz
    internal var _micRate:int = 44;

    // The amount of sound required to activate the microphone and dispatch the activity event.
    // The default value is 10.
    internal var _micSilenceLevel:Number = 0

    // The number of milliseconds between the time the microphone stops detecting sound and the time the activity event is dispatched.
    // The default value is 2000 (2 seconds).
    internal var _micSilenceTimeout:int = 10000

    // The amount by which the microphone boosts the signal. Valid values are 0 to 100.
    // The default value is 50.
    internal var _micGain:Number = 100

    // Set to true if echo suppression is enabled; false otherwise.
    // The default value is false unless the user has selected Reduce Echo in the Flash Player Microphone Settings panel.
    internal var _micUseEchoSuppression:Boolean = true

    public function AudioOnlyRtmpStreamer() {
        ExternalInterface.addCallback("setMicQuality", setMicQuality);
        ExternalInterface.addCallback("setMicRate", setMicRate);
        ExternalInterface.addCallback("setSilenceLevel", setSilenceLevel)
        ExternalInterface.addCallback("setUseEchoSuppression", setUseEchoSuppression)
        ExternalInterface.addCallback("setGain", setGain)
        ExternalInterface.addCallback("publish", publish);
        ExternalInterface.addCallback("disconnect", disconnect);

        ExternalInterface.call("setSWFIsReady");
    }

    public function setMicQuality(quality:int):void {
        _micQuality = quality;
    }

    public function setMicRate(rate:int):void {
        _micRate = rate;
    }

    // Sets the minimum input level that should be considered sound and (optionally) the amount of silent time signifying that silence has actually begun.
    //  To prevent the microphone from detecting sound at all, pass a value of 100 for silenceLevel; the activity event is never dispatched.
    //  To determine the amount of sound the microphone is currently detecting, use Microphone.activityLevel.
    public function setSilenceLevel(silenceLevel:Number, timeout:int = -1):void {
        _micSilenceLevel = silenceLevel;
    }

    public function setUseEchoSuppression(useEchoSuppression:Boolean):void {
        _micUseEchoSuppression = useEchoSuppression;
    }

    public function setGain(gain:Number):void {
        _micGain = gain;
    }

    public function publish(url:String, name:String):void {
        this.connect(url, name, function (name:String):void {
            publishStream(name);
        });
    }

    public function disconnect():void {
        nc.close();
    }

    private function connect(url:String, name:String, callback:Function):void {
        nc = new NetConnection();
        nc.addEventListener(NetStatusEvent.NET_STATUS, function (event:NetStatusEvent):void {
            ExternalInterface.call("console.log", "try to connect to " + url + "/" + name);
            ExternalInterface.call("console.log", event.info.code);
            if (event.info.code == "NetConnection.Connect.Success") {
                callback(name);
            }
        });
        nc.connect(url);
    }

    private function publishStream(name:String):void {
		mic = Microphone.getMicrophone();

		mic.encodeQuality = _micQuality;
		mic.rate = _micRate;
        mic.setUseEchoSuppression(_micUseEchoSuppression);
        mic.setSilenceLevel(_micSilenceLevel, _micSilenceTimeout);
        mic.gain = _micGain;

		ns = new NetStream(nc);
		ns.attachAudio(mic);
		ns.publish(name, "live");
	}
}
}
