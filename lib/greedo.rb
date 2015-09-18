require "haml"

require "greedo/version"
require "greedo/grid_helper"
require "greedo/paginator"
require "greedo/railtie"
require "greedo/engine"

module Greedo
  def self.init
    ActiveSupport.on_load(:action_view) do
      ::ActionView::Base.send :include, Greedo::GridHelper
    end
  end
end
