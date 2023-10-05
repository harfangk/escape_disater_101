defmodule EscapeDisasterWeb.MapLive do
  use Phoenix.LiveView
  import EscapeDisasterWeb.CoreComponents

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :map_layers, %{
       "show_forest_fire" => true,
       "show_flood" => true,
       "show_disaster_warning" => true
     })}
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
end
