class BRHomeViewController < BRCoreViewController
attr_accessor :has_friends



 def viewDidLoad

    super
   @table_view = view.viewWithTag 1


   @importView = view.viewWithTag 20
   @addressBookButton = view.viewWithTag 21
   @facebookButton = view.viewWithTag 22
   @addressBookButton.addTarget(self, action:'importFromAddressBookTapped:',forControlEvents:UIControlEventTouchUpInside)
   @facebookButton.addTarget(self, action:'importFromFacebookTapped:',forControlEvents:UIControlEventTouchUpInside)
   @importLabel = view.viewWithTag 23
   @addressBook = toolbarItems[1]
   @addressBook.target = self
   @addressBook.action ='importFromAddressBookTapped:'
   @facebook = toolbarItems[3]
   @facebook.target = self
   @facebook.action ='importFromFacebookTapped:'


   BRStyleSheet.styleLabel(@importLabel,withType:'BRLabelTypeLarge')

 end

 def has_friends=(flag)
    @has_friends = flag
    @importView.hidden = @has_friends
    @table_view.hidden = !@has_friends
    if navigationController.topViewController == self
        navigationController.setToolbarHidden(!@has_friends,animated:false)
    end

 end

 def viewWillAppear(animated)
   super
   puts 'home view will appear'
   @table_view.reloadData
   self.has_friends = fetchedResultsController.fetchedObjects.count > 0
   #BRDModel.sharedInstance.updateCachedBirthdays
   NSNotificationCenter.defaultCenter.addObserver(self, selector: 'handleCachedBirthdaysDidUpdate:', name: 'BRNotificationCachedBirthdaysDidUpdate', object: nil)
   NSNotificationCenter.defaultCenter.addObserver(self, selector: 'updateBirthdays', name: UIApplicationDidBecomeActiveNotification, object: nil)
 end

def viewWillDisappear(animated)
  super
  NSNotificationCenter.defaultCenter.removeObserver(self, name: 'BRNotificationCachedBirthdaysDidUpdate', object: nil)
  NSNotificationCenter.defaultCenter.removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
end

def handleCachedBirthdaysDidUpdate(notification)
  puts ' handleCachedBirthdaysCalled'
  @table_view.reloadData
end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
     cell = @table_view.dequeueReusableCellWithIdentifier('Cell')

    birthday =  fetchedResultsController.objectAtIndexPath(indexPath) #@birthdays[indexPath.row]
    brTableCell = cell
    brTableCell.birthday = birthday
    #if birthday.imageData
    #  brTableCell.iconView.image = UIImage.imageWithData birthday.imageData
    #else
    #   brTableCell.iconView.image = UIImage.imageNamed('icon-birthday-cake.png')
    #end

     if birthday.imageData == nil
       if birthday.picURL && birthday.picURL.length > 0
         brTableCell.iconView.setImageWithRemoteFileURL(birthday.picURL,placeHolderImage:UIImage.imageNamed('icon-birthday-cake.png'))

       end

         if birthday.picURL && birthday.picURL.length > 0 &&  UIImageView.imageCache.cachedImageForURL(birthday.picURL)
         puts'called length > 0 and has picURL 2'

         brTableCell.iconView.image = UIImageView.imageCache.cachedImageForURL(birthday.picURL)
       else
         brTableCell.iconView.image = UIImage.imageNamed('icon-birthday-cake.png')
       end
     else
       brTableCell.iconView.image = UIImage.imageWithData(birthday.imageData)
     end

     backgroundImage = indexPath.row == 0 ? UIImage.imageNamed('table-row-background.png') : UIImage.imageNamed('table-row-icing-background.png')
     brTableCell.backgroundView = UIImageView.alloc.initWithImage backgroundImage

    return brTableCell
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

  def importFromAddressBookTapped(sender)
    nav = self.storyboard.instantiateViewControllerWithIdentifier 'ImportAddressBook'
    navigationController.presentViewController(nav,animated: true,completion:nil)
  end

  def importFromFacebookTapped(sender)
    puts 'import from facebook'
    nav = self.storyboard.instantiateViewControllerWithIdentifier 'ImportFacebook'
    navigationController.presentViewController(nav,animated: true,completion:nil)
  end

  def controllerDidChangeContent(controller)

  end

  def updateBirthdays
    puts 'updateBdaysCalled on active notification'
    BRDModel.sharedInstance.updateCachedBirthdays
  end

end



