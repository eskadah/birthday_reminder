class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    story_board = UIStoryboard.storyboardWithName('MainStoryBoard', bundle: NSBundle.mainBundle)

    root_controller = story_board.instantiateInitialViewController


    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController =root_controller
    #root_controller.view.sizeToFit
    @window.makeKeyAndVisible
    true
  end
end
