defmodule MehrSchulferien.PeriodsTest do
  use MehrSchulferien.DataCase

  import MehrSchulferien.Factory

  alias MehrSchulferien.Periods
  alias MehrSchulferien.Locations

  describe "periods for certain time frame" do
    setup [:add_federal_state, :add_periods]

    test "list_school_periods/4 returns all periods within a time frame", %{
      federal_state: federal_state,
      school_periods: school_periods,
      other_period: other_period
    } do
      location_ids = Locations.recursive_location_ids(federal_state)
      period_ids = Enum.map(school_periods, & &1.id)

      short_time_periods =
        Periods.list_school_periods(location_ids, ~D[2021-02-01], ~D[2022-01-31])

      assert length(short_time_periods) == 5

      # results include a holiday that has already started, but not ended yet
      short_time_periods =
        Periods.list_school_periods(location_ids, ~D[2021-04-11], ~D[2021-12-31])

      assert length(short_time_periods) == 4
      assert Enum.all?(short_time_periods, &(&1.id in period_ids))

      long_time_periods =
        Periods.list_school_periods(location_ids, ~D[2020-01-01], ~D[2022-12-31])

      assert Enum.all?(long_time_periods, &(&1.id in period_ids))
      assert other_period not in short_time_periods
      assert other_period not in long_time_periods
    end

    test "group_periods_single_year/2 groups periods with the same name together", %{
      federal_state: federal_state
    } do
      location_ids = Locations.recursive_location_ids(federal_state)
      today = ~D[2021-02-26]
      first_day = ~D[2021-01-01]
      last_day = ~D[2022-12-31]
      school_periods = Periods.list_school_periods(location_ids, first_day, last_day)
      assert length(school_periods) == 9
      grouped_periods = Periods.group_periods_single_year(school_periods, today)
      assert length(grouped_periods) == 4
      today = ~D[2021-03-02]
      school_periods = Periods.list_school_periods(location_ids, first_day, last_day)
      assert length(school_periods) == 9
      grouped_periods = Periods.group_periods_single_year(school_periods, today)
      assert length(grouped_periods) == 3
    end
  end

  describe "filter periods" do
    setup [:add_federal_state, :add_periods]

    test "next_periods/3 returns a certain number of next periods", %{
      school_periods: school_periods
    } do
      today = ~D[2020-04-02]
      assert [period_1, period_2, period_3] = Periods.next_periods(school_periods, today, 3)
      assert period_1.starts_on == ~D[2020-04-06]
      assert period_2.starts_on == ~D[2020-10-31]
      assert period_3.starts_on == ~D[2020-12-23]
      today = ~D[2020-05-16]
      assert [period_4, period_5] = Periods.next_periods(school_periods, today, 2)
      assert period_4 == period_2
      assert period_5 == period_3
    end

    test "find_most_recent_period/2 returns the most recently ended period", %{
      school_periods: school_periods
    } do
      today = ~D[2020-05-02]
      period = Periods.find_most_recent_period(school_periods, today)
      assert period.starts_on == ~D[2020-04-06]
      today = ~D[2021-03-16]
      period = Periods.find_most_recent_period(school_periods, today)
      assert period.starts_on == ~D[2021-02-24]
    end
  end

  defp add_federal_state(_) do
    federal_state = insert(:federal_state)
    {:ok, %{federal_state: federal_state}}
  end

  defp add_periods(%{federal_state: federal_state}) do
    school_periods = add_school_periods(%{location: federal_state})

    other_period =
      insert(:period, %{
        is_school_vacation: true,
        is_valid_for_students: true,
        starts_on: ~D[2020-10-31],
        ends_on: ~D[2020-10-31]
      })

    {:ok,
     %{federal_state: federal_state, school_periods: school_periods, other_period: other_period}}
  end
end
