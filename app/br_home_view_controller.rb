class BRHomeViewController < BRCoreViewController

 def initWithCoder(aDecoder)

   a = super
   if a
     plistPath = NSBundle.mainBundle.pathForResource("birthdays", ofType:"plist")
     nonMutableBirthdays = NSArray.arrayWithContentsOfFile(plistPath)

    calendar =  NSCalendar.currentCalendar
    context = BRDModel.sharedInstance.managedObjectContext
     uids = [] ; i = 0
     while i < nonMutableBirthdays.length

       dictionary = nonMutableBirthdays[i]
       uid = dictionary['name']
       uids << uid
       i+=1
     end
     existingEntities = BRDModel.sharedInstance.getExistingBirthdaysWithUIDs(uids)
      index = 0
     while  index < nonMutableBirthdays.length
       dictionary = nonMutableBirthdays[index]
       uid = dictionary['name']
       birthday = existingEntities[uid]
       unless birthday
         birthday = NSEntityDescription.insertNewObjectForEntityForName("BirthdayReminder", inManagedObjectContext: context)
         existingEntities[uid] = birthday
         birthday.uid = uid
       end

     #nonMutableBirthdays.each do |dictionary|
     #birthday = NSEntityDescription.insertNewObjectForEntityForName('BirthdayReminder', inManagedObjectContext: context)
       name = dictionary['name']
       pic = dictionary['pic']
       birthdate = dictionary['birthdate']
     pathForPic = NSBundle.mainBundle.pathForResource(pic, ofType:nil)
     imageData = NSData.dataWithContentsOfFile(pathForPic)
     birthday.name = name
     birthday.imageData = imageData
     components = calendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate:birthdate)
     birthday.birthDay = components.day
     birthday.birthMonth = components.month
     birthday.birthYear = components.year
     birthday.updateNextBirthdayAndAge
     index += 1
     end

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
     #end
     BRDModel.sharedInstance.saveChanges
   end
   return a
end

 def viewDidLoad


   @table_view = view.viewWithTag 1
   puts @table_view.dataSource
   puts @table_view.delegate


 end

 def viewWillAppear(animated)
   super
   @table_view.reloadData
 end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
     cell = @table_view.dequeueReusableCellWithIdentifier('Cell')

    birthday =  fetchedResultsController.objectAtIndexPath(indexPath) #@birthdays[indexPath.row]
    brTableCell = cell
    brTableCell.birthday = birthday
    if birthday.imageData
      brTableCell.iconView.image = UIImage.imageWithData birthday.imageData
    else
       brTableCell.iconView.image = UIImage.imageNamed('icon-birthday-cake.png')
    end
     backgroundImage = indexPath.row == 0 ? UIImage.imageNamed('table-row-background.png') : UIImage.imageNamed('table-row-icing-background.png')
     brTableCell.backgroundView = UIImageView.alloc.initWithImage backgroundImage

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
       birthday = fetchedResultsController.objectAtIndexPath(selectedIndexPath)
       birthdayDetailViewController = segue.destinationViewController
       birthdayDetailViewController.birthday = birthday

    end if identifier == "BirthdayDetail"


    if identifier == "AddBirthday"

    context = BRDModel.sharedInstance.managedObjectContext
    birthday = NSEntityDescription.insertNewObjectForEntityForName('BirthdayReminder', inManagedObjectContext: context)
    birthday.updateWithDefaults
    navigationController = segue.destinationViewController
    birthdayEditViewController = navigationController.topViewController
    birthdayEditViewController.birthday = birthday
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
     @fetchedResultsController

   end

  def controllerDidChangeContent(controller)

  end

end



