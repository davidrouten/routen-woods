class Ahoy::Store < Ahoy::DatabaseStore
end

Ahoy.api = true
Ahoy.geocode = false
Ahoy.cookies = :none
Ahoy.server_side_visits = :when_needed

Ahoy.exclude_method = lambda { |_controller, request|
  request.path.start_with?("/admin")
}
