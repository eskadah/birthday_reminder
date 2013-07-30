class BRDModel

  def managedObjectContext
    coordinator = persistentStoreCoordinator
    puts ' this is coordinator'
    @managedObjectContext ||= begin

      managedObjectContext = NSManagedObjectContext.alloc.init
      managedObjectContext.setPersistentStoreCoordinator(coordinator)
    end if coordinator
    return @managedObjectContext
  end

  def managedObjectModel
    puts "in managedObjectModel"
    @managedObjectModel||= begin
     #modelURL = NSBundle.mainBundle.URLForResource("BirthdayReminder", withExtension:'momd')
     @managedObjectModel = NSManagedObjectModel.alloc.init
     puts" beneath initialization of Model"
     #@managedObjectModel = NSManagedObjectModel.alloc.initWithContentsOfURL(modelURL)
    # @managedObjectModel.setEntities([BRDBirthday.entity])

      #puts" beneath set entities"
    end
    puts "this is managedObjectModel #@managedObjectModel"
    return @managedObjectModel
  end

  def persistentStoreCoordinator
    @persistentStoreCoordinator ||= begin
    storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("BirthdayReminder.sqlite")
    error = Pointer.new(:object)
    persistentStoreCoordinator = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel managedObjectModel
    p "persistentstore coordinator has been initialized"
    unless persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL: storeURL, options: nil, error: error)
      raise "Can't add persistent SQLite store: #{error[0].description}"
      abort
    end
    p "at the end of persistentstorecoordinator"
    @persistentStoreCoordinator = persistentStoreCoordinator
    end
     @persistentStoreCoordinator
  end


  def applicationDocumentsDirectory
    NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains: NSUserDomainMask).lastObject
  end

  def self.sharedInstance
    @sharedInstance ||= self.alloc.init
    puts 'in shared instance complete'
    return @sharedInstance
  end

  def saveChanges
    puts persistentStoreCoordinator.nil?
    puts applicationDocumentsDirectory.nil?
    puts managedObjectModel.nil?
    puts managedObjectContext.nil?
    error = Pointer.new('@')
    if self.managedObjectContext.hasChanges
      unless self.managedObjectContext.save(nil)
        puts "save in BRDMODEL failed"

      else
        puts "save in BRDMODEL succeeded"
      end
    end
  end


end