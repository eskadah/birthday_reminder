#=begin
class BRStyleSheet
#=begin

   @@kFontLightOnDarkTextColour = UIColor.colorWithRed(255.0/255.0, green:251.0/255.0, blue:218.0/255.0, alpha:1.0)
   @@kFontDarkOnLightTextColour = UIColor.colorWithRed(1.0/255.0, green:1.0/255.0, blue:1.0/255.0, alpha:1.0)

   @@kFontNavigationTextColour = UIColor.colorWithRed(106.0/255.0, green:62.0/255.0, blue:39.0/255.0, alpha:1.0)
   @@kFontNavigationDisabledTextColour = UIColor.colorWithRed(106.0/255.0, green:62.0/255.0, blue:39.0/255.0, alpha:0.6)
   @@kNavigationButtonBackgroundColour=UIColor.colorWithRed(255.0/255.0, green:245.0/255.0, blue:225.0/255.0, alpha:1.0)
   @@kToolbarButtonBackgroundColour = UIColor.colorWithRed(39.0/255.0, green:17.0/255.0, blue:5.0/255.0, alpha:1.0)
   @@kLargeButtonTextColour = UIColor.whiteColor
#=end
 def self.fonts
    @@kFontNavigation = UIFont.systemFontOfSize(18)

#=begin
   @@kFontName = UIFont.fontWithName("HelveticaNeue-Bold", size:15.0)
   @@kFontBirthdayDate = UIFont.fontWithName("HelveticaNeue", size:13.0)
   @@kFontDaysUntilBirthday = UIFont.fontWithName("HelveticaNeue-Bold", size:25.0)
   @@kFontDaysUntilBirthdaySubText = UIFont.fontWithName("HelveticaNeue", size:9.0)
   @@kFontLarge = UIFont.fontWithName("HelveticaNeue-Bold", size:17.0)
   @@kFontButton = UIFont.fontWithName("HelveticaNeue-Bold", size:30.0)
   @@kFontNotes = UIFont.fontWithName("HelveticaNeue", size:16.0)
   @@kFontPicPhoto = UIFont.fontWithName("HelveticaNeue-Bold", size:12.0)
   @@kFontDropShadowColour = UIColor.colorWithRed(1.0/255.0, green:1.0/255.0, blue:1.0/255.0, alpha:0.75)
#=end
end
   def self.styleLabel(label, withType:labelType)
     fonts
     case labelType
       when 'BRLabelTypeName'
         label.font = @@kFontName
         label.layer.shadowColor = @@kFontDropShadowColour.CGColor
         label.layer.shadowOffset = CGSizeMake(1, 1)
         label.layer.shadowRadius = 0
         label.layer.masksToBounds = false
         label.textColor = @@kFontLightOnDarkTextColour
       when 'BRLabelTypeBirthdayDate'
         label.font = @@kFontBirthdayDate
         label.textColor = @@kFontLightOnDarkTextColour
       when 'BRLabelTypeDaysUntilBirthday'
         label.font = @@kFontDaysUntilBirthday
         label.textColor = @@kFontDarkOnLightTextColour
       when 'BRLabelTypeDaysUntilBirthdaySubText'
         label.font = @@kFontDaysUntilBirthdaySubText
         label.textColor = @@kFontDarkOnLightTextColour
       when 'BRLabelTypeLarge'
        label.textColor = @@kFontLightOnDarkTextColour
        label.layer.shadowColor = @@kFontDropShadowColour.CGColor
        label.layer.shadowOffset = CGSizeMake(1, 1)
        label.layer.shadowRadius = 0
        label.layer.masksToBounds = false
       else
         label.textColor = @@kFontLightOnDarkTextColour
     end

   end
#=end
  def self.styleRoundCorneredView(view)
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        view.clipsToBounds = true
  end

  def self.initStyles
    fonts
    titleTextAttributes = NSDictionary.dictionaryWithObjectsAndKeys(@@kFontNavigationTextColour,UITextAttributeTextColor,UIColor.whiteColor,UITextAttributeTextShadowColor,NSValue.valueWithUIOffset(UIOffsetMake(0,2)),UITextAttributeTextShadowOffset,@@kFontNavigation,UITextAttributeFont,nil)

    UINavigationBar.appearance.setTitleTextAttributes(titleTextAttributes)

    UINavigationBar.appearance.setBackgroundImage(UIImage.imageNamed("navigation-bar-background.png"), forBarMetrics: UIBarMetricsDefault)

    UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar,nil).setTintColor(@@kNavigationButtonBackgroundColour)
    barButtonItemTextAttributes = NSDictionary.dictionaryWithObjectsAndKeys(@@kFontNavigationTextColour,UITextAttributeTextColor,UIColor.whiteColor,

           UITextAttributeTextShadowColor,NSValue.valueWithUIOffset(UIOffsetMake(0,1)), UITextAttributeTextShadowOffset,nil



           )

    UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar,nil).setTitleTextAttributes(barButtonItemTextAttributes, forState: UIControlStateNormal )
    disabledBarButtonItemTextAttributes = NSDictionary.dictionaryWithObjectsAndKeys(@@kFontNavigationDisabledTextColour,UITextAttributeTextColor,UIColor.whiteColor,UITextAttributeTextShadowColor,NSValue.valueWithUIOffset(UIOffsetMake(0,1)),UITextAttributeTextShadowOffset,nil)
    UIBarButtonItem.appearanceWhenContainedIn(UINavigationBar,nil).setTitleTextAttributes(disabledBarButtonItemTextAttributes, forState: UIControlStateDisabled)
    UIToolbar.appearance.setBackgroundImage(UIImage.imageNamed("tool-bar-background.png"), forToolbarPosition: UIToolbarPositionAny, barMetrics: UIBarMetricsDefault)
    UIBarButtonItem.appearanceWhenContainedIn(UIToolbar,nil).setTintColor @@kToolbarButtonBackgroundColour
    barButtonItemTextAttributes = {UITextAttributeTextColor:UIColor.whiteColor}
    UIBarButtonItem.appearanceWhenContainedIn(UIToolbar,nil).setTitleTextAttributes(barButtonItemTextAttributes, forState: UIControlStateNormal)


    #Buttons

    BRBlueButton.appearance.setBackgroundImage(UIImage.imageNamed("button-blue.png"), forState: UIControlStateNormal)
    BRBlueButton.appearance.setTitleColor(@@kLargeButtonTextColour, forState: UIControlStateNormal)
    BRBlueButton.appearance.font = @@kFontLarge

    BRRedButton.appearance.setBackgroundImage(UIImage.imageNamed("button-red.png"), forState: UIControlStateNormal)
    BRRedButton.appearance.setTitleColor(@@kLargeButtonTextColour, forState: UIControlStateNormal)
    BRRedButton.appearance.font = @@kFontLarge

    #Table View

    UITableView.appearance.setBackgroundColor(UIColor.clearColor)
    UITableViewCell.appearance.selectionStyle = UITableViewCellSelectionStyleNone
    UITableView.appearance.separatorStyle = UITableViewCellSeparatorStyleNone


  end

 # p NSHomeDirectory()

  def self.styleTextView(textView)
    textView.backgroundColor = UIColor.clearColor
    textView.font = @@kFontNotes
    textView.textColor = @@kFontLightOnDarkTextColour
    textView.layer.shadowColor = @@kFontDropShadowColour.CGColor
    textView.layer.shadowOffset =[1.0,1.0]
    textView.layer.shadowRadius = 0.0
    textView.layer.masksToBounds = false

  end


end
#=end