module StructuredDataHelper
  def local_business_jsonld
    biz = I18n.t("business")
    addr = biz[:address]
    geo = biz[:geo]

    data = {
      "@context" => "https://schema.org",
      "@type" => ["HomeAndConstructionBusiness", "LocalBusiness"],
      "name" => biz[:name],
      "description" => biz.dig(:seo, :description),
      "url" => root_url,
      "telephone" => biz[:phone_raw],
      "email" => biz[:email],
      "foundingDate" => biz[:founded_year],
      "priceRange" => biz[:price_range],
      "address" => {
        "@type" => "PostalAddress",
        "addressLocality" => addr[:city],
        "addressRegion" => addr[:state],
        "postalCode" => addr[:zip],
        "addressCountry" => "US"
      },
      "geo" => {
        "@type" => "GeoCoordinates",
        "latitude" => geo[:latitude],
        "longitude" => geo[:longitude]
      },
      "areaServed" => biz[:service_area_cities].map { |city|
        {
          "@type" => "City",
          "name" => "#{city}, #{addr[:state]}"
        }
      },
      "openingHoursSpecification" => biz[:working_hours].map { |h| parse_opening_hours(h) },
      "sameAs" => [biz.dig(:social, :facebook), biz.dig(:social, :instagram), biz.dig(:social, :google_business)].select(&:present?),
      "hasOfferCatalog" => {
        "@type" => "OfferCatalog",
        "name" => "Services",
        "itemListElement" => biz[:services].map { |_key, svc| service_offer(svc) }
      }
    }

    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def services_jsonld
    biz = I18n.t("business")
    services = biz[:services].map do |_key, svc|
      {
        "@context" => "https://schema.org",
        "@type" => "Service",
        "name" => svc[:name],
        "description" => svc[:description],
        "provider" => {
          "@type" => "HomeAndConstructionBusiness",
          "name" => biz[:name],
          "telephone" => biz[:phone_raw]
        },
        "areaServed" => biz[:service_area]
      }
    end

    safe_join(services.map { |s| tag.script(s.to_json.html_safe, type: "application/ld+json") })
  end

  def faq_jsonld(questions)
    data = {
      "@context" => "https://schema.org",
      "@type" => "FAQPage",
      "mainEntity" => questions.map do |q|
        {
          "@type" => "Question",
          "name" => q[:question],
          "acceptedAnswer" => {
            "@type" => "Answer",
            "text" => q[:answer]
          }
        }
      end
    }

    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  private

  def service_offer(svc)
    {
      "@type" => "Offer",
      "itemOffered" => {
        "@type" => "Service",
        "name" => svc[:name],
        "description" => svc[:short_description]
      }
    }
  end

  def extract_price(price_string)
    return "0" unless price_string
    price_string.gsub(/[^\d]/, "")
  end

  def parse_opening_hours(hours_string)
    days_part, time_part = hours_string.split(" ", 2)
    open_time, close_time = time_part.split("-")
    day_map = { "Mo" => "Monday", "Tu" => "Tuesday", "We" => "Wednesday", "Th" => "Thursday", "Fr" => "Friday", "Sa" => "Saturday", "Su" => "Sunday" }

    days = if days_part.include?("-")
             start_day, end_day = days_part.split("-")
             keys = day_map.keys
             range_start = keys.index(start_day)
             range_end = keys.index(end_day)
             keys[range_start..range_end].map { |d| day_map[d] }
           else
             [day_map[days_part]]
           end

    {
      "@type" => "OpeningHoursSpecification",
      "dayOfWeek" => days,
      "opens" => open_time,
      "closes" => close_time
    }
  end
end
