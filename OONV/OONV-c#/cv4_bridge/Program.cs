class RemoteControl
{
    private Device device;
    
    public RemoteControl(Device device) {
        this.device = device;
    }
    
    public void togglePower() {
        if (device.isEnabled()) {
            device.disable();
        } else {
            device.enable();
        }
    }
    
    public void volumeUp(int percent) { 
        device.setVolume(device.getVolume() + percent);
    }
    
    public void volumeDown(int percent) {
        device.setVolume(device.getVolume() - percent);
    }
    
    public void channelUp() {
        device.setChannel(device.getChannel() + 1);
    }
    
    public void channelDown() {
        device.setChannel(device.getChannel() - 1);
    }
}

interface Device {
    bool isEnabled();
    void enable();
    void disable();
    int getVolume();
    void setVolume(int percent);
    int getChannel();
    void setChannel(int channel);
}

class AdvancedRemoteControl : RemoteControl {   
    private Device device;
    public AdvancedRemoteControl(Device device) : base(device) {
        this.device = device;
    }
    
    public void mute() {
        device.setVolume(0);
    }
}

class TV : Device {
    private bool enabled;
    private int volume;
    private int channel;
    private static List<string> tv_channels = new List<string> {"CT1", "CT2", "CT3", "CT4", "Nova", "Prima", "Ocko"};
    
    public TV() {
        this.enabled = false;
        this.volume = 0;
        this.channel = 0;
    }
    
    public bool isEnabled() {
        return this.enabled;
    }
    
    public void enable() {
        this.enabled = true;
    }
    
    public void disable() {
        this.enabled = false;
    }
    
    public int getVolume() {
        return this.volume;
    }
    
    public void setVolume(int percent) {
        this.volume = percent;
    }
    
    public int getChannel() {
        return this.channel;
    }
    
    public void setChannel(int channel) {
        this.channel = channel;
        Console.WriteLine("Právě koukáte na " + tv_channels[this.channel]);
    }
}

class Radio : Device {
    private bool enabled;
    private int volume;
    private int channel;
    private static List<string> radio_channels = new List<string> {"Evropa2", "Frekvence1", "Impuls", "FajnRadio", "Radiozurnal", "Radio1", "Radiozurnal"};
    
    public Radio() {
        this.enabled = false;
        this.volume = 0;
        this.channel = 0;
    }
    
    public bool isEnabled() {
        return this.enabled;
    }
    
    public void enable() {
        this.enabled = true;
    }
    
    public void disable() {
        this.enabled = false;
    }
    
    public int getVolume() {
        return this.volume;
    }
    
    public void setVolume(int percent) {
        this.volume = percent;
    }
    
    public int getChannel() {
        return this.channel;
    }
    
    public void setChannel(int channel) {
        this.channel = channel;
        Console.WriteLine("Právě posloucháte " + radio_channels[this.channel]);
    }
}


static class Program {
    public static void Main()
    {
        TV tv = new TV();
        RemoteControl tvRemote = new RemoteControl(tv);
        
        tvRemote.togglePower();
        tvRemote.volumeUp(10);
        tvRemote.channelUp();
        
        Console.WriteLine(tv.isEnabled());
        Console.WriteLine(tv.getVolume());
        Console.WriteLine(tv.getChannel());
        
        Radio radio = new Radio();
        AdvancedRemoteControl radioRemote = new AdvancedRemoteControl(radio);
        
        radioRemote.togglePower();
        radioRemote.volumeUp(10);
        radioRemote.channelUp();
        
        Console.WriteLine(radio.isEnabled());
        Console.WriteLine(radio.getVolume());
        Console.WriteLine(radio.getChannel());
        
        radioRemote.mute();
        Console.WriteLine(radio.getVolume());
    }
}