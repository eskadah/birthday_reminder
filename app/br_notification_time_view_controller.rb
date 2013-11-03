class BRNotificationTimeViewController   < BRCoreViewController


  def viewDidLoad
    super

    @whatTimeLabel = view.viewWithTag 1
    @timePicker = view.viewWithTag 2

    @timePicker.addTarget(self, action:'didChangeTime', forControlEvents:UIControlEventValueChanged)

    BRStyleSheet.styleLabel(@whatTimeLabel,withType: 'BRLabelTypeLarge')



  end

  def viewWillAppear(animated)
    super
    hour = BRDSettings.sharedInstance.notificationHour
    minute = BRDSettings.sharedInstance.notificationMinute

    components = NSCalendar.currentCalendar.components(NSHourCalendarUnit|NSMinuteCalendarUnit, fromDate: NSDate.date)
    components.hour = hour
    components.minute = minute
    @timePicker.date = NSCalendar.currentCalendar.dateFromComponents(components)

  end




  def didChangeTime
    components = NSCalendar.currentCalendar.components(NSHourCalendarUnit|NSMinuteCalendarUnit,fromDate:@timePicker.date)
    BRDSettings.sharedInstance.notificationHour = components.hour
    BRDSettings.sharedInstance.notificationMinute = components.minute

  end

end