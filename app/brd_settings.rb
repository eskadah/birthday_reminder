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

  def reminderDateForNextBirthday(nextBirthday)
    secondsInOneDay = 3600*24.0
    case self.daysBefore
      when 0 then timeInterval = 0.0
      when 1 then timeInterval = secondsInOneDay
      when 2 then timeInterval = secondsInOneDay*2
      when 3 then timeInterval = secondsInOneDay*3
      when 4 then timeInterval = secondsInOneDay*5
      when 5 then timeInterval = secondsInOneDay*7
      when 6 then timeInterval = secondsInOneDay*14
      when 7 then timeInterval = secondsInOneDay*21
    end

    reminderDate = nextBirthday.dateByAddingTimeInterval -timeInterval
    components = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit, fromDate: reminderDate)
    components.hour = self.notificationHour
    components.minute = self.notificationMinute
    NSCalendar.currentCalendar.dateFromComponents components
  end

  def reminderTextForNextBirthday(birthday)

    if birthday.nextBirthdayAge > 0
      if self.daysBefore == 0
        text = "#{birthday.name} is #{birthday.nextBirthdayAge}"
      else
        text =  "#{birthday.name} will be #{birthday.nextBirthdayAge}"
      end
    else
       text = "It's #{birthday.name}'s Birthday"
    end
    case self.daysBefore
      when 0
        text + 'today'
      when 1
        text +'tomorrow'
      when 2
        text +'in 2 days'
      when 3
        text + 'in 3 days'
      when 4
        text + 'in 5 days'
      when 5
        text + 'in 1 week'
      when 6
        text + 'in 2 weeks'
      when 7
         text + 'in 3 weeks'
      else
        ''
    end
  end

end