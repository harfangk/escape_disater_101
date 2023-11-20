defmodule EscapeDisaster.Apis.Naver do
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

    resp_body =
      Jason.decode!(resp.body)

    if resp_body["status"] == "OK" do
      with address when not is_nil(address) <- List.first(resp_body["addresses"]),
           {x, _rem} <- Float.parse(address["x"]),
           {y, _rem} <- Float.parse(address["y"]) do
        {:ok, {x, y}}
      else
        nil -> {:error, :empty_geocoding_result_error}
        :error -> {:error, :parse_error}
        _ -> {:error, :unknown_error}
      end
    else
      {:error, :http_error}
    end
  end
end
