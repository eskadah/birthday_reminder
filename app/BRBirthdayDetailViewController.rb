class BRBirthdayDetailViewController  < BRCoreViewController
   attr_accessor :birthday
  def initWithCoder(aDecoder)

    a = super
    if a
     @birthday = {}
    end

    return a

  end

  def viewDidLoad
    super

    @photo_view = view.viewWithTag 1

  end

  def viewWillAppear(animated)

    super

    puts 'viewWillAppear'
    name = @birthday['name']
    self.title = name
    image = @birthday['image']
    @photo_view.image = UIImage.imageNamed "icon-birthday-cake.png"
    @photo_view.image = image if image

  end

  def prepareForSegue(segue,sender:sender)

      identifier =segue.identifier
      if identifier == 'EditBirthday'

        navigation_controller = segue.destinationViewController
        birthdayEditViewController = navigation_controller.topViewController
        birthdayEditViewController.birthday = @birthday

      end

  end



end