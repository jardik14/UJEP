class VideoFile
{
    public string FileName { get; set; }
    public string CodecType { get; set; }
}

class AudioMixers
{
    public void MixAudio()
    {
        Console.WriteLine("Mixing audio");
    }
}


class BitrateReader
{
    public static VideoFile Read(VideoFile file, string codec)
    {
        Console.WriteLine("Reading file...");
        return file;
    }

    public static VideoFile Convert(VideoFile buffer, string codec)
    {
        Console.WriteLine("Converting file...");
        return buffer;
    }
}

class CodecFactory
{
    public static VideoFile Extract(VideoFile file)
    {
        Console.WriteLine("Extracting file...");
        return file;
    }
}

class OggCompressionCodec
{
    public void Compress(VideoFile buffer)
    {
        Console.WriteLine("Compressing file...");
    }
}

class MPEG4CompressionCodec
{
    public void Compress(VideoFile buffer)
    {
        Console.WriteLine("Compressing file...");
    }
}

class VideoConverter
{
    public VideoFile Convert(string filename, string format)
    {
        VideoFile file = new VideoFile { FileName = filename };
        VideoFile buffer = BitrateReader.Read(file, file.CodecType);
        VideoFile intermediateResult;
        if (format == "mp4")
        {
            MPEG4CompressionCodec codec = new MPEG4CompressionCodec();
            intermediateResult = BitrateReader.Convert(buffer, codec.ToString());
        }
        else
        {
            OggCompressionCodec codec = new OggCompressionCodec();
            intermediateResult = BitrateReader.Convert(buffer, codec.ToString());
        }
        return CodecFactory.Extract(intermediateResult);
    }
}

class Program
{
    static void Main()
    {
        VideoConverter converter = new VideoConverter();
        converter.Convert("video", "mp4");
    }
}