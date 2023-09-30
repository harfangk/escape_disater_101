import { Map, View } from 'ol';
import TileLayer from 'ol/layer/Tile';
import TileWMS from 'ol/source/TileWMS';
import XYZ from 'ol/source/XYZ';
import { transform } from 'ol/proj';

// Calling API on our own backend, downloading and saving map tile images, then serving them would hide these keys
// but will incur network costs that we're not willing to pay at the moment, so the keys are exposed to the public.
const DEFAULT_CENTER_COORDINATE = [127.05488, 37.27538]
const VWORLD_API_KEY = 'B1E465C1-3237-368E-8ACF-AA0E89EA8C43'
const VWORLD_DOMAIN = 'http://localhost:4000'
const VWORLD_WMS_URL = `https://api.vworld.kr/req/wms?KEY=${VWORLD_API_KEY}&DOMAIN=${encodeURIComponent(VWORLD_DOMAIN)}`
const VWORLD_WMTS_URL = `https://api.vworld.kr/req/wmts/1.0.0/${VWORLD_API_KEY}/Base/{z}/{y}/{x}.png`
const SAFEMAP_API_KEY = 'CD1CCFGI-CD1C-CD1C-CD1C-CD1CCFGI4Z'
const SAFEMAP_URL = `https://www.safemap.go.kr/openApiService/wms/getLayerData.do?apikey=${SAFEMAP_API_KEY}`

function getCenterCoordinate() {
  if (navigator && navigator.geolocation) {
    const coords = navigator.geolocation.getCurrentPosition(geolocationPosition => {
      return [geolocationPosition.coords.longitude, geolocationPosition.coords.latitude]
    }, _geolocationPositionError => {
      return DEFAULT_CENTER_COORDINATE
    })
    return DEFAULT_CENTER_COORDINATE
  } else {
    return DEFAULT_CENTER_COORDINATE
  }
}

function transformCoordinate(coordinate) {
  return transform(coordinate, 'EPSG:4326', 'EPSG:3857')
}

const forestFireLayer = new TileLayer({
  source: new TileWMS({
    url: VWORLD_WMS_URL,
    params: {
      LAYERS: ['lt_c_kfdrssigugrade'],
      STYLES: 'lt_c_kfdrssigugrade',
      VERSION: '1.3.0',
    },
    serverType: 'geoserver'
  })
})

const floodLayer = new TileLayer({
  source: new TileWMS({
    url: SAFEMAP_URL,
    params: {
      LAYERS: ['A2SM_FLUDEXPECT_22'],
      VERSION: '1.1.1',
    },
    serverType: 'geoserver'
  })
})

const disasterWarningLayer = new TileLayer({
  source: new TileWMS({
    url: VWORLD_WMS_URL,
    params: {
      LAYERS: ['lt_c_up201'],
      STYLES: 'lt_c_up201',
      VERSION: '1.3.0',
    },
    serverType: 'geoserver'
  })
})

const vworldBaseLayer = new TileLayer({
  source: new XYZ({ url: VWORLD_WMTS_URL }),
  properties: { name: 'base-vworld-base' },
  minZoom: 5,
  maxZoom: 19,
});

const center = transformCoordinate(getCenterCoordinate())

const view = new View({
  center: center,
  zoom: 8
})

let map

window.addEventListener("phx:page-loading-stop", _ => {
  map = new Map({
    target: 'map',
    layers: [
      vworldBaseLayer,
      forestFireLayer,
      floodLayer,
      disasterWarningLayer
    ],
    view: view
  });
})
