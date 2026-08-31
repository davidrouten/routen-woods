class Ahoy::Store < Ahoy::DatabaseStore
end

Ahoy.api = true
Ahoy.geocode = false
Ahoy.cookies = :none
Ahoy.server_side_visits = :when_needed
