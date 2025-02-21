defmodule MehrSchulferienWeb.Router do
  use MehrSchulferienWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", MehrSchulferienWeb do
    pipe_through :browser

    # Maps
    resources "/locations", LocationController
    resources "/zip_codes", ZipCodeController
    resources "/zip_code_mappings", ZipCodeMappingController

    # Calendars
    resources "/religions", ReligionController
    resources "/holiday_or_vacation_types", HolidayOrVacationTypeController
    resources "/periods", PeriodController
  end

  scope "/", MehrSchulferienWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/sommerferien", PageController, :summer_vacations
    get "/ferien/d/", PageController, :full_year
    get "/developers", PageController, :developers
    get "/impressum", PageController, :impressum

    get "/sitemap.xml", SitemapController, :index

    # Authentication
    resources "/users", UserController, except: [:index]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/confirms", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update

    # Old routes
    get "/cities/:city_slug/:from/:till", OldRoutes.CityController, :show
    get "/cities/:city_slug", OldRoutes.CityController, :show

    # School vacations
    get "/ferien/land/:country_slug", CountryController, :show
    get "/ferien/:country_slug/stadt/:city_slug/new_period", CityController, :new_period
    post "/ferien/:country_slug/stadt/:city_slug", CityController, :create_period
    get "/ferien/:country_slug/stadt/:city_slug", CityController, :show

    get "/ferien/:country_slug/bundesland/:federal_state_slug/new_period",
        FederalStateController,
        :new_period

    post "/ferien/:country_slug/bundesland/:federal_state_slug",
         FederalStateController,
         :create_period

    # Display holiday_or_vacation_type info
    get "/ferien/:country_slug/bundesland/:federal_state_slug/kategorie/:holiday_or_vacation_type_slug",
        FederalStateController,
        :show_holiday_or_vacation_type

    # School start information
    get "/ferien/:country_slug/bundesland/:federal_state_slug/schulbeginn",
        FederalStateController,
        :schulbeginn

    get "/ferien/:country_slug/bundesland/:federal_state_slug", FederalStateController, :show
    get "/ferien/:country_slug/schule/:school_slug/new_period", SchoolController, :new_period
    post "/ferien/:country_slug/schule/:school_slug", SchoolController, :create_period
    get "/ferien/:country_slug/schule/:school_slug", SchoolController, :show

    # Public holidays
    get "/feiertag/:country_slug/bundesland/:federal_state_slug/:holiday_or_vacation_type_slug",
        PublicHolidayController,
        :show_within_federal_state

    # Bridge days
    get "/brueckentage/:country_slug/bundesland/:federal_state_slug",
        BridgeDayController,
        :index_within_federal_state

    get "/brueckentage/:country_slug/bundesland/:federal_state_slug/:year",
        BridgeDayController,
        :show_within_federal_state

    # Misc
    get "/landkreise-und-staedte/:country_slug/:federal_state_slug",
        FederalStateController,
        :county_show
  end

  scope "/api/v2.0", MehrSchulferienWeb.Api.V2, as: :api do
    pipe_through :api

    resources "/locations", LocationController, only: [:index, :show]
    resources "/periods", PeriodController, only: [:index, :show]
    resources "/holiday_or_vacation_types", HolidayOrVacationTypeController, only: [:index, :show]
    get "/vcards/schools/:slug", VCardController, :school_show
    get "/icalendars/location/:slug", ICalController, :show
  end
end
