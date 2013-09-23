# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'birthdaytest'
  app.frameworks += ['CoreData','QuartzCore']
  app.file_dependencies 'app/BRBirthdayDetailViewController.rb' => 'app/brd_birthday.rb'
end
