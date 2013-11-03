class BRDBirthdayImport

  attr_accessor :addressBookID,:birthDay,:birthMonth,:birthYear,:facebookID,:imageData,:name,:nextBirthday,:nextBirthdayAge,:picURL,:uid,:remainingDaysUntilNextBirthday,:birthdayTextToDisplay,:isBirthdayToday

  def initWithAddressBookRecord(addressBookRecord)
    a = init
    if a
      firstName = nil
      lastName = nil
      birthdate = nil

      recordID = ABRecordGetRecordID(addressBookRecord)
      firstName = ABRecordCopyValue(addressBookRecord,KABPersonFirstNameProperty)
      lastName = ABRecordCopyValue(addressBookRecord,KABPersonLastNameProperty)
      birthdate = ABRecordCopyValue(addressBookRecord,KABPersonBirthdayProperty)
      name = firstName.nil? ? lastName : firstName + ' ' + lastName
      a.name = name
      a.uid = "ab-#{recordID}"
      a.addressBookID = recordID
      a.birthDay = birthdate.day
      a.birthMonth = birthdate.month
      a.birthYear = birthdate.year

      updateNextBirthdayAndAge

      if nextBirthdayAge > 150
        a.birthYear = 0
        a.nextBirthdayAge = 0
      end

      if ABPersonHasImageData(addressBookRecord)
        imageData = ABPersonCopyImageData(addressBookRecord)
        fullSizeImage = UIImage.imageWithData imageData
        side = 71.0
        side *= UIScreen.mainScreen.scale
        thumbnail = fullSizeImage.createThumbnailToFillSize([side,side])
        a.imageData = UIImageJPEGRepresentation(thumbnail,1.0)

      end

    end
    a
  end

  def initWithFacebookDictionary(dict)
    a = init
    if a
      a.name = dict['name']
      a.uid = "fb-#{dict['id']}"
      a.facebookID ="#{dict['id']}"
      a.picURL ="http://graph.facebook.com/#{facebookID}/picture?type=large"
      birthDateString = dict['birthday']
      birthdaySegments = birthDateString.split('/')
      a.birthDay = birthdaySegments[1].to_i
      a.birthMonth = birthdaySegments[0].to_i
      if birthdaySegments.size > 2
        a.birthYear = birthdaySegments[2].to_i
      end
      a.updateNextBirthdayAndAge

    end
    a
  end

  def updateNextBirthdayAndAge
    now = NSDate.date
    calendar = NSCalendar.currentCalendar

    dateComponents = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:now)

    today = calendar.dateFromComponents(dateComponents)
    dateComponents.day = birthDay.intValue
    dateComponents.month = birthMonth.intValue
    birthDayThisYear = calendar.dateFromComponents(dateComponents)

    if today.compare(birthDayThisYear) == NSOrderedDescending
      dateComponents.year += 1
      self.nextBirthday = calendar.dateFromComponents(dateComponents)

    else
      self.nextBirthday = birthDayThisYear.copy
    end

    if self.birthYear.intValue > 0
      self.nextBirthdayAge = NSNumber.numberWithInt(dateComponents.year - birthYear.intValue)

    else
      self.nextBirthdayAge = 0
    end

  end

  def updateWithDefaults
    now = NSDate.date
    dateComponents = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:now)
    self.birthDay = dateComponents.day
    self.birthMonth = dateComponents.month
    self.birthYear = 0

    updateNextBirthdayAndAge
  end

  def remainingDaysUntilNextBirthday
    now = NSDate.date
    calendar = NSCalendar.currentCalendar
    componentsToday = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:now)
    today = calendar.dateFromComponents componentsToday
    timeDiffSecs = self.nextBirthday.timeIntervalSinceDate now
    days = (timeDiffSecs/(60.0*60.0*24.0)).floor

  end

  def isBirthdayToday
    remainingDaysUntilNextBirthday == 0
  end

  def birthdayTextToDisplay
    now = NSDate.date
    calendar = NSCalendar.currentCalendar
    componentsToday = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:now)
    today = calendar.dateFromComponents componentsToday
    components = calendar.components(NSMonthCalendarUnit|NSDayCalendarUnit,fromDate:today,toDate:self.nextBirthday,options:0)

    if components.month == 0
      if components.day == 0
        if self.nextBirthdayAge.intValue > 0
          return "#{self.nextBirthdayAge} Today!"
        else
          return "Today!"
        end
      end

      if components.day == 1
        if self.nextBirthdayAge.intValue > 0
          return "#{self.nextBirthdayAge} Tomorrow!"
        else
          return "Tomorrow!"
        end
      end
    end

    text = ""
    if self.nextBirthdayAge > 0
      text = "#{self.nextBirthdayAge} on"
    end

    dateFormatterPartial ||= NSDateFormatter.alloc.init.setDateFormat("MMM d")

    return  (text + " "+ dateFormatterPartial.stringFromDate(nextBirthday))


  end
end