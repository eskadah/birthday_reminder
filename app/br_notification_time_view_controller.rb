class BRNotificationTimeViewController   < BRCoreViewController


  def viewDidLoad
    super

    @whatTimeLabel = view.viewWithTag 1
    @timePicker = view.viewWithTag 2

    @timePicker.addTarget(self, action:'didChangeTime', forControlEvents:UIControlEventValueChanged)

    BRStyleSheet.styleLabel(@whatTimeLabel,withType: 'BRLabelTypeLarge')



  end


  def didChangeTime
    components = NSCalendar.currentCalendar.components(NSHourCalendarUnit|NSMinuteCalendarUnit,fromDate:@timePicker.date)
    puts "#{components.hour}:#{components.minute}"

  end

end