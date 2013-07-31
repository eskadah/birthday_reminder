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


end