var isReady = false;

// Global method for ActionScript
function setSWFIsReady() {
    if (!isReady) {
        console.log('swf is ready!');
        isReady = true;
    }
}

define('audio-only-rtmp-streamer', function () {
    return function AudioOnlyRtmpStreamer(elem) {

        /**
         * Embed swf element, eg. <embed src="*.swf"></embed>.
         */
        var _elem = elem;

        if (!isReady) {
            setTimeout(function () {
                return AudioOnlyRtmpStreamer(elem);
            }, 1000);
        }

        /**
         * Push video to RTMP stream from local camera.
         *
         * @param url  - The RTMP stream URL
         * @param name - The RTMP stream name
         */
        this.publish = function (url, name) {
            _elem.publish(url, name);
        };

        this.disconnect = function () {
            _elem.disconnect();
        };

        this.setMicQuality = function (quality) {
            _elem.setMicQuality(quality);
        };

        this.setMicRate = function (rate) {
            _elem.setMicRate(rate);
        }

        this.setSilenceLevel = function (silenceLevel, silenceTimeout) {
            _elem.setSilenceLevel(silenceLevel, silenceTimeout);
        }

        this.setUseEchoSuppression = function(useEchoSuppression) {
            _elem.setUseEchoSuppression(useEchoSuppression);
        }
    };
});