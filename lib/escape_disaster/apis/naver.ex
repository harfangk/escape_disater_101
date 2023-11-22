defmodule EscapeDisaster.Apis.Naver do
  require Logger
  @url "https://naveropenapi.apigw.ntruss.com/map-geocode/v2/geocode"
  def get_coordinates(address) do
    uri =
      @url
      |> URI.new!()
      |> URI.append_query(URI.encode_query(%{"query" => address}))
      |> URI.to_string()

    req =
      Req.Request.new(method: :get, url: uri)
      |> Req.Request.put_header(
        "X-NCP-APIGW-API-KEY-ID",
        Application.fetch_env!(:escape_disaster, :naver_map_client_id)
      )
      |> Req.Request.put_header(
        "X-NCP-APIGW-API-KEY",
        Application.fetch_env!(:escape_disaster, :naver_map_client_secret)
      )

    {_req, resp} = Req.Request.run_request(req)

    with %Req.Response{body: resp_body} <- resp,
         decoded_body <- Jason.decode!(resp_body),
         "OK" <- decoded_body["status"],
         resp_address when not is_nil(resp_address) <- List.first(decoded_body["addresses"]),
         {x, _rem} <- Float.parse(resp_address["x"]),
         {y, _rem} <- Float.parse(resp_address["y"]) do
      Logger.info("Success calling geocode API, result: {x: #{x}, y: #{y}}, query: #{address}")
      {:ok, {x, y}}
    else
      nil ->
        Logger.error(
          "Error calling geocode API, error_code: #{:empty_geocoding_result_error}, detail: none, query: #{address}"
        )

        {:error, :empty_geocoding_result_error}

      :error ->
        Logger.error(
          "Error calling geocode API, error_code: #{:parse_error}, detail: none, query: #{address}"
        )

        {:error, :parse_error}

      transport_error = %Mint.TransportError{} ->
        Logger.error(
          "Error calling geocode API, error_code: #{:transport_error}, detail: #{inspect(transport_error)}, query: #{address}"
        )

        {:error, :transport_error}

      http_error = %Mint.HTTPError{} ->
        Logger.error(
          "Error calling geocode API, error_code: #{:http_error}, detail: #{inspect(http_error)}, query: #{address}"
        )

        {:error, :http_error}

      error ->
        Logger.error(
          "Error calling geocode API, error_code: #{:unknown_error}, detail: #{inspect(error)}, query: #{address}"
        )

        {:error, :unknown_error}
    end
  end
end
