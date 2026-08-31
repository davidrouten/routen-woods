# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/map_adapters", under: "map_adapters"
pin "leaflet" # @1.9.4
pin "ahoy.js" # @0.4.5
pin "chartist" # @1.5.0
