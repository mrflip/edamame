# require 'monkeyshines/utils/factory_module'
module Edamame
  module Store
    autoload :Base,   'edamame/store/base'
    autoload :Tyrant, 'edamame/store/tyrant'
  end
end
