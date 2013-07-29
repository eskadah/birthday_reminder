class BRBirthdayEditViewController < BRCoreViewController
attr_accessor :birthday




  def viewWillAppear(animated)
    super

    @name_text_field.text = @birthday['name']
    @date_picker.date = @birthday['birthdate']
    if (image = @birthday['image'])
      @photo_view.image = image
    else
      @photo_view.image = UIImage.imageNamed "icon-birthday-cake.png"
    end
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

  end

  def textFieldShouldReturn(sender)

    @name_text_field.resignFirstResponder
    false

  end


  def didChangeNameText
     puts @name_text_field.text
     self.birthday['name']=@name_text_field.text
     updateSaveButton
  end

  def updateSaveButton
     @save_button.enabled = @name_text_field.text.length>0
  end

  def didToggleSwitch
#=begin
     if @include_year_switch.on?
       puts "sure I'll share my age with you"
     else
       puts "Nope, I will not share my age with you"
     end
#=end
  #puts  @include_year_switch.methods.sort
  end

  def didChangeDatePicker
    puts @date_picker.date
    self.birthday["birthdate"]= @date_picker.date
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
    birthday["image"]=image
  end

end