class BRDBirthday < NSManagedObject

  #attr_reader :remainingDaysUntilNextBirthday,
               #:birthdayTextToDisplay,
               #:isBirthdayToday


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
    dateComponents = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:now)
    self.birthday = dateComponents.day
    self.birthMonth = dateComponents.month
    self.birthYear = 0

    updateNextBirthdayAndAge
  end

  def remainingDaysUntilNextBirthday
    now = NSDate.date
    calendar = NSCalendar.currentCalendar
    componentsToday = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:now)
    today = calendar.dateFromComponents componentsToday
    timeDiffSecs = self.nextBirthday.timeIntervalSinceDate
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

  def self.entity
     @entity ||=
    begin
      entity = NSEntityDescription.new
      entity.name = 'BirthdayReminder'
      entity.managedObjectClassName = 'BRDBirthday'

      entity.properties =
          ['addressBookID', NSInteger16AttributeType,
           'birthDay', NSInteger16AttributeType,
           'birthMonth', NSInteger16AttributeType,
           'birthYear',NSInteger16AttributeType,
           'facebookID',NSStringAttributeType,
           'imageData', NSBinaryDataAttributeType,
           'name',NSStringAttributeType,
            'nextBirthday',NSDateAttributeType,
            'nextBirthdayAge',NSInteger16AttributeType,
            'notes',NSStringAttributeType,
            'picURL',NSStringAttributeType,
            'uid',NSStringAttributeType
          ].each_slice(2).map do |name, type|
            property = NSAttributeDescription.alloc.init
            property.name = name
            property.attributeType = type
            property.optional = true
            property
          end

      @entity = entity
    end

    @entity
  end

end