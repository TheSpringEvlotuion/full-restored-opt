package hxcodec;

#if (hxCodec >= "2.6.1")
import hxcodec.VideoHandler;
#elseif (hxCodec == "2.6.0")
import VideoHandler;
#end

class VideoHandler extends VideoHandler
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
