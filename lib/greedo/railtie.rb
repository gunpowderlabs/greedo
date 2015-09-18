module Greedo
  class Railtie < ::Rails::Railtie
    initializer 'greedo' do |_app|
      Greedo.init
    end
  end
end
