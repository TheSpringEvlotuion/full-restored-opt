package hxcodec;

#if (hxCodec >= "2.6.1")
import hxcodec.VideoHandler as VideoHandlerOG;
#elseif (hxCodec == "2.6.0")
import VideoHandler as VideoHandlerOG;
#end

class VideoHandler extends VideoHandlerOG
{
	public var isDisposed:Bool = false;

  override function dispose()
	{
		isDisposed = true;
		super.dispose();
	}

	public function finishVideo()
		onVLCEndReached();
}
