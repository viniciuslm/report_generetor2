defmodule GenReport do
  alias GenReport.Parser

  def build(), do: {:error, "Insira o nome de um arquivo"}

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.map(& &1)
    |> generetor
  end

  defp generetor(report) do
    persons =
      report
      |> Enum.map(fn [v1, _v2, _v3, _v4, _v5] -> v1 end)
      |> return_frequencia

    months =
      report
      |> Enum.map(fn [_v1, _v2, _v3, v4, _v5] -> v4 end)
      |> return_frequencia

    years =
      report
      |> Enum.map(fn [_v1, _v2, _v3, _v4, v5] -> v5 end)
      |> return_frequencia

    report =
      report
      |> Enum.reduce(report_acc(persons, months, years), fn line, report ->
        sum_values(line, report)
      end)

    report
  end

  defp sum_values([person, hour, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = Map.put(all_hours, person, all_hours[person] + hour)
    hours_per_month = Map.put(hours_per_month, person, sum_hours(hours_per_month[person], month, hour))
    hours_per_year = Map.put(hours_per_year, person, sum_hours(hours_per_year[person], year, hour))

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp sum_hours(person, key, hour) do
    Map.put(person, key, person[key] + hour)
  end

  defp return_frequencia(list) do
    list
    |> Enum.frequencies()
    |> Enum.map(fn {k, _v} -> k end)
  end

  defp report_acc(persons, months, years) do
    months = Enum.into(months, %{}, &{&1, 0})
    months = Enum.into(persons, %{}, &{&1, months})

    years = Enum.into(years, %{}, &{&1, 0})
    years = Enum.into(persons, %{}, &{&1, years})

    persons = Enum.into(persons, %{}, &{&1, 0})

    %{"all_hours" => persons, "hours_per_month" => months, "hours_per_year" => years}
  end
end
