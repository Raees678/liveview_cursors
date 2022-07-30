defmodule LiveviewCursorsWeb.Cursors do
  alias LiveviewCursorsWeb.Presence
  import LiveviewCursorsWeb.Colors
  use LiveviewCursorsWeb, :live_view

  @cursorview "cursorview"

  def mount(_params, %{"user" => user}, socket) do
    Presence.track(self(), @cursorview, socket.id, %{
      socket_id: socket.id,
      x: 50,
      y: 50,
      msg: "",
      name: user
    })

    LiveviewCursorsWeb.Endpoint.subscribe(@cursorview)

    initial_users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(:user, user)
      |> assign(:users, initial_users)
      |> assign(:socket_id, socket.id)
      |> assign(:ping, 0)

    {:ok, updated}
  end

  def mount(_params, _session, socket) do
    {:ok, socket |> redirect(to: "/")}
  end

  def handle_event("cursor-move", %{"x" => x, "y" => y}, socket) do
    key = socket.id
    payload = %{x: x, y: y}

    updatePresence(key, payload)

    {:noreply, socket}
  end

  def handle_event("send_message", %{"msg" => msg}, socket) do
    updatePresence(socket.id, %{msg: msg})
    {:noreply, socket}
  end

  def handle_event("ping", %{}, socket) do
    {:reply, %{}, socket}
  end

  def updatePresence(key, payload) do
    metas =
      Presence.get_by_key(@cursorview, key)[:metas]
      |> List.first()
      |> Map.merge(payload)

    Presence.update(self(), @cursorview, key, metas)
  end

  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    users =
      Presence.list(@cursorview)
      |> Enum.map(fn {_, data} -> data[:metas] |> List.first() end)

    updated =
      socket
      |> assign(users: users)
      |> assign(socket_id: socket.id)

    {:noreply, updated}
  end

  def render(assigns) do
    ~H"""
    <section class="flex flex-col w-screen h-screen justify-center items-center text-center">
      <form
        id="msgform"
        phx-submit="send_message"
        class="rounded-xl bg-gradient-to-r to-violet-200 from-violet-100 p-8 drop-shadow-xl flex w-xs mx-auto space-x-3"
      >
        <input
          class="flex-1 appearance-none border border-transparent py-2 px-4 bg-white text-gray-600 placeholder-gray-400 shadow-md rounded-lg text-base focus:outline-none focus:ring-2 focus:ring-violet-600 focus:border-transparent"
          maxlength="30"
          aria-label="Your message"
          type="text"
          id="msg"
          name="msg"
          placeholder="Say something"
        />
        <input
          id="submit-msg"
          type="submit"
          class="flex-shrink-0 bg-violet-600 text-white text-base font-semibold py-2 px-4 rounded-lg shadow-md hover:bg-violet-700 focus:outline-none focus:ring-2 focus:ring-violet-500 focus:ring-offset-2 focus:ring-offset-violet-200"
          value="Change"
        />
      </form>
      <div id="ping-container" class="fixed bottom-2 text-sm text-gray-400 p-2" phx-update="ignore">
        <span id="ping" phx-hook="Ping">
          <%= @ping %>
        </span>
        <span>
          <%= if(System.get_env("FLY_REGION")) do %>
            from
            <img
              class="inline w-3 h-3 align-baseline"
              src={"https://fly.io/ui/images/#{System.get_env("FLY_REGION")}.svg"}
            />
          <% else %>
            from localhost
          <% end %>
        </span>
      </div>
      <ul class="list-none" id="cursors" phx-hook="TrackClientCursor">
        <%= for user <- @users do %>
          <% color = getHSL(user.name) %>
          <li
            style={"color: #{color}; left: #{user.x}%; top: #{user.y}%"}
            class="flex flex-col absolute pointer-events-none whitespace-nowrap overflow-hidden"
          >
            <svg
              version="1.1"
              width="25px"
              height="25px"
              xmlns="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              viewBox="0 0 21 21"
            >
              <polygon fill="black" points="8.2,20.9 8.2,4.9 19.8,16.5 13,16.5 12.6,16.6" />
              <polygon fill="currentColor" points="9.2,7.3 9.2,18.5 12.2,15.6 12.6,15.5 17.4,15.5" />
            </svg>
            <span style={"background-color: #{color};"} class="mt-1 ml-4 px-1 text-sm text-white">
              <%= user.name %>
            </span>
            <span
              style={"background-color: #{color};"}
              class="text-violet-50 mt-1 py-0 px-1 text-sm text-left rounded-sm opacity-80 fit-content"
            >
              <%= user.msg %>
            </span>
          </li>
        <% end %>
      </ul>
    </section>
    """
  end
end
