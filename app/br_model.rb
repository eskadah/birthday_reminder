class BRDModel
    attr_accessor :facebookAccount,:currentFacebookAction,:postToFacebookMessage,:postToFacebookID

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
    performSelectorOnMainThread('postAddressNotification:', withObject:userInfo, waitUntilDone:nil)


  end

   def postAddressNotification(userInfo)
     NSNotificationCenter.defaultCenter.postNotificationName('BRNotificationAddressBookBirthdaysDidUpdate', object: self, userInfo: userInfo)
   end


  def importBirthdays(birthdaysToImport)
    newUIDs = []
    birthdaysToImport.each_with_index do |importBirthday,_|
      uid = importBirthday.uid
      newUIDs << uid
    end
    existingBirthdays = getExistingBirthdaysWithUIDs(newUIDs)
    context = BRDModel.sharedInstance.managedObjectContext
    birthdaysToImport.each do |importBirthday|
      uid = importBirthday.uid
      birthday = existingBirthdays[uid]
      if birthday

      else
        birthday = NSEntityDescription.insertNewObjectForEntityForName('BirthdayReminder', inManagedObjectContext:context)
        birthday.uid = uid
        existingBirthdays[uid] = birthday
        birthday.name = importBirthday.name
        birthday.uid = importBirthday.uid
        birthday.picURL = importBirthday.picURL
        birthday.imageData = importBirthday.imageData
        birthday.addressBookID = importBirthday.addressBookID
        birthday.facebookID = importBirthday.facebookID
        birthday.birthDay = importBirthday.birthDay
        birthday.birthMonth = importBirthday.birthMonth
        birthday.birthYear = importBirthday.birthYear
        birthday.updateNextBirthdayAndAge

      end
    end
     saveChanges
    updateCachedBirthdays
  end

  def fetchFacebookBirthdays
    puts 'fetchFacebookBirthdays'
    unless facebookAccount
      self.currentFacebookAction = 'FacebookActionGetFriendsBirthdays'
      authenticateWithFacebook
      return
    end
    requestURL = NSURL.URLWithString('https://graph.facebook.com/me/friends')
    params = {'fields'=>'name,id,birthday'}
    request = SLRequest.requestForServiceType(SLServiceTypeFacebook, requestMethod: SLRequestMethodGET, URL: requestURL, parameters: params)
    request.account = facebookAccount
    handler = lambda do |responseData,urlResponse,error|
      if error
        NSLog('error with getting my friends birthdays: %@',error)
      else
        resultD = NSJSONSerialization.JSONObjectWithData(responseData, options: 0, error: nil)
        NSLog('facebook returned friends: %@', resultD)
        birthdayDictionaries = resultD['data']
        #birthdayCount =  birthdayDictionaries.count
        birthdays = []
        birthdayDictionaries.each do |facebookDictionary|
          birthDateS = facebookDictionary['birthday']
          next unless birthDateS
          NSLog('Found a Birthday from Facebook: %@',facebookDictionary)
          birthday = BRDBirthdayImport.alloc.initWithFacebookDictionary(facebookDictionary)
          birthdays << birthday
        end
        birthdays.sort_by!{|birthday| birthday.name}
        userInfo = {'birthdays'=> birthdays}
        performSelectorOnMainThread('postFacebookNotification:', withObject:userInfo, waitUntilDone:nil)
      end
    end
    request.performRequestWithHandler(handler)
  end

  def postFacebookNotification(userInfo)
    NSNotificationCenter.defaultCenter.postNotificationName('BRNotificationFaceBookBirthdaysDidUpdate', object: self, userInfo: userInfo)
  end

  def authenticateWithFacebook
    accountStore = ACAccountStore.alloc.init
    accountTypeFacebook = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
    options = {ACFacebookAppIdKey => '316689658473081', ACFacebookPermissionsKey => ['publish_actions','friends_birthday','email'], ACFacebookAudienceKey => ACFacebookAudienceFriends }
    completion = lambda do |granted, error|
      if granted
        puts 'Facebook Authorized!'
        accounts = accountStore.accountsWithAccountType accountTypeFacebook
        self.facebookAccount = accounts.last
        case currentFacebookAction
          when 'FacebookActionGetFriendsBirthdays' then fetchFacebookBirthdays
          when 'FacebookActionPostToWall'
            #self.postToFacebookWall(self.postToFacebookMessage,withFacebookID:self.postToFacebookID)
            array = [postToFacebookMessage,self.postToFacebookID]
            dict = {'message'=>postToFacebookMessage,'id'=>postToFacebookID}
          #performSelectorOnMainThread('postToFacebookWall:withFacebookID:', withObject:dict, waitUntilDone:true)

            gcdq_main = Dispatch::Queue.main
            gcdq_main.async do

              postToFacebookWall(postToFacebookMessage,withFacebookID:postToFacebookID)
            end
        end
      else
        if error.code == ACErrorAccountNotFound
          puts'No Facebook Account Found'
        else
          puts "authentication failed:#{error.localizedDescription}"
        end
      end
    end
    accountStore.requestAccessToAccountsWithType(accountTypeFacebook, options: options, completion: completion)

  end

  def postToFacebookWall(message,withFacebookID:id)
    puts 'postToFacebookWall Method Called from BRDMODEL'
    if self.facebookAccount.nil?
      puts 'not authorized to post to FB'
      self.postToFacebookID = id
      puts self.postToFacebookID
      self.postToFacebookMessage = message
      self.currentFacebookAction = 'FacebookActionPostToWall'

      authenticateWithFacebook
      return
    end

    puts 'we are authorized to post to FB!'
    fbcredential = facebookAccount.credential
    accessToken = fbcredential.oauthToken

    handler = lambda do |result,url,error|
      if error
        puts "there is an error:#{error.localizedDescription}"
      else
        puts "there was no error;#{url.absoluteString}" if url
      end

    end
    #params = {'app_id' => '316689658473081','name'=> 'Happy Birthday!','to'=>"#{self.postToFacebookID}"}
    params = {'app_id' => '316689658473081','name'=> 'Happy Birthday!','to'=>"#{id}"} #if id
    puts id
    puts params

      #session = FBSession.alloc.initWithAppID('316689658473081',permissions:nil,urlSchemeSuffix:nil,tokenCacheStrategy:nil)
      #FBSession.renewSystemCredentials(nil)
      #FBAccessTokenData.createTokenFromString(accessToken.to_s,permissions:nil,expirationDate:nil,)
    # make sure you add the FacebookAppID entry to info.plist before continuing with below
      session = FBSession.alloc.init
      session.openWithBehavior(FBSessionLoginBehaviorUseSystemAccountIfPresent,completionHandler:nil)
      FBWebDialogs.presentFeedDialogModallyWithSession(session,parameters:params,handler:handler)


  end



  def updateCachedBirthdays
    puts 'update cached bdays called'
    UIApplication.sharedApplication.cancelAllLocalNotifications
     fetchRequest = NSFetchRequest.alloc.init
    context = managedObjectContext
    entity = NSEntityDescription.entityForName('BirthdayReminder', inManagedObjectContext: context)
    sortDescriptor = NSSortDescriptor.alloc.initWithKey('nextBirthday', ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    fetchRequest.entity = entity
    fetchedResultsController = NSFetchedResultsController.alloc.initWithFetchRequest(fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    error = Pointer.new('@')
    unless fetchedResultsController.performFetch(error)
      puts error.localizedDescription
      abort
    end
     puts 'got here'
    fetchedObjects = fetchedResultsController.fetchedObjects
    resultCount = fetchedObjects.count
    scheduled = 0
    now = NSDate.date

    dateComponentsToday = NSCalendar.currentCalendar.components(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit, fromDate: now)
    today = NSCalendar.currentCalendar.dateFromComponents(dateComponentsToday)

    fetchedObjects.each do |birthday|
      if today < birthday.nextBirthday
        birthday.updateNextBirthdayAndAge
      end



    if scheduled< 20
      fireDate = BRDSettings.sharedInstance.reminderDateForNextBirthday(birthday.nextBirthday)
      if now.compare(fireDate)!= NSOrderedAscending
      else
        reminderNotification = UILocalNotification.alloc.init
        reminderNotification.fireDate = fireDate
        reminderNotification.timeZone = NSTimeZone.defaultTimeZone
        reminderNotification.alertAction = 'View Birthdays'
        reminderNotification.alertBody =BRDSettings.sharedInstance.reminderTextForNextBirthday(birthday)
        reminderNotification.soundName = 'HappyBirthday.m4a'
        reminderNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication.scheduleLocalNotification(reminderNotification)
        scheduled += 1
      end
    end
  end
    self.saveChanges
     puts 'got here too!'
   gcdq_main = Dispatch::Queue.main
  gcdq_main.async do
     puts 'got here too!'
     NSNotificationCenter.defaultCenter.postNotificationName('BRNotificationCachedBirthdaysDidUpdate', object: self, userInfo: nil)
  end

    true
  end

end