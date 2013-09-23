class BRBirthdayEditViewController < BRCoreViewController
attr_accessor :birthday

SIDE = 71.0


  def viewWillAppear(animated)
    super

    @name_text_field.text = @birthday.name
    #@date_picker.date = @birthday.birthdate
    components = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:@date_picker.date)
    components.day = @birthday.birthDay if @birthday.birthDay > 0
    components.month = @birthday.birthMonth if @birthday.birthMonth > 0
    if @birthday.birthYear > 0
        components.year = @birthday.birthYear
        @include_year_switch.on = true
    else
       @include_year_switch.on = false
    end
    @birthday.updateNextBirthdayAndAge
    @date_picker.date = NSCalendar.currentCalendar.dateFromComponents components
    @photo_view.image = UIImage.imageNamed "icon-birthday-cake.png"
    @photo_view.image = UIImage.imageWithData(@birthday.imageData) if @birthday.imageData
    updateSaveButton
  end

  def viewDidLoad

    super

    left = self.navigationItem.leftBarButtonItem
    left.target = self
    left.action = :cancelAndDismiss

    @save_button =  self.navigationItem.rightBarButtonItem
    @save_button.target = self
    @save_button.action = :saveAndDismiss

    #date_picker =  self.view.subviews.grep(UIDatePicker).first
    #text_field =   self.view.subviews.grep(UITextField).first

    @date_picker = view.viewWithTag 2
    @name_text_field = view.viewWithTag 1
    @include_year_label = view.viewWithTag 3
    @include_year_switch = view.viewWithTag 4
    @photo_container_view = view.viewWithTag 5
    @photo_view = view.viewWithTag 7
    @pic_photo_label = view.viewWithTag 8
    @gesture_recognizer = @photo_container_view.gestureRecognizers[0]
    @name_text_field.delegate = self



    @name_text_field.addTarget(self, action:'didChangeNameText', forControlEvents:UIControlEventEditingChanged)
    @include_year_switch.addTarget(self, action:'didToggleSwitch', forControlEvents:UIControlEventValueChanged)
    @date_picker.addTarget(self, action:'didChangeDatePicker', forControlEvents:UIControlEventValueChanged)
    @gesture_recognizer.addTarget(self,action:"didTapPhoto")

    BRStyleSheet.styleLabel(@include_year_label,withType:'BRLabelTypeLarge')
    BRStyleSheet.styleRoundCorneredView @photo_container_view

  end

  def textFieldShouldReturn(sender)

    @name_text_field.resignFirstResponder
    false

  end


  def didChangeNameText
     #puts @name_text_field.text
     #self.birthday['name']=@name_text_field.text
     @birthday.name =  @name_text_field.text
     updateSaveButton
  end

  def updateSaveButton
     @save_button.enabled = false unless @name_text_field.text
     @save_button.enabled = @name_text_field.text.length>0  if @name_text_field.text
  end

  def didToggleSwitch
   updateBirthdayDetails
  end

  def didChangeDatePicker
    #puts @date_picker.date
    #elf.birthday["birthdate"]= @date_picker.date
    updateBirthdayDetails
  end

  def didTapPhoto
   puts "photo was tapped"
   unless UIImagePickerController.isSourceTypeAvailable UIImagePickerControllerSourceTypeCamera
       puts "No camera detected!"
       pickPhoto
       return
   end
   actionSheet = UIActionSheet.alloc.initWithTitle(nil,delegate:self,cancelButtonTitle:"Cancel",destructiveButtonTitle:nil,otherButtonTitles:'Take a Photo','Pick from Photo Library', nil)
   actionSheet.showInView self.view
  end

  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)

    return if buttonIndex == actionSheet.cancelButtonIndex

     case buttonIndex
       when 0 then takePhoto
       when 1 then pickPhoto
     end

  end

   def imagePicker
         @imagePicker ||= UIImagePickerController.alloc.init
         @imagePicker.delegate = self if @imagePicker
         return @imagePicker
   end

  def takePhoto
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera
        self.navigationController.presentViewController(@imagePicker,animated:true,completion:nil)
  end

  def pickPhoto
      imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary
      self.navigationController.presentViewController(@imagePicker,animated:true,completion:nil)
  end

  def imagePickerController(picker,didFinishPickingMediaWithInfo:info)
    picker.dismissViewControllerAnimated(true, completion:nil)
    #picker.dismissModalViewControllerAnimated(true)
    image = info[UIImagePickerControllerOriginalImage]
    @photo_view.image = image
     side = SIDE
     side *= UIScreen.mainScreen.scale
     thumbnail = image.createThumbnailToFillSize((CGSizeMake(side,side)))
    @photo_view.image = thumbnail
    @birthday.imageData =UIImageJPEGRepresentation(thumbnail,1.0)
  end

  def updateBirthdayDetails
      calendar = NSCalendar.currentCalendar
      components = calendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:@date_picker.date)
      @birthday.birthMonth =  components.month
      @birthday.birthDay = components.day
      @birthday.birthYear = 0
      @birthday.birthYear = components.year if @include_year_switch.on?
      @birthday.updateNextBirthdayAndAge

  end

  def saveAndDismiss
   BRDModel.sharedInstance.saveChanges
   super
  end

  def cancelAndDismiss
    BRDModel.sharedInstance.cancelChanges
    super
  end
=begin
  def self.respondToNotification

    p 'i responded'

  end
=end
  #NSNotificationCenter.defaultCenter.addObserver(self, selector: 'respondToNotification', name: UIKeyboardWillShowNotification, object: nil)

end

class UIImage

  def createThumbnailToFillSize(size)
    mainImageSize = self.size
    repositionedImageSize = mainImageSize
    width_scaler = size.width/mainImageSize.width
    length_scaler = size.height/mainImageSize.height

    if width_scaler > length_scaler
      scaler = width_scaler; #repositionedImageSize.height = (size.height/scaler)
    else
      scaler = length_scaler; #repositionedImageSize.width = (size.width/scaler)
    end



    new_x = (( repositionedImageSize.width - mainImageSize.width)/2.0) * scaler
    new_y = (( repositionedImageSize.height - mainImageSize.height)/2.0) * scaler
    UIGraphicsBeginImageContext(size)
    self.drawInRect(CGRectMake(new_x,new_y,mainImageSize.width*scaler,mainImageSize.height*scaler))

    thumb = UIGraphicsGetImageFromCurrentImageContext()

    UIGraphicsEndImageContext()

    return thumb

  end


end