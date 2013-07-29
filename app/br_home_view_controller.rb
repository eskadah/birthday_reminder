class BRHomeViewController < BRCoreViewController

 def initWithCoder(aDecoder)
   a = super
   if a
     plistPath = NSBundle.mainBundle.pathForResource("birthdays", ofType:"plist")
     nonMutableBirthdays = NSArray.arrayWithContentsOfFile(plistPath)
     @birthdays = []

     nonMutableBirthdays.each do |dictionary|

       name = dictionary['name']
       pic = dictionary['pic']
       image = UIImage.imageNamed(pic)
       birthdate = dictionary['birthdate']
       birthday =  {}
       birthday['name'] = name
       birthday['image'] = image
       birthday['birthdate']= birthdate
       @birthdays << birthday
     end
   end
   return a
end

 def viewDidLoad

   @table_view = view.viewWithTag 1


 end

 def viewWillAppear(animated)
   super
   @table_view.reloadData
 end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
     cell = @table_view.dequeueReusableCellWithIdentifier('Cell')

    birthday = @birthdays[indexPath.row]
    name = birthday['name']
    birthdate = birthday['birthdate']
    image = birthday['image']

    cell.textLabel.text = name
    cell.detailTextLabel.text = birthdate.description
    cell.imageView.image = image

    return cell
  end

  def tableView(tableView, numberOfRowsInSection:section)
     @birthdays.count
  end

  def tableView (tableView,didSelectRowAtIndexPath:indexPath)

    @table_view.deselectRowAtIndexPath(indexPath,animated:true)

  end

  def prepareForSegue(segue,sender:sender)
    #puts "prepare for Segue!"

    identifier = segue.identifier
    begin
       selectedIndexPath = @table_view.indexPathForSelectedRow
       birthday = @birthdays[selectedIndexPath.row]
       birthdayDetailViewController = segue.destinationViewController
       birthdayDetailViewController.birthday = birthday

    end if identifier == "BirthdayDetail"


    if identifier == "AddBirthday"
      birthday = {}
      birthday['name'] = 'My Friend'
      birthday['birthdate'] = NSDate.date
      @birthdays << birthday
      navigation_Controller = segue.destinationViewController
      birthdayEditViewController = navigation_Controller.topViewController
      birthdayEditViewController.birthday = birthday
      puts birthday
    end

  end



end



