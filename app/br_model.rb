class BRDModel

  def managedObjectContext
    coordinator = persistentStoreCoordinator
    @managedObjectContext ||= begin

      managedObjectContext = NSManagedObjectContext.alloc.init
      managedObjectContext.setPersistentStoreCoordinator(coordinator)
      managedObjectContext
    end if coordinator
    return @managedObjectContext
  end

  def managedObjectModel
     @managedObjectModel||= begin
     @managedObjectModel = NSManagedObjectModel.alloc.init
     #@managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
     #model_path = NSBundle.mainBundle.pathForResource("BirthdayReminder",ofType:'momd')
     #model_url = NSURL.fileURLWithPath(model_path)
     #@managedObjectModel = NSManagedObjectModel.alloc.initWithContentsOfURL(model_url)
    @managedObjectModel.setEntities([BRDBirthday.entity])
      #@managedObjectModel.entities = [BRDBirthday.entity]
    end
    #puts "this is managedObjectModel.entities #{@managedObjectModel.entities}"
    return @managedObjectModel
  end

  def persistentStoreCoordinator
    @persistentStoreCoordinator ||= begin
    storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BirthdayReminder.sqlite")
    error = Pointer.new(:object)
    persistentStoreCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel managedObjectModel

    unless persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: storeURL, options: nil, error: error)
      raise "Can't add persistent SQLite store: #{error[0].description}"
      abort
    end

    @persistentStoreCoordinator = persistentStoreCoordinator
    end
     @persistentStoreCoordinator
  end


  def applicationDocumentsDirectory
    NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains: NSUserDomainMask).lastObject
  end

  def self.sharedInstance
    @sharedInstance ||= self.alloc.init

    return @sharedInstance
  end

  def saveChanges
    error = Pointer.new('@')
    if self.managedObjectContext.hasChanges
      if self.managedObjectContext.save(error)

        puts "save in BRDMODEL succeeded"

      else
        raise "it failed #{error[0].description}"
      end
    end
  end


  def getExistingBirthdaysWithUIDs(uid)

       fetchRequest = NSFetchRequest.alloc.init
       context = @managedObjectContext
       predicate = NSPredicate.predicateWithFormat("uid IN %@",argumentArray:[uid])
       fetchRequest.predicate = predicate
       entity = NSEntityDescription.entityForName("BirthdayReminder", inManagedObjectContext: context)
       fetchRequest.entity = entity
       sortDescriptor = NSSortDescriptor.alloc.initWithKey("uid", ascending:true)
       fetchRequest.sortDescriptors = [sortDescriptor]
       fetchedResultsController = NSFetchedResultsController.alloc.initWithFetchRequest(fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
       error = Pointer.new(:object)
       unless fetchedResultsController.performFetch(error)
         puts "there was an error in performing the fetch for UIDS: #{error[0].description}"
         abort
       end
       fetchedObjects = fetchedResultsController.fetchedObjects
       resultCount = fetchedObjects.count
       return {} if resultCount == 0
       tmpDict = {}
       fetchedObjects.each{|f|birthday = f;tmpDict[birthday.uid] = birthday}
       return tmpDict

  end

   def cancelChanges
     managedObjectContext.rollback
   end

   # addressBook code starts

  def fetchAddressBookBirthdays
    addressbook = ABAddressBookCreateWithOptions(nil,nil)
    case ABAddressBookGetAuthorizationStatus()
      when KABAuthorizationStatusNotDetermined
        ABAddressBookRequestAccessWithCompletion(addressbook,lambda do |granted,error|

           if granted
             puts 'Access to the Address Book has been granted'
             gcdq_main = Dispatch::Queue.main
             gcdq_main.async do

               self.extractBirthdaysFromAddressBook(ABAddressBookCreateWithOptions(nil,nil))
             end
           else
             puts 'Access to the Address Book has been denied'
           end


        end
        )

      when KABAuthorizationStatusAuthorized
        puts 'User has already authorized access'
        extractBirthdaysFromAddressBook(ABAddressBookCreateWithOptions(nil,nil))
      when  KABAuthorizationStatusRestricted
        puts 'User cannot access due to parental controls'
      when  KABAuthorizationStatusDenied
         puts ' User has denied access'

    end
  end

  def extractBirthdaysFromAddressBook(addressbook)
    
    puts 'extractBirthdayFromAddressBook'
    
    people = ABAddressBookCopyArrayOfAllPeople(addressbook)
    peopleCount = ABAddressBookGetPersonCount(addressbook)
    birthdays = []
    (0...peopleCount).each do |i|
      addressbookRecord = CFArrayGetValueAtIndex(people, i)
      addressbookRecordObject = addressbookRecord.to_object
      birthdate = ABRecordCopyValue(addressbookRecordObject,KABPersonBirthdayProperty)
      next unless birthdate
      birthday = BRDBirthdayImport.alloc.initWithAddressBookRecord(addressbookRecord.to_object)
      birthdays << birthday
    end
    birthdays.sort_by!{|birthday| birthday.name}
    userInfo = {'birthdays' => birthdays}
    performSelectorOnMainThread('postNotification:', withObject:userInfo, waitUntilDone:nil)


  end

   def postNotification(userInfo)
     NSNotificationCenter.defaultCenter.postNotificationName('BRNotificationAddressBookBirthdaysDidUpdate', object: self, userInfo: userInfo)
   end
end