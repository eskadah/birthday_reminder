class BRBirthdayDetailViewController  < BRCoreViewController
   attr_accessor :birthday
  def initWithCoder(aDecoder)

    a = super
    if a
     #@birthday =  BRDBirthday.new
    end

    return a

  end

  def viewDidLoad
    super

    @photo_view = view.viewWithTag 1
    @birthday_label = view.viewWithTag 2
    @notes_title_label = view.viewWithTag 3
    @notes_text_label =  view.viewWithTag 4
    @remaining_days_image_view = view.viewWithTag 5
    @remaining_days_label = view.viewWithTag 6
    @remaining_days_subtext_label = view.viewWithTag 7
    @scroll_view = view.viewWithTag 13

    @facebook_button = view.viewWithTag 8
    @facebook_button.addTarget(self,action:'facebookButtonTapped:',forControlEvents:UIControlEventTouchUpInside)

    @call_button = view.viewWithTag 9
    @call_button.addTarget(self,action:'callButtonTapped:',forControlEvents:UIControlEventTouchUpInside)

    @sms_button = view.viewWithTag 10
    @sms_button.addTarget(self,action:'smsButtonTapped:',forControlEvents:UIControlEventTouchUpInside)

    @email_button = view.viewWithTag 11
    @email_button.addTarget(self,action:'emailButtonTapped:',forControlEvents:UIControlEventTouchUpInside)

    @delete_button = view.viewWithTag 12
    @delete_button.addTarget(self,action:'deleteButtonTapped:',forControlEvents:UIControlEventTouchUpInside)


    BRStyleSheet.styleRoundCorneredView(@photo_view)
    BRStyleSheet.styleLabel(@birthday_label,withType:'BRLabelTypeLarge')
    BRStyleSheet.styleLabel(@notes_title_label,withType:'BRLabelTypeLarge')
    BRStyleSheet.styleLabel(@notes_text_label,withType:'BRLabelTypeLarge')
    BRStyleSheet.styleLabel(@remaining_days_label,withType:'BRLabelTypeDaysUntilBirthday')
    BRStyleSheet.styleLabel(@remaining_days_subtext_label,withType:'BRLabelTypeDaysUntilBirthdaySubText')


  end

  def viewWillAppear(animated)

    super

    #puts 'viewWillAppear'
    #name = @birthday['name']
    self.title = birthday.name
    image = UIImage.imageWithData(birthday.imageData)
    @photo_view.image = UIImage.imageNamed "icon-birthday-cake.png"
    @photo_view.image = image if image

    days = birthday.remainingDaysUntilNextBirthday

    if days == 0
      @remaining_days_label.text = @remaining_days_subtext_label.text = ''
      @remaining_days_image_view.image = UIImage.imageNamed 'icon-birthday-cake.png'
    else
      @remaining_days_label.text = "#{days}"
      @remaining_days_subtext_label.text = days == 1 ? 'more day' : 'more days'
      @remaining_days_image_view.image = UIImage.imageNamed 'icon-days-remaining.png'
    end

    @birthday_label.text = birthday.birthdayTextToDisplay

    notes = (birthday.notes && birthday.notes.length > 0) ? birthday.notes : ""
    cY = @notes_text_label.frame.origin.y
    #notesLabelSize = notes.sizeWithFont(@notes_text_label.font, constrainedToSize: [300.0,300.0], lineBreakMode: NSLineBreakByWordWrapping)
    #frame = @notes_text_label.frame
    #frame.size.height = notesLabelSize.height
    #@notes_text_label.frame = frame
    @notes_text_label.text = notes
    @notes_text_label.sizeToFit
    frame = @notes_text_label.frame
    cY += frame.size.height
    cY += 10.0
    buttonGap = 6.0
    cY += buttonGap * 2
    buttonsToShow = [@facebook_button,@sms_button,@call_button,@email_button,@delete_button]

    buttonsToHide = []
    if birthday.facebookID == nil
      buttonsToShow.delete(@facebook_button)
      buttonsToHide.push(@facebook_button)
    end
    if callLink == nil
      buttonsToShow.delete(@call_button)
      buttonsToHide.push(@call_button)
    end
    if smsLink == nil
      buttonsToShow.delete(@sms_button)
      buttonsToHide.push(@sms_button)
    end
    if emailLink == nil
      buttonsToShow.delete(@email_button)
      buttonsToHide.push(@email_button)
    end

    for button in buttonsToHide do
      button.hidden = true
    end

    for button in buttonsToShow do
      button.hidden = false
      frame = button.frame
      frame.origin.y = cY
      button.frame = frame
      cY += button.frame.size.height + buttonGap

    end

     @scroll_view.contentSize = [320,cY]



  end

   def callButtonTapped
     link = callLink
     UIApplication.sharedApplication.openURL(NSURL.URLWithString(link))
   end

   def smsButtonTapped
     link = smsLink
     UIApplication.sharedApplication.openURL(NSURL.URLWithString(link))
   end

   def emailButtonTapped
     link = emailLink
     UIApplication.sharedApplication.openURL(NSURL.URLWithString(link))
   end

   def deleteButtonTapped(sender)
     actionSheet = UIActionSheet.alloc.initWithTitle(nil, delegate: self, cancelButtonTitle: 'Cancel', destructiveButtonTitle: "Delete #{birthday.name}", otherButtonTitles: nil)
     actionSheet.showInView view
   end

   def facebookButtonTapped(sender)
     #BRDModel.sharedInstance.authenticateWithFacebook
     BRDModel.sharedInstance.postToFacebookWall('nil',withFacebookID:self.birthday.facebookID)
   end

   def actionSheet(actionSheet,willDismissWithButtonIndex:buttonIndex)
     return if buttonIndex == actionSheet.cancelButtonIndex
     context = BRDModel.sharedInstance.managedObjectContext
     context.deleteObject(self.birthday)
     BRDModel.sharedInstance.saveChanges
     navigationController.popViewControllerAnimated(true)
   end


  def prepareForSegue(segue,sender:sender)

      identifier =segue.identifier
      if identifier == 'EditBirthday'

        navigation_controller = segue.destinationViewController
        birthdayEditViewController = navigation_controller.topViewController
        birthdayEditViewController.birthday = birthday

      elsif identifier == 'EditNotes'

        navigationController = segue.destinationViewController
        birthdayNotesEditViewController =navigationController.topViewController
        birthdayNotesEditViewController.birthday = birthday

      end

  end

  def telephoneNumber
    addressBook = ABAddressBookCreateWithOptions(nil,nil)
    record = ABAddressBookGetPersonWithRecordID(addressBook,birthday.addressBookID)
    multi = ABRecordCopyValue(record,KABPersonPhoneProperty)

    if ABMultiValueGetCount(multi) > 0
      telephone = ABMultiValueCopyValueAtIndex(multi,0)
      tel = telephone.gsub(' ','')
      puts telephone

    end
    tel
  end

  def callLink
    if !birthday.addressBookID || birthday.addressBookID == 0
      return nil
    end
    telnumber = telephoneNumber
    return nil unless telnumber
    callLink = "tel:#{telnumber}"
    if UIApplication.sharedApplication.canOpenURL(NSURL.URLWithString callLink)
      return callLink
    else
      return nil
    end
  end

   def smsLink
     if !birthday.addressBookID || birthday.addressBookID == 0
       return nil
     end
     telnumber = telephoneNumber
     return nil unless telnumber
     smsLink = "sms:#{telnumber}"
     if UIApplication.sharedApplication.canOpenURL(NSURL.URLWithString smsLink)
       return callLink
     else
       return nil
     end
   end

   def emailLink
     addressBook = ABAddressBookCreateWithOptions(nil,nil)
     record = ABAddressBookGetPersonWithRecordID(addressBook,(birthday.addressBookID || 0))
     multi = ABRecordCopyValue(record,KABPersonEmailProperty)

     if ABMultiValueGetCount(multi) > 0
       email = ABMultiValueCopyValueAtIndex(multi,0)
       em = email.gsub(' ','')
       puts em
     end
     if em
       emailLink = "mailto:#{em}"
       emailLink += '?subject=Happy%20Birthday'
       puts" this is emailLink :#{emailLink}"
       puts  UIApplication.sharedApplication.canOpenURL(NSURL.URLWithString 'mailto:eskadah@yahoo.com')
       if UIApplication.sharedApplication.canOpenURL(NSURL.URLWithString(emailLink))
         return emailLink
       end

     end
     return nil
   end

end