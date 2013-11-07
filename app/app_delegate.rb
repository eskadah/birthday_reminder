class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    story_board = UIStoryboard.storyboardWithName('MainStoryBoard1', bundle: NSBundle.mainBundle)

    root_controller = story_board.instantiateInitialViewController


    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController =root_controller
    #root_controller.view.sizeToFit
    @window.makeKeyAndVisible

    BRStyleSheet.initStyles



    true
  end

 def applicationDidBecomeActive(application)
   UIApplication.sharedApplication.applicationIconBadgeNumber = 0
 end






end


