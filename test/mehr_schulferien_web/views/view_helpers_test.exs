defmodule MehrSchulferienWeb.ViewHelpersTest do
  use MehrSchulferienWeb.ConnCase

  alias MehrSchulferienWeb.ViewHelpers

  describe "returns number of days" do
    test "shows number of days for single period" do
      period = insert(:period, %{starts_on: ~D[2020-03-01], ends_on: ~D[2020-03-01]})
      assert ViewHelpers.number_days([period]) == 1
      period = insert(:period, %{starts_on: ~D[2020-03-01], ends_on: ~D[2020-03-07]})
      assert ViewHelpers.number_days([period]) == 7
    end

    test "shows combined number of days for multiple periods" do
      period_1 = insert(:period, %{starts_on: ~D[2020-03-01], ends_on: ~D[2020-03-04]})
      period_2 = insert(:period, %{starts_on: ~D[2020-03-21], ends_on: ~D[2020-03-22]})
      assert ViewHelpers.number_days([period_1, period_2]) == 6
    end
  end

  describe "format date range" do
    test "same date just shows one date" do
      assert ViewHelpers.format_date_range(~D[2020-04-06], ~D[2020-04-06]) == "06.04.20"
    end

    test "different dates show range" do
      assert ViewHelpers.format_date_range(~D[2020-04-06], ~D[2020-04-16]) ==
               "06.04.20 - 16.04.20"
    end

    test "setting short value does not show year" do
      assert ViewHelpers.format_date_range(~D[2020-04-06], ~D[2020-04-06], :short) == "06.04."

      assert ViewHelpers.format_date_range(~D[2020-04-06], ~D[2020-04-16], :short) ==
               "06.04. - 16.04."
    end
  end

  describe "displays the year" do
    test "displays the first year in the list of periods" do
      period_1 = insert(:period, %{starts_on: ~D[2020-03-01], ends_on: ~D[2020-03-04]})
      period_2 = insert(:period, %{starts_on: ~D[2021-03-21], ends_on: ~D[2021-03-22]})
      assert ViewHelpers.display_year([[period_1, period_2], []]) == 2020
      assert ViewHelpers.display_year([[period_2], [period_1]]) == 2021
      assert ViewHelpers.display_year([[], [period_1, period_2]]) == 2020
    end
  end

  describe "gets the html_class" do
    test "shows html_class if date is a holiday" do
      period =
        insert(:period, %{
          html_class: "success",
          starts_on: ~D[2020-03-01],
          ends_on: ~D[2020-03-04]
        })

      assert ViewHelpers.get_html_class(~D[2020-03-02], 1, [period]) == "success"
      assert ViewHelpers.get_html_class(~D[2020-03-05], 4, [period]) == ""
    end

    test "shows active if date is a weekend" do
      period =
        insert(:period, %{
          html_class: "success",
          starts_on: ~D[2020-03-01],
          ends_on: ~D[2020-03-04]
        })

      assert ViewHelpers.get_html_class(~D[2020-03-08], 7, [period]) == "active"
      assert ViewHelpers.get_html_class(~D[2020-03-12], 4, [period]) == ""
    end
  end
end
