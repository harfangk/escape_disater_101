defmodule EscapeDisasterWeb.MapLive do
  alias EscapeDisaster.CivilDefenseShelter
  alias EscapeDisaster.CivilDefenseWaterSource
  use Phoenix.LiveView
  import EscapeDisasterWeb.CoreComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:map_layers, %{
        "show_forest_fire" => true,
        "show_flood" => true,
        "show_disaster_warning" => true,
        "show_civil_defense_shelters" => false,
        "show_civil_defense_water_sources" => false
      })
      |> assign(:coordinates, %{
        "center" => nil,
        "top_right" => nil,
        "bottom_left" => nil
      })

    {:ok, socket}
  end

  def handle_event("toggle-forest-fire-layer", %{"show_forest_fire" => string_bool}, socket) do
    bool = String.to_existing_atom(string_bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_forest_fire", bool)

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-map-layer", %{layer: "forestFire", shouldShow: bool})

    {:noreply, socket}
  end

  def handle_event("toggle-flood-layer", %{"show_flood" => string_bool}, socket) do
    bool = String.to_existing_atom(string_bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_flood", bool)

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-map-layer", %{layer: "flood", shouldShow: bool})

    {:noreply, socket}
  end

  def handle_event(
        "toggle-disaster-warning-layer",
        %{"show_disaster_warning" => string_bool},
        socket
      ) do
    bool = String.to_existing_atom(string_bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_disaster_warning", bool)

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-map-layer", %{layer: "disasterWarning", shouldShow: bool})

    {:noreply, socket}
  end

  def handle_event(
        "toggle-civil-defense-shelters-layer",
        %{"show_civil_defense_shelters" => string_bool},
        socket
      ) do
    bool = String.to_existing_atom(string_bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_civil_defense_shelters", bool)

    shelters =
      if bool do
        CivilDefenseShelter.get_shelters_to_show(
          socket.assigns.coordinates["center"],
          socket.assigns.coordinates["bottom_left"],
          socket.assigns.coordinates["top_right"]
        )
      else
        []
      end

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-map-layer", %{
        layer: "civilDefenseShelters",
        shouldShow: bool,
        items: shelters
      })

    {:noreply, socket}
  end

  def handle_event(
        "toggle-civil-defense-water-sources-layer",
        %{"show_civil_defense_water_sources" => string_bool},
        socket
      ) do
    bool = String.to_existing_atom(string_bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_civil_defense_water_sources", bool)

    water_sources =
      if bool do
        CivilDefenseWaterSource.get_water_sources_to_show(
          socket.assigns.coordinates["center"],
          socket.assigns.coordinates["bottom_left"],
          socket.assigns.coordinates["top_right"]
        )
      else
        []
      end

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-map-layer", %{
        layer: "civilDefenseWaterSources",
        shouldShow: bool,
        items: water_sources
      })

    {:noreply, socket}
  end

  def handle_event(
        "update-map-info",
        %{
          "bottomLeft" => [bottom_left_x, bottom_left_y],
          "topRight" => [top_right_x, top_right_y],
          "center" => [center_x, center_y]
        },
        socket
      ) do
    coordinates =
      socket.assigns.coordinates
      |> Map.put("bottom_left", {bottom_left_x, bottom_left_y})
      |> Map.put("top_right", {top_right_x, top_right_y})
      |> Map.put("center", {center_x, center_y})

    socket =
      socket
      |> assign(:coordinates, coordinates)
      |> add_update_features_event()

    {:noreply, socket}
  end

  defp add_update_features_event(socket) do
    cond do
      socket.assigns.map_layers["show_civil_defense_shelters"] ->
        items =
          CivilDefenseShelter.get_shelters_to_show(
            socket.assigns.coordinates["center"],
            socket.assigns.coordinates["bottom_left"],
            socket.assigns.coordinates["top_right"]
          )

        socket
        |> push_event("update-map-features", %{
          layer: "civilDefenseShelters",
          items: items
        })

      socket.assigns.map_layers["show_civil_defense_water_sources"] ->
        items =
          CivilDefenseWaterSource.get_water_sources_to_show(
            socket.assigns.coordinates["center"],
            socket.assigns.coordinates["bottom_left"],
            socket.assigns.coordinates["top_right"]
          )

        socket
        |> push_event("update-map-features", %{
          layer: "civilDefenseWaterSources",
          items: items
        })

      true ->
        socket
    end
  end
end
