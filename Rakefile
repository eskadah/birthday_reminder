# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
  rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'birthdaytest'
  app.frameworks += ['CoreData','QuartzCore','AddressBook','Accounts','Social']
  app.file_dependencies 'app/app_delegate.rb' => 'app/br_model.rb'
  app.file_dependencies 'app/br_home_view_controller.rb' => 'app/ui_image_view.rb'
  app.info_plist['FacebookAppID'] = '316689658473081'
  app.pods do
    pod 'Facebook-iOS-SDK'
  end
end
