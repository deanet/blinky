require File.join(File.dirname(__FILE__), '/spec_helper')

module Blinky 
  describe "Blinky" do
    
    describe "that has a supported device connected" do
  
      before(:each) do
        @supported_device = OpenStruct.new(:idVendor => 0x1000, :idProduct => 0x1111)       
        self.connected_devices = [
          OpenStruct.new(:idVendor => 0x1234, :idProduct => 0x5678),
          @supported_device,
          OpenStruct.new(:idVendor => 0x5678, :idProduct => 0x1234)     
          ]
        @blinky = Blinky.new("#{File.dirname(__FILE__)}/fixtures")
      end

      it "can call recipe methods on the device" do
        @supported_device.should_receive(:indicate_success)
        @blinky.success!                  
      end
      
    end
              
    describe "that has no supported devices connected" do

      before(:each) do
        @devices = [
          OpenStruct.new(:idVendor => 0x1234, :idProduct => 0x5678),
          OpenStruct.new(:idVendor => 0x5678, :idProduct => 0x1234)     
          ]
          self.connected_devices= @devices
      end
      
      it "will complain" do
        exception = Exception.new("foo")
        NoSupportedDevicesFound.should_receive(:new).with(@devices).and_return(exception)
        lambda{Blinky.new("#{File.dirname(__FILE__)}/fixtures")}.should raise_error("foo")                
      end
      
     end
 
     describe "that has no supported devices connected - but does have one from the same vendor" do

       before(:each) do
         @devices = [
           OpenStruct.new(:idVendor => 0x1000, :idProduct => 0x5678),
           OpenStruct.new(:idVendor => 0x5678, :idProduct => 0x1234)     
           ]
           self.connected_devices= @devices
       end

       it "will complain" do
         exception = Exception.new("foo")
         NoSupportedDevicesFound.should_receive(:new).with(@devices).and_return(exception)
         lambda{Blinky.new("#{File.dirname(__FILE__)}/fixtures")}.should raise_error("foo")                
       end

      end
      
      describe "that has two supported devices connected" do

        before(:each) do
          @supported_device_one = OpenStruct.new(:idVendor => 0x1000, :idProduct => 0x1111)  
          @supported_device_two = OpenStruct.new(:idVendor => 0x2000, :idProduct => 0x2222)      
          
          self.connected_devices = [
            OpenStruct.new(:idVendor => 0x1234, :idProduct => 0x5678),
            @supported_device_one,
            @supported_device_two    
            ]
          @blinky = Blinky.new("#{File.dirname(__FILE__)}/fixtures")
        end

        it "will choose the second device" do
          @supported_device_one.should_not_receive(:indicate_success)
          @supported_device_two.should_receive(:indicate_success)
          @blinky.success!                  
        end
      end
      
      describe "that is asked to watch a supported CI server" do

        before(:each) do      
          self.connected_devices = [OpenStruct.new(:idVendor => 0x1000, :idProduct => 0x1111)]
          @blinky = Blinky.new("#{File.dirname(__FILE__)}/fixtures")
        end

        it "can receive call backs from the server" do
          @blinky.should_receive(:notify_build_status)
          @blinky.watch_mock_ci_server                  
        end

      end
 
     def connected_devices= devices
             devices.each do |device|
               device.stub!(:usb_open).and_return(device)
             end
             USB.stub!(:devices).and_return(devices)
     end
     
   end   
end