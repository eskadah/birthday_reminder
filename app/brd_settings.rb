class BRDSettings
  attr_accessor :notificationHour,:notificationMinute,:daysBefore

  def notificationHour
    hour = userDefaults['notificationHour'] || 9
  end

  def notificationHour=(hr)
    userDefaults['notificationHour'] = hr
    userDefaults.synchronize
  end

  def notificationMinute
    hour = userDefaults['notificationMinute'] || 0
  end

  def notificationMinute=(min)
    userDefaults['notificationMinute'] = min
    userDefaults.synchronize
  end

  def daysBefore
    days = userDefaults['daysBefore'] || 0
  end

  def daysBefore=(days)
    userDefaults['daysBefore'] = days
    userDefaults.synchronize
  end

  def self.sharedInstance
      @sharedInstance ||= BRDSettings.alloc.init
  end

  def titleForNotificationTime
     hour = BRDSettings.sharedInstance.notificationHour
     minute = BRDSettings.sharedInstance.notificationMinute
     components = NSCalendar.currentCalendar.components(NSHourCalendarUnit|NSMinuteCalendarUnit, fromDate: NSDate.date)
     components.hour = hour
     components.minute = minute
     date = NSCalendar.currentCalendar.dateFromComponents components
    dateFormatter ||= NSDateFormatter.alloc.init
    dateFormatter.setDateFormat('h:mm a')
    dateFormatter.stringFromDate date

  end

  def titleForDaysBefore(daysBefore)

     case daysBefore
       when 0 then 'On Birthday'
       when 1 then '1 Day Before'
       when 2 then '2 Days Before'
       when 3 then '3 Days Before'
       when 4 then '5 Days Before'
       when 5 then '1 week Before'
       when 6 then '2 weeks Before'
       when 7 then '3 weeks Before'
       else
         return ''
     end

  end

  def userDefaults
    userDefaults = NSUserDefaults.standardUserDefaults
  end

end