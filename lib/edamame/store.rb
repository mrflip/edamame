require 'monkeyshines/utils/factory_module'
module Edamame
  module Store
    extend FactoryModule
    autoload :Base,        'edamame/store/base'
    autoload :TyrantStore, 'edamame/store/tyrant_store'
  end
end
