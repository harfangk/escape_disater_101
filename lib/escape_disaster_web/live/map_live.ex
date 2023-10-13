defmodule EscapeDisasterWeb.MapLive do
  alias EscapeDisaster.CivilDefenseShelter
  use Phoenix.LiveView
  import EscapeDisasterWeb.CoreComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:map_layers, %{
        "show_forest_fire" => true,
        "show_flood" => true,
        "show_disaster_warning" => true,
        "show_civil_defense_shelters" => false
      })
      |> assign(:coordinates, %{
        "center" => nil,
        "top_right" => nil,
        "bottom_left" => nil
      })

    {:ok, socket}
  end

  def handle_event("toggle-forest-fire-layer", %{"show_forest_fire" => bool}, socket) do
    new_bool = String.to_existing_atom(bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_forest_fire", new_bool)

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-layer", %{key: "forestFire", value: new_bool})

    {:noreply, socket}
  end

  def handle_event("toggle-flood-layer", %{"show_flood" => bool}, socket) do
    new_bool = String.to_existing_atom(bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_flood", new_bool)

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-layer", %{key: "flood", value: new_bool})

    {:noreply, socket}
  end

  def handle_event("toggle-disaster-warning-layer", %{"show_disaster_warning" => bool}, socket) do
    new_bool = String.to_existing_atom(bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_disaster_warning", new_bool)

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-layer", %{key: "disasterWarning", value: new_bool})

    {:noreply, socket}
  end

  def handle_event(
        "toggle-civil-defense-shelters-layer",
        %{"show_civil_defense_shelters" => bool},
        socket
      ) do
    new_bool = String.to_existing_atom(bool)

    map_layers =
      socket.assigns.map_layers
      |> Map.put("show_civil_defense_shelters", new_bool)

    shelters =
      if new_bool do
        CivilDefenseShelter.get_shelters_to_show(
          socket.assigns.coordinates.bottomLeft,
          socket.assigns.coordinates.topRight
        )
      else
        []
      end

    socket =
      socket
      |> assign(:map_layers, map_layers)
      |> push_event("toggle-layer", %{key: "civilDefenseShelters", value: new_bool})

    {:noreply, socket}
  end

  def handle_event(
        "update-map-info",
        %{"bottomLeft" => bottom_left, "topRight" => top_right, "center" => center},
        socket
      ) do
    coordinates =
      socket.assigns.coordinates
      |> Map.put("bottom_left", bottom_left)
      |> Map.put("top_right", top_right)
      |> Map.put("center", center)

    socket =
      socket
      |> assign(:coordinates, coordinates)

    {:noreply, socket}
  end
end
