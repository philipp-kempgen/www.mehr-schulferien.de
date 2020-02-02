defmodule MehrSchulferienWeb.FederalStateController do
  use MehrSchulferienWeb, :controller

  import Ecto.Query
  alias MehrSchulferien.Display
  alias MehrSchulferien.Display.FederalState
  alias MehrSchulferien.Repo
  alias MehrSchulferien.Maps.Location
  alias MehrSchulferien.Calendars.Period
  alias MehrSchulferien.Calendars

  # def index(conn, _params) do
  #   federal_states = Display.list_federal_states()
  #   render(conn, "index.html", federal_states: federal_states)
  # end

  def show(conn, %{"id" => id}) do
    query =
      from(l in Location,
        where: l.id == ^id,
        where: l.is_federal_state == true,
        limit: 1
      )

    location = Repo.one(query)

    current_year = DateTime.utc_now().year
    current_month = DateTime.utc_now().month
    current_day = DateTime.utc_now().day

    last_year = current_year - 1
    next_year = current_year + 1

    current_school_year =
      case DateTime.utc_now().month do
        x when x < 8 ->
          [last_year, current_year]

        _ ->
          [current_year, next_year]
      end

    current_school_year_string = current_school_year |> Enum.join(" - ")

    [start_year, end_year] = current_school_year

    {:ok, starts_on} = Date.from_erl({start_year, 8, 1})
    {:ok, ends_on} = Date.from_erl({end_year, 7, 31})
    {:ok, today} = Date.from_erl({current_year, current_month, current_day})
    {:ok, today_next_year} = Date.from_erl({current_year + 2, current_month, current_day})

    location_ids = Calendars.recursive_location_ids(location)

    query =
      from(p in Period,
        where:
          p.location_id in ^location_ids and
            p.is_valid_for_students == true and
            p.is_school_vacation == true and
            p.starts_on >= ^today and p.starts_on <= ^today_next_year,
        order_by: p.starts_on
      )

    next_12_months_periods = Repo.all(query) |> Repo.preload(:holiday_or_vacation_type)

    render(conn, "show.html",
      location: location,
      current_year: current_year,
      current_school_year_string: current_school_year_string,
      next_12_months_periods: next_12_months_periods
    )
  end
end