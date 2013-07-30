class BRHomeViewController < BRCoreViewController

 def initWithCoder(aDecoder)
   puts 'in alloc'
   a = super
   if a
     plistPath = NSBundle.mainBundle.pathForResource("birthdays", ofType:"plist")
     nonMutableBirthdays = NSArray.arrayWithContentsOfFile(plistPath)
     #@birthdays = []
    calendar =  NSCalendar.currentCalendar
     puts calendar
    context = BRDModel.sharedInstance.managedObjectContext
      puts 'context ran!'

     nonMutableBirthdays.each do |dictionary|
     birthday = NSEntityDescription.insertNewObjectForEntityForName('BirthdayReminder', inManagedObjectContext: context)
     name = dictionary['name']
     pic = dictionary['pic']
     birthdate = dictionary['birthdate']
     pathForPic = NSBundle.mainBundle.pathForResource(pic, ofType:nil)
     imageData = NSData.dataWithContentsOfFile(pathForPic)
     birthday.name = name
     birthday.imageData = imageData
     components = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:birthdate)
     birthday.birthDay = components.day
     birthday.birthMonth = components.month
     birthday.birthYear = components.year
     birthday.updateNextBirthdayAndAge


=begin
   name = dictionary['name']
       pic = dictionary['pic']
       image = UIImage.imageNamed(pic)
       birthdate = dictionary['birthdate']
       birthday =  {}
       birthday['name'] = name
       birthday['image'] = image
       birthday['birthdate']= birthdate
       @birthdays << birthday
=end
     end
     BRDModel.sharedInstance.saveChanges
   end
   return a
end

 def viewDidLoad
   puts 'in viewdidload'

   @table_view = view.viewWithTag 1


 end

 def viewWillAppear(animated)
   super
   @table_view.reloadData
 end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
     cell = @table_view.dequeueReusableCellWithIdentifier('Cell')

    birthday =  fetchedResultsController.objectAtIndexPath(indexPath) #@birthdays[indexPath.row]


    #name = birthday['name']
    #birthdate = birthday['birthdate']
    #image = birthday['image']

    cell.textLabel.text = birthday.name
    cell.detailTextLabel.text = birthday.birthdayTextToDisplay
    cell.imageView.image = UIImage.imageWithData(birthday.imageData)

     p birthday.name
     p fetchedResultsController.fetchedObjects.map{|x| x.name}


    return cell
  end

  def tableView(tableView, numberOfRowsInSection:section)
    sectionInfo = fetchedResultsController.sections.objectAtIndex(section)
    sectionInfo.numberOfObjects
     #@birthdays.count
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

   def fetchedResultsController
     if @fetchedResultsController == nil
       fetchRequest = NSFetchRequest.alloc.init
       context = BRDModel.sharedInstance.managedObjectContext
       entity = NSEntityDescription.entityForName("BirthdayReminder", inManagedObjectContext: context)
       fetchRequest.entity = entity
       sortdescriptor = NSSortDescriptor.alloc.initWithKey("nextBirthday", ascending: true)
       sortDescriptors = NSArray.alloc.initWithObjects(sortdescriptor,nil)
       fetchRequest.sortDescriptors = sortDescriptors
       @fetchedResultsController = NSFetchedResultsController.alloc.initWithFetchRequest(fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
       @fetchedResultsController.delegate = self
       error = Pointer.new('@')
        unless @fetchedResultsController.performFetch(error)
          puts "Unresolved Error"
        end
     end
     puts "this is #{@fetchedResultsController.nil?} "
     p entity
     @fetchedResultsController

   end

  def controllerDidChangeContent(controller)

  end

end



